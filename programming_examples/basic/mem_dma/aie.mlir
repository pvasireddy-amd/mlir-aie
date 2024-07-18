
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
      aiex.npu.writebd_memtile {bd_id = 0 : i32, buffer_length = 4096 : i32, buffer_offset = 0 : i32, column = 0 : i32, row = 1: i32, column_num = 1 : i32, d0_size = 0 : i32, d0_stride = 0 : i32, d1_size = 0 : i32, d1_stride = 0 : i32, d2_stride = 0 : i32, ddr_id = 0 : i32, enable_packet = 0 : i32, iteration_current = 0 : i32, iteration_size = 0 : i32, iteration_stride = 0 : i32, lock_acq_enable = 1 : i32, lock_acq_id = 64 : i32, lock_acq_val = 127 : i32, lock_rel_id = 65 : i32, lock_rel_val = 1 : i32, next_bd = 0 : i32, out_of_order_id = 0 : i32, packet_id = 0 : i32, packet_type = 0 : i32, use_next_bd = 1 : i32, valid_bd = 1 : i32}
      aiex.npu.write32 {address = 656900 : ui32, column = 0 : i32, row = 1 : i32, value = 0 : ui32}
      aiex.npu.writebd_memtile {bd_id = 1 : i32, buffer_length = 4096 : i32, buffer_offset = 0 : i32, column = 0 : i32, row = 1: i32, column_num = 1 : i32, d0_size = 0 : i32, d0_stride = 0 : i32, d1_size = 0 : i32, d1_stride = 0 : i32, d2_stride = 0 : i32, ddr_id = 0 : i32, enable_packet = 0 : i32, iteration_current = 0 : i32, iteration_size = 0 : i32, iteration_stride = 0 : i32, lock_acq_enable = 1 : i32, lock_acq_id = 65 : i32, lock_acq_val = 127 : i32, lock_rel_id = 64 : i32, lock_rel_val = 1 : i32, next_bd = 1 : i32, out_of_order_id = 0 : i32, packet_id = 0 : i32, packet_type = 0 : i32, use_next_bd = 1 : i32, valid_bd = 1 : i32}
      aiex.npu.write32 {address = 656948 : ui32, column = 0 : i32, row = 1 : i32, value = 1 : ui32}
      aiex.npu.writebd_shimtile {bd_id = 1 : i32, buffer_length = 4096 : i32, buffer_offset = 0 : i32, column = 0 : i32, row = 0: i32, column_num = 1 : i32, d0_size = 0 : i32, d0_stride = 0 : i32, d1_size = 0 : i32, d1_stride = 0 : i32, d2_stride = 0 : i32, ddr_id = 0 : i32, enable_packet = 0 : i32, iteration_current = 0 : i32, iteration_size = 0 : i32, iteration_stride = 0 : i32, lock_acq_enable = 0 : i32, lock_acq_id = 0 : i32, lock_acq_val = 0 : i32, lock_rel_id = 0 : i32, lock_rel_val = 0 : i32, next_bd = 0 : i32, out_of_order_id = 0 : i32, packet_id = 0 : i32, packet_type = 0 : i32, use_next_bd = 0 : i32, valid_bd = 1 : i32}
      aiex.npu.write32 {address = 119316 : ui32, column = 0 : i32, row = 0 : i32, value = 1 : ui32}
      aiex.npu.sync {channel = 0 : i32, column = 0 : i32, column_num = 1 : i32, direction = 0 : i32, row = 0 : i32, row_num = 1 : i32}
      return
    }
  }
}

// [ 4152.232353] UTL MSG: [RAD DEBUG] mem_dma_bd_0_0_val: 0x1000
// [ 4152.232512] UTL MSG: [RAD DEBUG] mem_dma_bd_0_1_val: 0x80000
// [ 4152.232636] UTL MSG: [RAD DEBUG] mem_dma_bd_0_2_val: 0x0
// [ 4152.232770] UTL MSG: [RAD DEBUG] mem_dma_bd_0_3_val: 0x0
// [ 4152.232905] UTL MSG: [RAD DEBUG] mem_dma_bd_0_4_val: 0x0
// [ 4152.233038] UTL MSG: [RAD DEBUG] mem_dma_bd_0_5_val: 0x0
// [ 4152.233175] UTL MSG: [RAD DEBUG] mem_dma_bd_0_6_val: 0x0
// [ 4152.233328] UTL MSG: [RAD DEBUG] mem_dma_bd_0_7_val: 0x141ff40
// [ 4152.233473] UTL MSG: [RAD DEBUG] mem_dma_bd_1_0_val: 0x1000
// [ 4152.233619] UTL MSG: [RAD DEBUG] mem_dma_bd_1_1_val: 0x180000
// [ 4152.233752] UTL MSG: [RAD DEBUG] mem_dma_bd_1_2_val: 0x0
// [ 4152.233891] UTL MSG: [RAD DEBUG] mem_dma_bd_1_3_val: 0x0
// [ 4152.234024] UTL MSG: [RAD DEBUG] mem_dma_bd_1_4_val: 0x0
// [ 4152.234177] UTL MSG: [RAD DEBUG] mem_dma_bd_1_5_val: 0x0
// [ 4152.234294] UTL MSG: [RAD DEBUG] mem_dma_bd_1_6_val: 0x0
// [ 4152.234465] UTL MSG: [RAD DEBUG] mem_dma_bd_1_7_val: 0x140ff41