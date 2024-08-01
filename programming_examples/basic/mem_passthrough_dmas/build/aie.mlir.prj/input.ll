; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"
target triple = "aie2"

@in_cons_buff_0 = external global [4096 x i32]
@out_cons = external global [4096 x i32]
@out = external global [4096 x i32]
@in_cons = external global [4096 x i32]
@in = external global [4096 x i32]
@blockwrite_data_0 = private constant [8 x i32] [i32 4096, i32 0, i32 0, i32 0, i32 -2147483648, i32 0, i32 0, i32 33554432]
@blockwrite_data_1 = private constant [8 x i32] [i32 4096, i32 0, i32 0, i32 0, i32 -2147483648, i32 0, i32 0, i32 33554432]
@blockwrite_data_2 = private constant [8 x i32] [i32 4096, i32 524288, i32 0, i32 0, i32 0, i32 0, i32 0, i32 -2126381248]
@blockwrite_data_3 = private constant [8 x i32] [i32 4096, i32 1572864, i32 0, i32 0, i32 0, i32 0, i32 0, i32 -2126381247]

declare void @debug_i32(i32)

declare void @llvm.aie2.put.ms(i32, i32)

declare { i32, i32 } @llvm.aie2.get.ss()

declare void @llvm.aie2.mcd.write.vec(<16 x i32>, i32)

declare <16 x i32> @llvm.aie2.scd.read.vec(i32)

declare void @llvm.aie2.acquire(i32, i32)

declare void @llvm.aie2.release(i32, i32)

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
