//===- lut.cc ---------------------------------------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// Copyright (C) 2025, Advanced Micro Devices, Inc.
//
//===----------------------------------------------------------------------===//

#define NOCPP

#include <stdint.h>
#include <stdlib.h>

#include "../aie_kernel_utils.h"
#include <aie_api/aie.hpp>
#include "lut_int8.h"

extern "C" {

void lutParallelLookupLine(uint32_t *in, uint8_t *out, int32_t lineWidth) {
  const int step = 0;
  using lut_type = aie::lut<4, uint32_t, uint32_t>;
  lut_type lut(num_entries_32t, int32_lut_ab, int32_lut_cd);
  aie::parallel_lookup<uint32, lut_type, aie::lut_oor_policy::truncate> lookup(
      lut, step);

  const int vector_size = 16;
  ::aie::vector<uint32_t, vector_size> lane_offsets =
      ::aie::broadcast<uint32_t, vector_size>(0);

  for (int i = 0; i < vector_size; i += 2) {
    lane_offsets[i] = i;
    lane_offsets[i + 1] = i;
  }

  // Each input value produces 4 output values (since 32-bit input, 8-bit
  // output, 128 in -> 512 out) Input: 128 values * 32-bit = 512 bytes Output:
  // 512 values * 8-bit = 512=bytes
  for (int i = 0; i < lineWidth; i += vector_size) {
    ::aie::vector<uint32_t, vector_size> base = ::aie::broadcast<uint32_t, vector_size>(static_cast<uint32_t>(i));
    ::aie::vector<uint32_t, vector_size> idx_vec = ::aie::add(base, lane_offsets);

    // N=16 32-bit values : v16uint32
    ::aie::vector<uint32_t, vector_size> vout = lookup.fetch(idx_vec);

    // Method 1:
    // Convert each 32-bit value to 4 8-bit values and
    // store in a 8-bit vector of size 4*N = 64 values : v64uint8
    v64uint8 vout8 = *(v64uint8 *)&vout;
    v64uint8 *restrict outPtr = (v64uint8 *)(out + i * 4);
    *outPtr = vout8;

    // Method 2: 
    // ::aie::vector<uint8_t, vector_size * 4> vout8;
    // for (int j = 0; j < vector_size; ++j) {
    //   uint32_t val = vout[j];
    //   vout8[j * 4 + 0] = static_cast<uint8_t>(val & 0xFF);
    //   vout8[j * 4 + 1] = static_cast<uint8_t>((val >> 8) & 0xFF);
    //   vout8[j * 4 + 2] = static_cast<uint8_t>((val >> 16) & 0xFF);
    //   vout8[j * 4 + 3] = static_cast<uint8_t>((val >> 24) & 0xFF);
    // }
    // ::aie::store_v(out + i * 4, vout8);
  }
}

} // extern "C"