
      // aiex.npu.writebd_memtile {bd_id = 0 : i32, buffer_length = 4096 : i32, buffer_offset = 0 : i32, column = 0 : i32, column_num = 1 : i32, d0_size = 0 : i32, d0_stride = 0 : i32, d1_size = 0 : i32, d1_stride = 0 : i32, d2_stride = 0 : i32, ddr_id = 0 : i32, enable_packet = 0 : i32, iteration_current = 0 : i32, iteration_size = 0 : i32, iteration_stride = 0 : i32, lock_acq_enable = 1 : i32, lock_acq_id = 64 : i32, lock_acq_val = 127 : i32, lock_rel_id = 65 : i32, lock_rel_val = 1 : i32, next_bd = 0 : i32, out_of_order_id = 0 : i32, packet_id = 0 : i32, packet_type = 0 : i32, use_next_bd = 1 : i32, valid_bd = 1 : i32}
      // aiex.npu.write32 {address = 656900 : ui32, column = 0 : i32, row = 1 : i32, value = 0 : ui32}
      // aiex.npu.writebd_memtile {bd_id = 1 : i32, buffer_length = 4096 : i32, buffer_offset = 0 : i32, column = 0 : i32, column_num = 1 : i32, d0_size = 0 : i32, d0_stride = 0 : i32, d1_size = 0 : i32, d1_stride = 0 : i32, d2_stride = 0 : i32, ddr_id = 0 : i32, enable_packet = 0 : i32, iteration_current = 0 : i32, iteration_size = 0 : i32, iteration_stride = 0 : i32, lock_acq_enable = 1 : i32, lock_acq_id = 65 : i32, lock_acq_val = 127 : i32, lock_rel_id = 64 : i32, lock_rel_val = 1 : i32, next_bd = 1 : i32, out_of_order_id = 0 : i32, packet_id = 0 : i32, packet_type = 0 : i32, use_next_bd = 1 : i32, valid_bd = 1 : i32}
      // aiex.npu.write32 {address = 656948 : ui32, column = 0 : i32, row = 1 : i32, value = 1 : ui32}

module {
  aie.device(npu1_1col) {
    memref.global "public" @out_cons : memref<4096xi32>
    memref.global "public" @out : memref<4096xi32>
    memref.global "public" @in_cons : memref<4096xi32>
    memref.global "public" @in : memref<4096xi32>
    %tile_0_0 = aie.tile(0, 0)
    %tile_0_1 = aie.tile(0, 1)
    %out_cons_prod_lock = aie.lock(%tile_0_0, 2) {init = 0 : i32, sym_name = "out_cons_prod_lock"}
    %out_cons_cons_lock = aie.lock(%tile_0_0, 3) {init = 0 : i32, sym_name = "out_cons_cons_lock"}
    %in_cons_buff_0 = aie.buffer(%tile_0_1) {address = 0 : i32, mem_bank = 0 : i32, sym_name = "in_cons_buff_0"} : memref<4096xi32> 
    %in_cons_prod_lock = aie.lock(%tile_0_1, 0) {init = 1 : i32, sym_name = "in_cons_prod_lock"}
    %in_cons_cons_lock = aie.lock(%tile_0_1, 1) {init = 0 : i32, sym_name = "in_cons_cons_lock"}
    %in_prod_lock = aie.lock(%tile_0_0, 0) {init = 0 : i32, sym_name = "in_prod_lock"}
    %in_cons_lock = aie.lock(%tile_0_0, 1) {init = 0 : i32, sym_name = "in_cons_lock"}
    aie.flow(%tile_0_0, DMA : 0, %tile_0_1, DMA : 0)
    aie.flow(%tile_0_1, DMA : 0, %tile_0_0, DMA : 0)
    aie.shim_dma_allocation @in(MM2S, 0, 0, 0)
    func.func @sequence(%arg0: memref<4096xi32>, %arg1: memref<4096xi32>, %arg2: memref<4096xi32>) {
      aiex.npu.writebd_shimtile {bd_id = 0 : i32, buffer_length = 4096 : i32, buffer_offset = 0 : i32, column = 0 : i32, row = 0: i32, column_num = 1 : i32, d0_size = 0 : i32, d0_stride = 0 : i32, d1_size = 0 : i32, d1_stride = 0 : i32, d2_stride = 0 : i32, ddr_id = 2 : i32, enable_packet = 0 : i32, iteration_current = 0 : i32, iteration_size = 0 : i32, iteration_stride = 0 : i32, lock_acq_enable = 0 : i32, lock_acq_id = 0 : i32, lock_acq_val = 0 : i32, lock_rel_id = 0 : i32, lock_rel_val = 0 : i32, next_bd = 0 : i32, out_of_order_id = 0 : i32, packet_id = 0 : i32, packet_type = 0 : i32, use_next_bd = 0 : i32, valid_bd = 1 : i32}
      aiex.npu.write32 {address = 119300 : ui32, column = 0 : i32, row = 0 : i32, value = 2147483648 : ui32}
      // aiex.npu.writebd_memtile {bd_id = 0 : i32, buffer_length = 4096 : i32, buffer_offset = 0 : i32, column = 0 : i32, row = 1: i32, column_num = 1 : i32, d0_size = 0 : i32, d0_stride = 0 : i32, d1_size = 0 : i32, d1_stride = 0 : i32, d2_stride = 0 : i32, ddr_id = 0 : i32, enable_packet = 0 : i32, iteration_current = 0 : i32, iteration_size = 0 : i32, iteration_stride = 0 : i32, lock_acq_enable = 1 : i32, lock_acq_id = 64 : i32, lock_acq_val = 127 : i32, lock_rel_id = 65 : i32, lock_rel_val = 1 : i32, next_bd = 0 : i32, out_of_order_id = 0 : i32, packet_id = 0 : i32, packet_type = 0 : i32, use_next_bd = 1 : i32, valid_bd = 1 : i32}
      // aiex.npu.write32 {address = 656900 : ui32, column = 0 : i32, row = 1 : i32, value = 0 : ui32}
      // aiex.npu.writebd_memtile {bd_id = 1 : i32, buffer_length = 4096 : i32, buffer_offset = 0 : i32, column = 0 : i32, row = 1: i32, column_num = 1 : i32, d0_size = 0 : i32, d0_stride = 0 : i32, d1_size = 0 : i32, d1_stride = 0 : i32, d2_stride = 0 : i32, ddr_id = 0 : i32, enable_packet = 0 : i32, iteration_current = 0 : i32, iteration_size = 0 : i32, iteration_stride = 0 : i32, lock_acq_enable = 1 : i32, lock_acq_id = 65 : i32, lock_acq_val = 127 : i32, lock_rel_id = 64 : i32, lock_rel_val = 1 : i32, next_bd = 1 : i32, out_of_order_id = 0 : i32, packet_id = 0 : i32, packet_type = 0 : i32, use_next_bd = 1 : i32, valid_bd = 1 : i32}
      // aiex.npu.write32 {address = 656948 : ui32, column = 0 : i32, row = 1 : i32, value = 1 : ui32}
       aiex.npu.write32 {address = 655360 : ui32, column = 0 : i32, row = 1 : i32, value = 4096 : ui32}
       aiex.npu.write32 {address = 655364 : ui32, column = 0 : i32, row = 1 : i32, value = 524288 : ui32}
       aiex.npu.write32 {address = 655368 : ui32, column = 0 : i32, row = 1 : i32, value = 0 : ui32}
       aiex.npu.write32 {address = 655372 : ui32, column = 0 : i32, row = 1 : i32, value = 0 : ui32}
       aiex.npu.write32 {address = 655376 : ui32, column = 0 : i32, row = 1 : i32, value = 0 : ui32}
       aiex.npu.write32 {address = 655380 : ui32, column = 0 : i32, row = 1 : i32, value = 0 : ui32}
       aiex.npu.write32 {address = 655384 : ui32, column = 0 : i32, row = 1 : i32, value = 0 : ui32}
       aiex.npu.write32 {address = 655388 : ui32, column = 0 : i32, row = 1 : i32, value = 2168586048 : ui32} //2168586048 = 0x8141ff40; reg = 141ff40
       aiex.npu.write32 {address = 656900 : ui32, column = 0 : i32, row = 1 : i32, value = 2147483648 : ui32}

       aiex.npu.write32 {address = 655392 : ui32, column = 0 : i32, row = 1 : i32, value = 4096 : ui32}
       aiex.npu.write32 {address = 655396 : ui32, column = 0 : i32, row = 1 : i32, value = 1572864 : ui32}
       aiex.npu.write32 {address = 655400 : ui32, column = 0 : i32, row = 1 : i32, value = 0 : ui32}
       aiex.npu.write32 {address = 655404 : ui32, column = 0 : i32, row = 1 : i32, value = 0 : ui32}
       aiex.npu.write32 {address = 655408 : ui32, column = 0 : i32, row = 1 : i32, value = 0 : ui32}
       aiex.npu.write32 {address = 655412 : ui32, column = 0 : i32, row = 1 : i32, value = 0 : ui32}
       aiex.npu.write32 {address = 655416 : ui32, column = 0 : i32, row = 1 : i32, value = 0 : ui32}
       aiex.npu.write32 {address = 656420 : ui32, column = 0 : i32, row = 1 : i32, value = 2168520513 : ui32} //2168520513 = 0x8140ff41; reg = 140ff41
       aiex.npu.write32 {address = 656948 : ui32, column = 0 : i32, row = 1 : i32, value = 1 : ui32}
      aiex.npu.sync {channel = 0 : i32, column = 0 : i32, column_num = 1 : i32, direction = 0 : i32, row = 1 : i32, row_num = 1 : i32}

      aiex.npu.writebd_shimtile {bd_id = 1 : i32, buffer_length = 4096 : i32, buffer_offset = 0 : i32, column = 0 : i32, row = 0: i32, column_num = 1 : i32, d0_size = 0 : i32, d0_stride = 0 : i32, d1_size = 0 : i32, d1_stride = 0 : i32, d2_stride = 0 : i32, ddr_id = 0 : i32, enable_packet = 0 : i32, iteration_current = 0 : i32, iteration_size = 0 : i32, iteration_stride = 0 : i32, lock_acq_enable = 0 : i32, lock_acq_id = 0 : i32, lock_acq_val = 0 : i32, lock_rel_id = 0 : i32, lock_rel_val = 0 : i32, next_bd = 0 : i32, out_of_order_id = 0 : i32, packet_id = 0 : i32, packet_type = 0 : i32, use_next_bd = 0 : i32, valid_bd = 1 : i32}
      aiex.npu.write32 {address = 119316 : ui32, column = 0 : i32, row = 0 : i32, value = 1 : ui32}
      aiex.npu.sync {channel = 0 : i32, column = 0 : i32, column_num = 1 : i32, direction = 0 : i32, row = 0 : i32, row_num = 1 : i32}
      return
    }
  }
}

