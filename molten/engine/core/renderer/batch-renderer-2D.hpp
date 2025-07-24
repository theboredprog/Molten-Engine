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

#pragma once

#include <vector>
#include <simd/simd.h>

namespace MTL {
    class Buffer;
    class Library;
    class CommandQueue;
    class RenderPipelineState;
    class CommandBuffer;
    class Device;
    class SamplerState;
    class MTLRenderPipelineState;
}

class Window;
class Sprite2D;
struct VertexData2D;

class BatchRenderer2D {
    
private:
    Window* m_Window = nullptr;
    
    MTL::Library* m_MetalDefaultLibrary = nullptr;
    MTL::RenderPipelineState* m_Pipeline = nullptr;
    MTL::Buffer* m_VertexBuffer = nullptr;
    MTL::Buffer* m_IndexBuffer = nullptr;
    CA::MetalDrawable* m_MetalDrawable = nullptr;
    
    MTL::CommandQueue* m_MetalCommandQueue = nullptr;
    MTL::SamplerState* m_SamplerState = nullptr;
    MTL::Buffer* m_ProjBuffer = nullptr;
    
    std::vector<Sprite2D*> m_Sprites;
    std::vector<VertexData2D> m_VertexData;

    static constexpr uint32_t MaxSprites = 1000;
    static constexpr uint32_t MaxVertices = MaxSprites * 4;
    static constexpr uint32_t MaxIndices = MaxSprites * 6;
    
    void CreatePipeline();
    void CreateBuffers();
    void CreateSampler();
    void UpdateBuffers();
    
    simd::float4x4 m_ProjMatrix{};
    
public:
    explicit BatchRenderer2D(Window* window);
    ~BatchRenderer2D();

    void AddSprite(Sprite2D* sprite);
    
    void UpdateProjMatrix(unsigned int width, unsigned int height);
    void Flush();
    void Clear();
};
