// MIT License
//
// Copyright (c) 2025 Gabriele Vierti
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include "matrix.h"

simd::float4x4 Ortho(float left, float right, float bottom, float top)
{
    float rl = right - left;
    float tb = top - bottom;
    float tx = -(right + left) / rl;
    float ty = -(top + bottom) / tb;

    return simd::float4x4(
      simd::float4{2.0f / rl, 0.0f,       0.0f, 0.0f}, // Column 0
      simd::float4{0.0f,       2.0f / tb, 0.0f, 0.0f}, // Column 1
      simd::float4{0.0f,       0.0f,       1.0f, 0.0f}, // Column 2
      simd::float4{tx,         ty,         0.0f, 1.0f}  // Column 3
    );
}
