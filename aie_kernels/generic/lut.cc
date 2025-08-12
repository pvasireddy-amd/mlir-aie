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
  using lut_type = aie::lut<4, uint8_t, uint8_t>;
  lut_type lut(num_entries_32t, int32_lut_ab,
                              int32_lut_cd);
  aie::parallel_lookup<uint32, lut_type, aie::lut_oor_policy::truncate>
      lookup(lut, step);

  const int vector_size = 16;
  ::aie::vector<uint32_t, vector_size> lane_offsets = ::aie::broadcast<uint32_t, vector_size> (0);

  // This is done to not worry about alignment and copying
  for(int i =0; i<vector_size; i+=2){
    lane_offsets[i] = i ;
    lane_offsets[i+1] = i ;
  }

  for (int i =0; i < lineWidth; i += vector_size) {
  // Indexing into LUT
    ::aie::vector<uint32_t, vector_size> base = ::aie::broadcast<uint32_t, vector_size>(static_cast<uint32_t>(i));
    ::aie::vector<uint32_t, vector_size> idx_vec = ::aie::add(base, lane_offsets);

    // Method 1:
    
    // Load a 32-bit value from LUT
    auto vout_raw = lookup.fetch(idx_vec);
    // Need explicit cast to 8 bits
    ::aie::vector<uint8_t, vector_size> vout;
    // Only takes lower 8 bits
    for (int j = 0; j < vector_size; ++j) {
      vout[j] = static_cast<uint8_t>(vout_raw[j]);
    }

    // Method 2:
    ::aie::vector<uint8_t, vector_size> vout = lookup.fetch(idx_vec);


    // Store as 8-bit value
    ::aie::store_v(out + i, vout);
  }

  // Reinterpret the vector: load int32 input and store int8 output
  // Input 0 becomes : outputs: 0, 0, 0, 0
  // Input 1 becomes : outputs: 1, 0, 0, 0
  // Input 2 becomes : outputs: 2, 0, 0, 0
  // Input 3 becomes : outputs: 3, 0, 0, 0 and so on..
  //
  // const int vector_size = 16;
  // for (int i = 0; i < lineWidth; i += vector_size) {
  //   ::aie::vector<uint32_t, vector_size> v_in = ::aie::load_v(in + i);
  //   v64uint8 *restrict outPtr = (v64uint8 *)(out + i * sizeof(uint32_t));
  //   v64uint8 *restrict inPtr = (v64uint8 *)(in + i);
  //   *outPtr = *inPtr;
  // }
}

} // extern "C"