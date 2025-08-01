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

#include <vector>
#include <unordered_set>
#include <random>

#include "../maths/matrix.h"

namespace MTL
{
    class Buffer;
    class Library;
    class CommandQueue;
    class RenderPipelineState;
    class CommandBuffer;
    class Device;
    class SamplerState;
    class Buffer;
}

namespace CA
{
    class MetalDrawable;
}

class Window;
class Sprite2D;

class Renderer2D
{
private:
    
    MTL::Library* m_MetalDefaultLibrary = nullptr;
    MTL::CommandQueue* m_MetalCommandQueue = nullptr;
    MTL::RenderPipelineState* m_MetalRenderPSO = nullptr;
    
    CA::MetalDrawable* m_MetalDrawable = nullptr;
    MTL::CommandBuffer* m_MetalCommandBuffer = nullptr;
    MTL::SamplerState* m_MetalSamplerState = nullptr;
    
    std::vector<MTL::Buffer*> m_VertexBuffers;
    simd::float4x4 m_ProjMatrix;
    MTL::Buffer* m_ProjBuffer = nullptr;
    
    std::vector<Sprite2D*> m_Queue;
    std::unordered_set<unsigned int> s_UsedIds;
    std::mt19937 s_Rng;
    
    Window* m_Window = nullptr;
    
public:
    
    explicit Renderer2D(Window* window);
    
    void AddSprite(Sprite2D* sprite);
    
    void RemoveSprite(Sprite2D* sprite);
    
    void UpdateProjMatrix(unsigned int width, unsigned int height);
    
    void PrepareRenderingData();
    
    void IssueRenderCall();
    
    Window* GetWindow() const { return m_Window; }
    
    void Cleanup();
    
    ~Renderer2D();
};
