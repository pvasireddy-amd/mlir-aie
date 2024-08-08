module attributes {llvm.target_triple = "aie2"} {
  llvm.mlir.global external @in_cons_buff_1() {addr_space = 0 : i32} : !llvm.array<1024 x i32>
  llvm.mlir.global external @in_cons_buff_0() {addr_space = 0 : i32} : !llvm.array<1024 x i32>
  llvm.func @debug_i32(i32) attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.put.ms(i32, i32) attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.get.ss() -> !llvm.struct<(i32, i32)> attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.mcd.write.vec(vector<16xi32>, i32) attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.scd.read.vec(i32) -> vector<16xi32> attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.acquire(i32, i32) attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.release(i32, i32) attributes {sym_visibility = "private"}
  llvm.mlir.global external @out_cons() {addr_space = 0 : i32} : !llvm.array<1024 x i32>
  llvm.mlir.global external @out() {addr_space = 0 : i32} : !llvm.array<1024 x i32>
  llvm.mlir.global external @in_cons() {addr_space = 0 : i32} : !llvm.array<1024 x i32>
  llvm.mlir.global external @in() {addr_space = 0 : i32} : !llvm.array<1024 x i32>
}

