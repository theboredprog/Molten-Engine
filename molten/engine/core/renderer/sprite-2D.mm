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

#include <Metal/Metal.hpp>

#include "vertex-data-2D.hpp"
#include "sprite-2D.hpp"

Sprite2D::Sprite2D(simd::float2 position, const char* filepath)
    : m_Position(position),
      m_Color{1.0f, 1.0f, 1.0f, 1.0f},  // default white
      m_Texture(nullptr),
      m_Data(new VertexData2D[6])
{
    if (filepath && *filepath != '\0')
        m_Texture = new Texture2D(filepath);

    UpdateVertexData();
}

// Constructor with color parameter
Sprite2D::Sprite2D(simd::float2 position, simd::float4 color, const char* filepath)
    : m_Position(position),
      m_Color(color),
      m_Texture(nullptr),
      m_Data(new VertexData2D[6])
{
    if (filepath && *filepath != '\0')
        m_Texture = new Texture2D(filepath);

    UpdateVertexData();
}

Sprite2D::~Sprite2D()
{
    delete[] m_Data;
    if (m_Texture) delete m_Texture;
}

void Sprite2D::UpdateVertexData()
{
    // Define corners relative to center (float3 instead of float4)
    simd::float3 posOffsets[6] = {
        {-0.5f, -0.5f, 0.0f},
        {-0.5f,  0.5f, 0.0f},
        { 0.5f,  0.5f, 0.0f},
        {-0.5f, -0.5f, 0.0f},
        { 0.5f,  0.5f, 0.0f},
        { 0.5f, -0.5f, 0.0f},
    };

    simd::float2 texCoords[6] = {
        {0.0f, 0.0f}, {0.0f, 1.0f}, {1.0f, 1.0f},
        {0.0f, 0.0f}, {1.0f, 1.0f}, {1.0f, 0.0f}
    };

    for (int i = 0; i < 6; i++)
    {
        simd::float3 offset = simd::make_float3(m_Position, 0.0f);
        
        m_Data[i].position = posOffsets[i] + offset;
        
        m_Data[i].texCoord = texCoords[i];
        m_Data[i].color = m_Color;
    }
}

