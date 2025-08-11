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

void lutParallelLookupLine(int8_t *in, int8_t *out, int32_t lineWidth) {

  using lut_type = ::aie::lut<4, int8_t, int8_t>;
  lut_type lut(num_entries, int8_lut_ab, int8_lut_cd);
  aie::parallel_lookup<int8_t, lut_type, aie::lut_oor_policy::truncate> lookup(lut, 0);

  const int vector_size = 16;
  ::aie::vector<int8_t, vector_size> lane_offsets = ::aie::broadcast<int8_t, vector_size> (0);
  
  for(int i =0; i<15; i++){
    lane_offsets[i] = i;
  }

  for (int i =0; i < lineWidth; i += vector_size) {
    ::aie::vector<int8_t, vector_size> base = ::aie::broadcast<int8_t, vector_size>(static_cast<int8_t>(i));
    ::aie::vector<int8_t, vector_size> idx_vec = ::aie::add(base, lane_offsets);
    ::aie::vector<int8_t, vector_size> vout = lookup.fetch(idx_vec);
    ::aie::store_v(out + i, vout);
  }
}

} // extern "C"