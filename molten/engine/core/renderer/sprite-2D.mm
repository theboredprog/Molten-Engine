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
#include "../utils/log-macros.hpp"

Sprite2D::Sprite2D(simd::float2 position, const char* filepath)
    : m_Position(position), m_Color{1.0f, 1.0f, 1.0f, 1.0f}, m_Texture(nullptr), m_VertexData(new VertexData2D[6])
{
    if (filepath && *filepath != '\0') m_Texture = new Texture2D(filepath);

    CreateVertexData();
}

Sprite2D::Sprite2D(simd::float2 position, simd::float4 color, const char* filepath)
    : m_Position(position), m_Color(color), m_Texture(nullptr), m_VertexData(new VertexData2D[6])
{
    if (filepath && *filepath != '\0') m_Texture = new Texture2D(filepath);

    CreateVertexData();
}

Sprite2D::~Sprite2D()
{
    if (m_Texture) delete m_Texture;
    
    delete[] m_VertexData;
}

void Sprite2D::CreateVertexData()
{
    simd::float3 posOffsets[6] =
    {
        {-0.5f, -0.5f, 0.0f},
        {-0.5f,  0.5f, 0.0f},
        { 0.5f,  0.5f, 0.0f},
        {-0.5f, -0.5f, 0.0f},
        { 0.5f,  0.5f, 0.0f},
        { 0.5f, -0.5f, 0.0f},
    };

    simd::float2 texCoords[6] =
    {
        {0.0f, 0.0f}, {0.0f, 1.0f}, {1.0f, 1.0f},
        {0.0f, 0.0f}, {1.0f, 1.0f}, {1.0f, 0.0f}
    };

    for (int i = 0; i < 6; i++)
    {
        simd::float3 offset = simd::make_float3(m_Position, 0.0f);
        
        m_VertexData[i].position = posOffsets[i] + offset;
        
        m_VertexData[i].texCoord = texCoords[i];
        m_VertexData[i].color = m_Color;
    }
}

