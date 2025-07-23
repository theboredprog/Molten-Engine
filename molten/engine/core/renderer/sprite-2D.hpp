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

#include "texture-2D.hpp"

#include <simd/simd.h>

struct VertexData2D;

class Sprite2D
{
private:
    
    unsigned int m_Id;
    
    simd::float2 m_Position;
    simd::float4 m_Color;          // store color (RGBA)
    
    Texture2D* m_Texture;
    VertexData2D* m_Data;

    void UpdateVertexData();       // call after position or color change

public:
    
    Sprite2D(simd::float2 position, const char* filepath = nullptr);  // allow nullptr texture
    Sprite2D(simd::float2 position,simd::float4 color, const char* filepath = nullptr);

    void SetId(unsigned int id) { m_Id = id; }
    unsigned int GetId() const { return m_Id; }

    simd::float2 GetPosition() const { return m_Position; }
    void SetPosition(const simd::float2& pos) { m_Position = pos; UpdateVertexData(); }

    simd::float4 GetColor() const { return m_Color; }
    void SetColor(const simd::float4& color) { m_Color = color; UpdateVertexData(); }

    Texture2D* GetTexture() const { return m_Texture; }
    VertexData2D* GetData() const { return m_Data; }
    
    ~Sprite2D();
};
