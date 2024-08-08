module {
  aie.device(npu1_1col) {
    memref.global "public" @out_cons : memref<1024xi32>
    memref.global "public" @out : memref<1024xi32>
    memref.global "public" @in_cons : memref<1024xi32>
    memref.global "public" @in : memref<1024xi32>
    %tile_0_0 = aie.tile(0, 0)
    %tile_0_1 = aie.tile(0, 1)
    %in_cons_buff_0 = aie.buffer(%tile_0_1) {address = 0 : i32, mem_bank = 0 : i32, sym_name = "in_cons_buff_0"} : memref<1024xi32> 
    %in_cons_buff_1 = aie.buffer(%tile_0_1) {address = 4096 : i32, mem_bank = 0 : i32, sym_name = "in_cons_buff_1"} : memref<1024xi32> 
    aie.flow(%tile_0_0, DMA : 0, %tile_0_1, DMA : 0)
    aie.flow(%tile_0_1, DMA : 0, %tile_0_0, DMA : 0)
    aie.shim_dma_allocation @in(MM2S, 0, 0, 0)
    aie.shim_dma_allocation @in(S2MM, 0, 0, 1)
    aie.shim_dma_allocation @out(MM2S, 0, 0, 1)
    aie.shim_dma_allocation @out(S2MM, 0, 0, 0)
    memref.global "private" constant @blockwrite_data_0 : memref<8xi32> = dense<[4096, 0, 0, 0, 0, 0, 0, -2147483648]>
    memref.global "private" constant @blockwrite_data_1 : memref<8xi32> = dense<[4096, 0, 0, 0, -2147483648, 0, 0, 33554432]>
    memref.global "private" constant @blockwrite_data_2 : memref<8xi32> = dense<[4096, 0, 0, 0, 0, 0, 0, -2147483648]>
    memref.global "private" constant @blockwrite_data_3 : memref<8xi32> = dense<[4096, 0, 0, 0, -2147483648, 0, 0, 33554432]>
    aiex.runtime_sequence(%arg0: memref<4096xi32>, %arg1: memref<4096xi32>, %arg2: memref<4096xi32>) {
      %0 = memref.get_global @blockwrite_data_0 : memref<8xi32>
      aiex.npu.blockwrite(%0) {address = 1703936 : ui32} : memref<8xi32>
      aiex.npu.write32 {address = 656948 : ui32, column = 0 : i32, row = 0 : i32, value = 0 : ui32}
      %1 = memref.get_global @blockwrite_data_1 : memref<8xi32>
      aiex.npu.blockwrite(%1) {address = 118784 : ui32} : memref<8xi32>
      aiex.npu.address_patch {addr = 118788 : ui32, arg_idx = 2 : i32, arg_plus = 0 : i32}
      aiex.npu.write32 {address = 119316 : ui32, column = 0 : i32, row = 0 : i32, value = 0 : ui32}
      %2 = memref.get_global @blockwrite_data_2 : memref<8xi32>
      aiex.npu.blockwrite(%2) {address = 1703968 : ui32} : memref<8xi32>
      aiex.npu.write32 {address = 656948 : ui32, column = 0 : i32, row = 0 : i32, value = 1 : ui32}
      %3 = memref.get_global @blockwrite_data_3 : memref<8xi32>
      aiex.npu.blockwrite(%3) {address = 118816 : ui32} : memref<8xi32>
      aiex.npu.address_patch {addr = 118820 : ui32, arg_idx = 0 : i32, arg_plus = 0 : i32}
      aiex.npu.write32 {address = 119316 : ui32, column = 0 : i32, row = 0 : i32, value = 1 : ui32}
      aiex.npu.sync {channel = 0 : i32, column = 0 : i32, column_num = 1 : i32, direction = 0 : i32, row = 0 : i32, row_num = 1 : i32}
    }
  }
}

