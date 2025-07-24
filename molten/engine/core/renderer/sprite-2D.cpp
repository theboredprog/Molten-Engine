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

#include "sprite-2D.h"

#include <Metal/Metal.hpp>

#include "../utils/log-macros.h"
#include "texture-2D.h"

Sprite2D::Sprite2D(simd::float2 position,
                   simd::float2 size,
                   float rotation,
                   const char* filepath)
    : m_Position(position), m_Color{1.0f, 1.0f, 1.0f, 1.0f},
      m_Size(size), m_Rotation(rotation), m_Texture(nullptr)
{
    if (filepath && *filepath != '\0')
        m_Texture = new Texture2D(filepath);
}

Sprite2D::Sprite2D(simd::float2 position,
                   simd::float4 color,
                   simd::float2 size,
                   float rotation,
                   const char* filepath)
    : m_Position(position), m_Color(color),
      m_Size(size), m_Rotation(rotation), m_Texture(nullptr)
{
    if (filepath && *filepath != '\0')
        m_Texture = new Texture2D(filepath);

}

Sprite2D::~Sprite2D()
{
    if (m_Texture) delete m_Texture;
}
