//===- test.cpp -------------------------------------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// Copyright (C) 2023, Advanced Micro Devices, Inc.
//
//===----------------------------------------------------------------------===//

#include "xrt_test_wrapper.h"
#include <cstdint>

//*****************************************************************************
// Modify this section to customize buffer datatypes, initialization functions,
// and verify function. The other place to reconfigure your design is the
// Makefile.
//*****************************************************************************

#ifndef DATATYPES_USING_DEFINED
#define DATATYPES_USING_DEFINED
// ------------------------------------------------------
// Configure this to match your buffer data type
// ------------------------------------------------------
using DATATYPE_IN1 = std::uint32_t;
using DATATYPE_OUT = std::uint8_t;
#endif

// Initialize Input buffer 1
void initialize_bufIn1(DATATYPE_IN1 *bufIn1, int SIZE) {
  for (int i = 0; i < SIZE; i++)
    bufIn1[i] = i;
}

// Initialize Output buffer
void initialize_bufOut(DATATYPE_OUT *bufOut, int SIZE) {
  memset(bufOut, 0, SIZE * sizeof(DATATYPE_IN1));
}

// Functional correctness verifyer
int verify_passthrough_kernel(DATATYPE_IN1 *bufIn1, DATATYPE_OUT *bufOut,
                              int SIZE, int verbosity) {
  int errors = 0;
  for (int i = 0; i < SIZE; i++) {
    uint32_t ref = i + 256;
    // Each input value is 32 bits, so output should have 4 bytes per input
    for (int b = 0; b < 4; b++) {
      uint8_t expected = (ref >> (8 * b)) & 0xFF;
      uint8_t test = bufOut[i * 4 + b];
      if (test != expected) {
        std::cout << "Error at index " << (i * 4 + b) << ": " << (int)test
                  << " != " << (int)expected << std::endl;
        errors++;
      } else {
        std::cout << "Correct at index " << (i * 4 + b) << ": " << (int)test
                  << " == " << (int)expected << std::endl;
      }
    }
  }
  return errors;
}

//*****************************************************************************
// Should not need to modify below section
//*****************************************************************************

int main(int argc, const char *argv[]) {

  constexpr int IN1_VOLUME = IN1_SIZE / sizeof(DATATYPE_IN1);
  constexpr int OUT_VOLUME = OUT_SIZE / sizeof(DATATYPE_OUT);

  args myargs = parse_args(argc, argv);

  int res = setup_and_run_aie<DATATYPE_IN1, DATATYPE_OUT, initialize_bufIn1,
                              initialize_bufOut, verify_passthrough_kernel>(
      IN1_VOLUME, OUT_VOLUME, myargs);
  return res;
}
