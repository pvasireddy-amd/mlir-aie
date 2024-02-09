# This file is licensed under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
# (c) Copyright 2023 AMD Inc.

# RUN: VITIS_DIR=$VITIS WORKDIR=$PWD XRT_DIR=%XRT_DIR %PYTHON %s

from __future__ import annotations

import sys

from aie.extras.context import ExplicitlyManagedModule
from aie.extras.dialects.ext import arith, func, linalg
from aie.extras.runtime.passes import Pipeline, run_pipeline
from aie.extras.util import find_ops
from filelock import FileLock
import numpy as np

from aie.dialects import aie, aiex, builtin, pdl
from aie.dialects.aie import (
    AIEDevice,
    DMAChannelDir,
    LockAction,
    WireBundle,
)
from aie.dialects.linalg.opdsl.ops.core_named_ops import fill as linalg_fill
from aie.dialects.transform import any_op_t, apply_registered_pass, get_parent_op
from aie.dialects.transform.extras import named_sequence
from aie.dialects.transform.loop import loop_unroll
from aie.dialects.transform.structured import structured_match
import aie.extras.types as T
from aie.ir import StringAttr, UnitAttr
from aie.xrt import XCLBin
from util import (
    compile_with_vectorization,
    construct_and_print_module,
    make_xclbin,
    setup_xclbin_firmware,
)

DMA = WireBundle.DMA
S2MM = DMAChannelDir.S2MM
MM2S = DMAChannelDir.MM2S
Acquire = LockAction.Acquire
AcquireGreaterEqual = LockAction.AcquireGreaterEqual
Release = LockAction.Release

M, K, N = 16, 32, 16


@func.func(sym_visibility="private")
def matmul_i32_i32(
    A: T.memref(M, K, T.i32()),
    B: T.memref(K, N, T.i32()),
    C: T.memref(M, N, T.i32()),
):
    linalg.matmul(A, B, C)


# CHECK-LABEL: nonsquare_matrix_mult_vectorized
@construct_and_print_module
def nonsquare_matrix_mult_vectorized(module):
    mod_aie = ExplicitlyManagedModule()

    @aie.device(AIEDevice.ipu)
    def ipu():
        matmul_i32_i32.emit(decl=True)
        tile_0_0 = aie.tile(0, 0)
        tile_0_1 = aie.tile(0, 1)
        tile_0_2 = aie.tile(0, 2)

        # in
        buffer_0_2_a = aie.buffer(T.memref(M, K, T.i32()), tile_0_2)
        buffer_0_2_b = aie.buffer(T.memref(K, N, T.i32()), tile_0_2)
        # out
        buffer_0_2_c = aie.buffer(T.memref(M, N, T.i32()), tile_0_2)

        # input
        lock_0_1_read_in_a = aie.lock(tile_0_1, lock_id=0, init=1)
        lock_0_1_write_out_a = aie.lock(tile_0_1, lock_id=1, init=0)
        lock_0_1_read_in_b = aie.lock(tile_0_1, lock_id=2, init=1)
        lock_0_1_write_out_b = aie.lock(tile_0_1, lock_id=3, init=0)
        # output/returning
        lock_0_1_read_in_c = aie.lock(tile_0_1, lock_id=4, init=1)
        lock_0_1_write_out_c = aie.lock(tile_0_1, lock_id=5, init=0)

        lock_0_2_read_in_a = aie.lock(tile_0_2, lock_id=0, init=1)
        lock_0_2_use_a = aie.lock(tile_0_2, lock_id=1, init=0)
        lock_0_2_read_in_b = aie.lock(tile_0_2, lock_id=2, init=1)
        lock_0_2_use_b = aie.lock(tile_0_2, lock_id=3, init=0)
        lock_0_2_use_c = aie.lock(tile_0_2, lock_id=4, init=1)
        lock_0_2_write_out_c = aie.lock(tile_0_2, lock_id=5, init=0)

        # input flow
        # a
        aie.flow(tile_0_0, DMA, 0, tile_0_1, DMA, 0)
        aie.flow(tile_0_1, DMA, 0, tile_0_2, DMA, 0)
        # b
        aie.flow(tile_0_0, DMA, 1, tile_0_1, DMA, 1)
        aie.flow(tile_0_1, DMA, 1, tile_0_2, DMA, 1)
        # output flow
        aie.flow(tile_0_2, DMA, 0, tile_0_1, DMA, 2)
        aie.flow(tile_0_1, DMA, 2, tile_0_0, DMA, 0)

        @func.func(emit=True)
        def bobsyouruncle():
            # in A
            channel_index = 0
            col = 0
            ddr_id = 0
            bd_id = 0
            aiex.ipu.writebd_shimtile(
                bd_id,
                buffer_length=M * K,
                offset=0,
                ddr_id=ddr_id,
            )
            aiex.ipu.write32(MM2S, channel_index, col, bd_id)

            # in B
            channel_index = 1
            col = 0
            ddr_id = 1
            bd_id += 1
            aiex.ipu.writebd_shimtile(
                bd_id,
                buffer_length=K * N,
                offset=0,
                ddr_id=ddr_id,
            )
            aiex.ipu.write32(MM2S, channel_index, col, bd_id)

            # out C
            channel_index = 0
            col = 0
            ddr_id = 2
            bd_id += 1
            aiex.ipu.writebd_shimtile(
                bd_id,
                buffer_length=M * N,
                offset=0,
                ddr_id=ddr_id,
            )
            aiex.ipu.write32(S2MM, channel_index, col, bd_id)
            aiex.ipu.sync(
                channel=0,
                column=0,
                column_num=1,
                direction=0,
                row=0,
                row_num=1,
            )

        @aie.memtile_dma(tile_0_1)
        def memtile_dma_0_1():
            # input flow
            buffer_0_1_a = aie.buffer(T.memref(M, K, T.i32()), tile_0_1)
            buffer_0_1_b = aie.buffer(T.memref(K, N, T.i32()), tile_0_1)
            # output flow
            buffer_0_1_c = aie.buffer(T.memref(M, N, T.i32()), tile_0_1)

            @aie.dma(S2MM, 0)
            def dma1():
                aie.use_lock(lock_0_1_read_in_a, AcquireGreaterEqual)
                aie.dma_bd(buffer_0_1_a)
                aie.use_lock(lock_0_1_write_out_a, Release)

            @aie.dma(MM2S, 0, num_blocks=2)
            def dma2():
                aie.use_lock(lock_0_1_write_out_a, AcquireGreaterEqual)
                aie.dma_bd(buffer_0_1_a)
                aie.use_lock(lock_0_1_write_out_a, Release)

            @aie.another_bd(dma2)
            def dma2point5():
                aie.use_lock(lock_0_1_write_out_a, AcquireGreaterEqual)
                aie.dma_bd(buffer_0_1_a)
                aie.use_lock(lock_0_1_read_in_a, Release)

            @aie.dma(S2MM, 1)
            def dma3():
                aie.use_lock(lock_0_1_read_in_b, AcquireGreaterEqual)
                aie.dma_bd(buffer_0_1_b)
                aie.use_lock(lock_0_1_write_out_b, Release)

            @aie.dma(MM2S, 1)
            def dma4():
                aie.use_lock(lock_0_1_write_out_b, AcquireGreaterEqual)
                aie.dma_bd(buffer_0_1_b)
                aie.use_lock(lock_0_1_read_in_b, Release)

            # output flow
            @aie.dma(S2MM, 2)
            def dma5():
                aie.use_lock(lock_0_1_read_in_c, AcquireGreaterEqual)
                aie.dma_bd(buffer_0_1_c)
                aie.use_lock(lock_0_1_write_out_c, Release)

            @aie.dma(MM2S, 2)
            def dma6():
                aie.use_lock(lock_0_1_write_out_c, AcquireGreaterEqual)
                aie.dma_bd(buffer_0_1_c)
                aie.use_lock(lock_0_1_read_in_c, Release)

            aie.end()

        @aie.mem(tile_0_2)
        def mem_0_2():
            # input
            @aie.dma(S2MM, 0)
            def dma1():
                aie.use_lock(lock_0_2_read_in_a, AcquireGreaterEqual)
                aie.dma_bd(buffer_0_2_a)
                aie.use_lock(lock_0_2_use_a, Release)

            @aie.dma(S2MM, 1)
            def dma2():
                aie.use_lock(lock_0_2_read_in_b, AcquireGreaterEqual)
                aie.dma_bd(buffer_0_2_b)
                aie.use_lock(lock_0_2_use_b, Release)

            # output
            @aie.dma(MM2S, 0)
            def dma3():
                aie.use_lock(lock_0_2_write_out_c, AcquireGreaterEqual)
                aie.dma_bd(buffer_0_2_c)
                aie.use_lock(lock_0_2_use_c, Release)

            aie.end()

        @aie.core(tile_0_2)
        def core():
            # wait on both in and out to be ready
            # these have to be acge for some reason...
            aie.use_lock(lock_0_2_use_a, AcquireGreaterEqual)
            aie.use_lock(lock_0_2_use_b, AcquireGreaterEqual)
            aie.use_lock(lock_0_2_use_c, AcquireGreaterEqual)

            linalg_fill(arith.constant(0), outs=[buffer_0_2_c])
            matmul_i32_i32(buffer_0_2_a, buffer_0_2_b, buffer_0_2_c)

            aie.use_lock(lock_0_2_read_in_a, Release)
            aie.use_lock(lock_0_2_read_in_b, Release)
            aie.use_lock(lock_0_2_write_out_c, Release)

    mod_aie.finish()
    mod_aievec = ExplicitlyManagedModule()

    @builtin.module(attrs={"transform.target_tag": StringAttr.get("payload")})
    def payload():
        matmul_i32_i32.emit(force=True)

    @builtin.module(attrs={"transform.with_named_sequence": UnitAttr.get()})
    def mod_transform():
        @named_sequence("affine_unroll", [any_op_t()], [])
        def affine_unroll(target: any_op_t()):
            func = structured_match(any_op_t(), target, ops=["func.func"])
            new_func = apply_registered_pass(
                any_op_t(), func, "convert-linalg-to-affine-loops"
            )
            m = structured_match(any_op_t(), new_func, ops=["arith.addi"])
            loop = get_parent_op(pdl.op_t(), m, op_name="affine.for")
            # unroll inner loop
            # for i32 this has to be 8? something to do with 256 alignment for v16int32 loads...
            loop_unroll(loop, 8)

        @named_sequence("affine_super_vectorize", [any_op_t()], [])
        def super_vectorize(target: any_op_t()):
            func = structured_match(any_op_t(), target, ops=["func.func"])
            func = apply_registered_pass(
                any_op_t(),
                func,
                "affine-super-vectorize",
                # todo: smaller virtualvector (8)
                options="virtual-vector-size=16",
            )
            func = apply_registered_pass(any_op_t(), func, "affine-scalrep")
            func = apply_registered_pass(any_op_t(), func, "canonicalize")
            func = apply_registered_pass(any_op_t(), func, "cse")
            mod = apply_registered_pass(
                any_op_t(),
                target,
                "convert-vector-to-aievec",
                options="aie-target=aieml",
            )

    mod_aievec.finish()

    print(mod_aie)
    print(mod_aievec)

    affine_loops = run_pipeline(
        mod_aievec,
        Pipeline()
        .transform_interpreter(
            entry_point="affine_unroll",
            debug_payload_root_tag="payload",
        )
        .canonicalize()
        .cse(),
    )
    print(affine_loops)

    super_vec = run_pipeline(
        affine_loops,
        Pipeline()
        .transform_interpreter(
            entry_point="affine_super_vectorize",
            debug_payload_root_tag="payload",
        )
        .lower_affine(),
    )

    mod_aievec = find_ops(
        super_vec.operation,
        lambda x: "transform.target_tag" in x.attributes,
        single=True,
    )

    ipu_insts = compile_with_vectorization(mod_aie, mod_aievec)
    xclbin_path = make_xclbin(mod_aie)
    with FileLock("/tmp/ipu.lock"):
        setup_xclbin_firmware(xclbin_path)

        xclbin = XCLBin(xclbin_path, "MLIR_AIE")
        xclbin.load_ipu_instructions(ipu_insts)
        inps, outps = xclbin.mmap_buffers([(M, K), (K, N)], [(M, N)], np.int32)

        wrap_A = np.asarray(inps[0])
        wrap_B = np.asarray(inps[1])
        wrap_C = np.asarray(outps[0])

        A = np.random.randint(0, 10, (M, K), dtype=np.int32)
        B = np.random.randint(0, 10, (K, N), dtype=np.int32)
        # B = np.identity(M, dtype=np.int32)
        C = np.zeros((M, N), dtype=np.int32)

        np.copyto(wrap_A, A, casting="no")
        np.copyto(wrap_B, B, casting="no")
        np.copyto(wrap_C, C, casting="no")

        xclbin.sync_buffers_to_device()
        xclbin.run()
        print("Running kernel")
        xclbin.wait(30)
        xclbin.sync_buffers_from_device()

        if not np.array_equal(A @ B, wrap_C):
            with np.printoptions(threshold=sys.maxsize, linewidth=sys.maxsize):
                print(A @ B)
                print(wrap_C)
                assert False


# CHECK-LABEL: nonsquare_matrix_mult_vectorized_sugar
@construct_and_print_module
def nonsquare_matrix_mult_vectorized_sugar(module):
    mod_aie = ExplicitlyManagedModule()

    @aie.device(AIEDevice.ipu)
    def ipu():
        matmul_i32_i32.emit(decl=True)
        tile_0_0 = aie.tile(0, 0)
        tile_0_1 = aie.tile(0, 1)
        tile_0_2 = aie.tile(0, 2)

        # in
        buffer_0_2_a = aie.buffer(T.memref(M, K, T.i32()), tile_0_2)
        buffer_0_2_b = aie.buffer(T.memref(K, N, T.i32()), tile_0_2)
        # out
        buffer_0_2_c = aie.buffer(T.memref(M, N, T.i32()), tile_0_2)

        # input
        lock_0_1_read_in_a = aie.lock(tile_0_1, lock_id=0, init=1)
        lock_0_1_write_out_a = aie.lock(tile_0_1, lock_id=1, init=0)

        lock_0_2_read_in_a = aie.lock(tile_0_2, lock_id=0, init=1)
        lock_0_2_use_a = aie.lock(tile_0_2, lock_id=1, init=0)
        lock_0_2_read_in_b = aie.lock(tile_0_2, lock_id=2, init=1)
        lock_0_2_use_b = aie.lock(tile_0_2, lock_id=3, init=0)
        lock_0_2_use_c = aie.lock(tile_0_2, lock_id=4, init=1)
        lock_0_2_write_out_c = aie.lock(tile_0_2, lock_id=5, init=0)

        # input flow
        # a
        aie.flow(tile_0_0, DMA, 0, tile_0_1, DMA, 0)
        aie.flow(tile_0_1, DMA, 0, tile_0_2, DMA, 0)
        # b
        aie.flow(tile_0_0, DMA, 1, tile_0_1, DMA, 1)
        aie.flow(tile_0_1, DMA, 1, tile_0_2, DMA, 1)
        # output flow
        aie.flow(tile_0_2, DMA, 0, tile_0_1, DMA, 2)
        aie.flow(tile_0_1, DMA, 2, tile_0_0, DMA, 0)

        @func.func(emit=True)
        def bobsyouruncle():
            # in A
            channel_index = 0
            col = 0
            ddr_id = 0
            bd_id = 0
            aiex.ipu.writebd_shimtile(
                bd_id,
                buffer_length=M * K,
                offset=0,
                ddr_id=ddr_id,
            )
            aiex.ipu.write32(MM2S, channel_index, col, bd_id)

            # in B
            channel_index = 1
            col = 0
            ddr_id = 1
            bd_id += 1
            aiex.ipu.writebd_shimtile(
                bd_id,
                buffer_length=K * N,
                offset=0,
                ddr_id=ddr_id,
            )
            aiex.ipu.write32(MM2S, channel_index, col, bd_id)

            # out C
            channel_index = 0
            col = 0
            ddr_id = 2
            bd_id += 1
            aiex.ipu.writebd_shimtile(
                bd_id,
                buffer_length=M * N,
                offset=0,
                ddr_id=ddr_id,
            )
            aiex.ipu.write32(S2MM, channel_index, col, bd_id)
            aiex.ipu.sync(
                channel=0,
                column=0,
                column_num=1,
                direction=0,
                row=0,
                row_num=1,
            )

        @aie.memtile_dma(tile_0_1)
        def memtile_dma_0_1():
            # input flow
            buffer_0_1_a = aie.buffer(T.memref(M, K, T.i32()), tile_0_1)
            buffer_0_1_b = aie.buffer(T.memref(K, N, T.i32()), tile_0_1)
            # output flow
            buffer_0_1_c = aie.buffer(T.memref(M, N, T.i32()), tile_0_1)

            @aie.dma(S2MM, 0)
            def dma1():
                aiex.process_bd(lock_0_1_read_in_a, buffer_0_1_a, lock_0_1_write_out_a)

            @aie.dma(MM2S, 0, num_blocks=2)
            def dma2():
                aiex.process_bd(
                    lock_0_1_write_out_a, buffer_0_1_a, lock_0_1_write_out_a
                )

            @aie.another_bd(dma2)
            def dma2point5():
                aiex.process_bd(lock_0_1_write_out_a, buffer_0_1_a, lock_0_1_read_in_a)

            aiex.forward_bd(tile_0_1, 1, buffer_0_1_b)
            aiex.forward_bd(tile_0_1, 2, buffer_0_1_c)

            aie.end()

        @aie.mem(tile_0_2)
        def mem_0_2():
            # input
            @aie.dma(S2MM, 0)
            def dma1():
                aiex.process_bd(lock_0_2_read_in_a, buffer_0_2_a, lock_0_2_use_a)

            @aie.dma(S2MM, 1)
            def dma2():
                aiex.process_bd(lock_0_2_read_in_b, buffer_0_2_b, lock_0_2_use_b)

            # output
            @aie.dma(MM2S, 0)
            def dma3():
                aiex.process_bd(lock_0_2_write_out_c, buffer_0_2_c, lock_0_2_use_c)

            aie.end()

        @aie.core(tile_0_2)
        def core():
            with (
                aiex.hold_lock(lock_0_2_use_a, lock_0_2_read_in_a),
                aiex.hold_lock(lock_0_2_use_b, lock_0_2_read_in_b),
                aiex.hold_lock(lock_0_2_use_c, lock_0_2_write_out_c),
            ):
                linalg_fill(arith.constant(0), outs=[buffer_0_2_c])
                matmul_i32_i32(buffer_0_2_a, buffer_0_2_b, buffer_0_2_c)

    mod_aie.finish()
    mod_aievec = ExplicitlyManagedModule()

    @builtin.module(attrs={"transform.target_tag": StringAttr.get("payload")})
    def payload():
        matmul_i32_i32.emit(force=True)

    @builtin.module(attrs={"transform.with_named_sequence": UnitAttr.get()})
    def mod_transform():
        @named_sequence("affine_unroll", [any_op_t()], [])
        def affine_unroll(target: any_op_t()):
            func = structured_match(any_op_t(), target, ops=["func.func"])
            new_func = apply_registered_pass(
                any_op_t(), func, "convert-linalg-to-affine-loops"
            )
            m = structured_match(any_op_t(), new_func, ops=["arith.addi"])
            loop = get_parent_op(pdl.op_t(), m, op_name="affine.for")
            # unroll inner loop
            # for i32 this has to be 8? something to do with 256 alignment for v16int32 loads...
            loop_unroll(loop, 8)

        @named_sequence("affine_super_vectorize", [any_op_t()], [])
        def super_vectorize(target: any_op_t()):
            func = structured_match(any_op_t(), target, ops=["func.func"])
            func = apply_registered_pass(
                any_op_t(),
                func,
                "affine-super-vectorize",
                # todo: smaller virtualvector (8)
                options="virtual-vector-size=16",
            )
            func = apply_registered_pass(any_op_t(), func, "affine-scalrep")
            func = apply_registered_pass(any_op_t(), func, "canonicalize")
            func = apply_registered_pass(any_op_t(), func, "cse")
            mod = apply_registered_pass(
                any_op_t(),
                target,
                "convert-vector-to-aievec",
                options="aie-target=aieml",
            )

    mod_aievec.finish()

    print(mod_aie)
    print(mod_aievec)

    affine_loops = run_pipeline(
        mod_aievec,
        Pipeline()
        .transform_interpreter(
            entry_point="affine_unroll",
            debug_payload_root_tag="payload",
        )
        .canonicalize()
        .cse(),
    )
    print(affine_loops)

    super_vec = run_pipeline(
        affine_loops,
        Pipeline()
        .transform_interpreter(
            entry_point="affine_super_vectorize",
            debug_payload_root_tag="payload",
        )
        .lower_affine(),
    )

    mod_aievec = find_ops(
        super_vec.operation,
        lambda x: "transform.target_tag" in x.attributes,
        single=True,
    )
    ipu_insts = compile_with_vectorization(mod_aie, mod_aievec)
    xclbin_path = make_xclbin(mod_aie)
    with FileLock("/tmp/ipu.lock"):
        setup_xclbin_firmware(xclbin_path)

        xclbin = XCLBin(xclbin_path, "MLIR_AIE")
        xclbin.load_ipu_instructions(ipu_insts)
        inps, outps = xclbin.mmap_buffers([(M, K), (K, N)], [(M, N)], np.int32)

        wrap_A = np.asarray(inps[0])
        wrap_B = np.asarray(inps[1])
        wrap_C = np.asarray(outps[0])

        A = np.random.randint(0, 10, (M, K), dtype=np.int32)
        B = np.random.randint(0, 10, (K, N), dtype=np.int32)
        # B = np.identity(M, dtype=np.int32)
        C = np.zeros((M, N), dtype=np.int32)

        np.copyto(wrap_A, A, casting="no")
        np.copyto(wrap_B, B, casting="no")
        np.copyto(wrap_C, C, casting="no")

        xclbin.sync_buffers_to_device()
        xclbin.run()
        print("Running kernel")
        xclbin.wait(30)
        xclbin.sync_buffers_from_device()

        if not np.array_equal(A @ B, wrap_C):
            with np.printoptions(threshold=sys.maxsize, linewidth=sys.maxsize):
                print(A @ B)
                print(wrap_C)
                assert False
