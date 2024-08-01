module attributes {llvm.target_triple = "aie2"} {
  llvm.mlir.global external @in_cons_buff_0() {addr_space = 0 : i32} : !llvm.array<4096 x i32>
  llvm.func @debug_i32(i32) attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.put.ms(i32, i32) attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.get.ss() -> !llvm.struct<(i32, i32)> attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.mcd.write.vec(vector<16xi32>, i32) attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.scd.read.vec(i32) -> vector<16xi32> attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.acquire(i32, i32) attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.release(i32, i32) attributes {sym_visibility = "private"}
  llvm.mlir.global external @out_cons() {addr_space = 0 : i32} : !llvm.array<4096 x i32>
  llvm.mlir.global external @out() {addr_space = 0 : i32} : !llvm.array<4096 x i32>
  llvm.mlir.global external @in_cons() {addr_space = 0 : i32} : !llvm.array<4096 x i32>
  llvm.mlir.global external @in() {addr_space = 0 : i32} : !llvm.array<4096 x i32>
  llvm.mlir.global private constant @blockwrite_data_0(dense<[4096, 0, 0, 0, -2147483648, 0, 0, 33554432]> : tensor<8xi32>) {addr_space = 0 : i32} : !llvm.array<8 x i32>
  llvm.mlir.global private constant @blockwrite_data_1(dense<[4096, 0, 0, 0, -2147483648, 0, 0, 33554432]> : tensor<8xi32>) {addr_space = 0 : i32} : !llvm.array<8 x i32>
  llvm.mlir.global private constant @blockwrite_data_2(dense<[4096, 524288, 0, 0, 0, 0, 0, -2126381248]> : tensor<8xi32>) {addr_space = 0 : i32} : !llvm.array<8 x i32>
  llvm.mlir.global private constant @blockwrite_data_3(dense<[4096, 1572864, 0, 0, 0, 0, 0, -2126381247]> : tensor<8xi32>) {addr_space = 0 : i32} : !llvm.array<8 x i32>
}

