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

#include <simd/simd.h>

class Texture2D;

class Sprite2D
{
private:
    
    unsigned int m_Id;
    
    simd::float2 m_Position;
    simd::float4 m_Color;
    simd::float2 m_Size;
    
    float m_Rotation;
    
    Texture2D* m_Texture = nullptr;

public:
    
    explicit Sprite2D(simd::float2 position,
             simd::float2 size = {100.0f, 100.0f},
             float rotation = 0.0f,
             const char* filepath = nullptr);

    explicit Sprite2D(simd::float2 position,
             simd::float4 color,
             simd::float2 size = {100.0f, 100.0f},
             float rotation = 0.0f,
             const char* filepath = nullptr);

    void SetId(unsigned int id) { m_Id = id; }
    void SetPosition(const simd::float2& pos) { m_Position = pos; }
    void SetSize(const simd::float2& size) { m_Size = size; }
    void SetRotation(float radians) { m_Rotation = radians; }
    void SetColor(const simd::float4& color) { m_Color = color; }

    unsigned int GetId() const { return m_Id; }
    
    simd::float2 GetPosition() const { return m_Position; }
    simd::float4 GetColor() const { return m_Color; }
    simd::float2 GetSize() const { return m_Size; }
    float GetRotation() const { return m_Rotation; }

    Texture2D* GetTexture() const { return m_Texture; }

    ~Sprite2D();
};
