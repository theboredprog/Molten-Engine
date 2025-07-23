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

#include <iostream>
#include <random>
#include <algorithm>
#include <unordered_set>

#include <Metal/Metal.hpp>
#include <QuartzCore/CAMetalLayer.hpp>

#include "renderer-2D.hpp"
#include "../application/window.hpp"
#include "vertex-data-2D.hpp"

Renderer2D::Renderer2D(Window* window)
: m_Window(window), m_MetalDefaultLibrary(nullptr), m_MetalCommandQueue(nullptr), m_MetalRenderPSO(nullptr), m_MetalDrawable(nullptr), m_MetalCommandBuffer(nullptr) { s_Rng.seed(std::random_device{}()); }

void Renderer2D::AddSprite(Sprite2D* sprite)
{
    if (!sprite) return;

    std::uniform_int_distribution<unsigned int> dist(1, 0xFFFFFFFE);
    
    unsigned int sprite_id;

    do
    {
        sprite_id = dist(s_Rng);
    } while (s_UsedIds.find(sprite_id) != s_UsedIds.end());

    s_UsedIds.insert(sprite_id);

    sprite->SetId(sprite_id);

    m_Queue.push_back(sprite);
    
    m_VertexBuffers.push_back(nullptr);
}

void Renderer2D::RemoveSprite(Sprite2D* sprite)
{
    if (!sprite) return;

    auto it = std::find(m_Queue.begin(), m_Queue.end(), sprite);
    if (it != m_Queue.end())
    {
        size_t idx = std::distance(m_Queue.begin(), it);

        if (m_VertexBuffers[idx])
        {
            m_VertexBuffers[idx]->release();
            m_VertexBuffers.erase(m_VertexBuffers.begin() + idx);
        }

        m_Queue.erase(it);
    }
}

void Renderer2D::PrepareRenderingData()
{
    if (!m_Window) { std::cerr << "[ERROR] Window pointer is null." << std::endl; return; }

    auto device = m_Window->GetMetalDevice();
    if (!device) { std::cerr << "[ERROR] Metal device is null." << std::endl; return; }

    for (size_t i = 0; i < m_Queue.size(); i++)
    {
        Sprite2D* sprite = m_Queue[i];
        if (!sprite) { std::cerr << "[WARNING] Null sprite at index " << i << std::endl; continue; }
        
        auto texture = m_Queue[i]->GetTexture();
        
        if (texture) texture->SetMetalDevice(device);
        
        else std::cerr << "[WARNING] Sprite texture null at index " << i << std::endl;

        auto vertexData = sprite->GetData();
        if (!vertexData) { std::cerr << "[WARNING] Null vertex data for sprite at index " << i << std::endl; continue; }

        if (m_VertexBuffers[i])
        {
            m_VertexBuffers[i]->release();
            m_VertexBuffers[i] = nullptr;
        }

        m_VertexBuffers[i] = device->newBuffer(vertexData, sizeof(VertexData2D) * 6, MTL::ResourceStorageModeShared);

        if (!m_VertexBuffers[i]) { std::cerr << "[ERROR] Failed to create Metal buffer for sprite index " << i << std::endl; return; }
    }

    if (m_MetalDefaultLibrary) { m_MetalDefaultLibrary->release(); m_MetalDefaultLibrary = nullptr; }

    m_MetalDefaultLibrary = device->newDefaultLibrary();
    if (!m_MetalDefaultLibrary) { std::cerr << "[ERROR] Failed to load Metal default library." << std::endl; return; }

    if (m_MetalCommandQueue) { m_MetalCommandQueue->release(); m_MetalCommandQueue = nullptr; }

    m_MetalCommandQueue = device->newCommandQueue();
    if (!m_MetalCommandQueue) { std::cerr << "[ERROR] Failed to create Metal command queue." << std::endl; return; }

    auto vertexShader = m_MetalDefaultLibrary->newFunction(NS::String::string("vertexShader", NS::UTF8StringEncoding));
    auto fragmentShader = m_MetalDefaultLibrary->newFunction(NS::String::string("fragmentShader", NS::UTF8StringEncoding));

    if (!vertexShader || !fragmentShader) { std::cerr << "[ERROR] Shader function not found in Metal library." << std::endl; return; }

    if (m_MetalRenderPSO) { m_MetalRenderPSO->release(); m_MetalRenderPSO = nullptr; }

    MTL::RenderPipelineDescriptor* pipelineDescriptor = MTL::RenderPipelineDescriptor::alloc()->init();
    pipelineDescriptor->setLabel(NS::String::string("2D Rendering Pipeline", NS::ASCIIStringEncoding));
    pipelineDescriptor->setVertexFunction(vertexShader);
    pipelineDescriptor->setFragmentFunction(fragmentShader);

    auto pixelFormat = (MTL::PixelFormat)m_Window->GetMetalLayer()->pixelFormat();
    pipelineDescriptor->colorAttachments()->object(0)->setPixelFormat(pixelFormat);
    
    auto vertexDescriptor = MTL::VertexDescriptor::alloc()->init();

    vertexDescriptor->attributes()->object(0)->setFormat(MTL::VertexFormatFloat3); // position
    vertexDescriptor->attributes()->object(0)->setOffset(offsetof(VertexData2D, position));
    vertexDescriptor->attributes()->object(0)->setBufferIndex(0);

    vertexDescriptor->attributes()->object(1)->setFormat(MTL::VertexFormatFloat2); // texCoord
    vertexDescriptor->attributes()->object(1)->setOffset(offsetof(VertexData2D, texCoord));
    vertexDescriptor->attributes()->object(1)->setBufferIndex(0);

    vertexDescriptor->attributes()->object(2)->setFormat(MTL::VertexFormatFloat4); // color
    vertexDescriptor->attributes()->object(2)->setOffset(offsetof(VertexData2D, color));
    vertexDescriptor->attributes()->object(2)->setBufferIndex(0);

    vertexDescriptor->layouts()->object(0)->setStride(sizeof(VertexData2D));
    vertexDescriptor->layouts()->object(0)->setStepFunction(MTL::VertexStepFunctionPerVertex);
    vertexDescriptor->layouts()->object(0)->setStepRate(1);

    pipelineDescriptor->setVertexDescriptor(vertexDescriptor);

    vertexDescriptor->release();


    NS::Error* error = nullptr;
    m_MetalRenderPSO = device->newRenderPipelineState(pipelineDescriptor, &error);

    pipelineDescriptor->release();

    vertexShader->release();

    fragmentShader->release();

    if (!m_MetalRenderPSO)
    {
        std::cerr << "[ERROR] Failed to create Render Pipeline State: " << (error ? error->localizedDescription()->utf8String() : "unknown error") << std::endl;
        return;
    }
    
    if (m_MetalSamplerState)
    {
        m_MetalSamplerState->release();
        m_MetalSamplerState = nullptr;
    }

    MTL::SamplerDescriptor* samplerDesc = MTL::SamplerDescriptor::alloc()->init();
    
    samplerDesc->setMinFilter(MTL::SamplerMinMagFilterLinear);
    samplerDesc->setMagFilter(MTL::SamplerMinMagFilterLinear);
    samplerDesc->setMipFilter(MTL::SamplerMipFilterNotMipmapped);
    samplerDesc->setSAddressMode(MTL::SamplerAddressModeClampToEdge);
    samplerDesc->setTAddressMode(MTL::SamplerAddressModeClampToEdge);
    
    m_MetalSamplerState = device->newSamplerState(samplerDesc);
    
    samplerDesc->release();

    if (!m_MetalSamplerState) { std::cerr << "[ERROR] Failed to create Metal sampler state." << std::endl; return; }
}

void Renderer2D::IssueRenderCall()
{
    @autoreleasepool
    {
        if (!m_MetalCommandQueue || !m_MetalRenderPSO)
        {
            std::cerr << "[ERROR] Cannot issue render call: CommandQueue or PipelineState not ready." << std::endl;
            return;
        }

        m_MetalDrawable = m_Window->GetMetalLayer()->nextDrawable();
        if (!m_MetalDrawable)
        {
            std::cerr << "[WARNING] Metal drawable is null. Possibly invalid layer size or window not ready." << std::endl;
            return;
        }

        m_MetalCommandBuffer = m_MetalCommandQueue->commandBuffer();

        MTL::RenderPassDescriptor* renderPassDescriptor = MTL::RenderPassDescriptor::alloc()->init();

        auto colorAttachment = renderPassDescriptor->colorAttachments()->object(0);
        
        colorAttachment->setTexture(m_MetalDrawable->texture());
        colorAttachment->setLoadAction(MTL::LoadActionClear);
        colorAttachment->setClearColor(MTL::ClearColor(41.0f / 255.0f, 42.0f / 255.0f, 48.0f / 255.0f, 1.0f));
        colorAttachment->setStoreAction(MTL::StoreActionStore);

        MTL::RenderCommandEncoder* encoder = m_MetalCommandBuffer->renderCommandEncoder(renderPassDescriptor);

        encoder->setRenderPipelineState(m_MetalRenderPSO);

        NS::UInteger vertexCount = 6;
        NS::UInteger vertexStart = 0;

        for (size_t i = 0; i < m_Queue.size(); i++)
        {
            if (!m_VertexBuffers[i]) continue;

            encoder->setVertexBuffer(m_VertexBuffers[i], 0, 0);

            auto texture = m_Queue[i]->GetTexture()->GetMetalTexture();
            
            if (texture) encoder->setFragmentTexture(texture, 0);
            
            else encoder->setFragmentTexture(nullptr, 0);
            
            encoder->setFragmentSamplerState(m_MetalSamplerState, 0);

            encoder->drawPrimitives(MTL::PrimitiveTypeTriangle, vertexStart, vertexCount);
        }

        encoder->endEncoding();

        m_MetalCommandBuffer->presentDrawable(m_MetalDrawable);
        m_MetalCommandBuffer->commit();

        // Remove or conditionally compile this for debugging only - it stalls the cpu to wait for the gpu
        // = very bad for performance.
        // m_MetalCommandBuffer->waitUntilCompleted();

        renderPassDescriptor->release();
    }
}

Renderer2D::~Renderer2D()
{
    for (auto buffer : m_VertexBuffers)
        if (buffer) buffer->release();

    m_VertexBuffers.clear();

    for (auto sprite : m_Queue)
        delete sprite;

    m_Queue.clear();

    if (m_MetalRenderPSO) { m_MetalRenderPSO->release(); m_MetalRenderPSO = nullptr; }
    if (m_MetalCommandQueue) { m_MetalCommandQueue->release(); m_MetalCommandQueue = nullptr; }
    if (m_MetalDefaultLibrary) { m_MetalDefaultLibrary->release(); m_MetalDefaultLibrary = nullptr; }
    if (m_MetalSamplerState) { m_MetalSamplerState->release(); m_MetalSamplerState = nullptr; }

    if (m_Window && m_Window->GetMetalDevice()) { m_Window->GetMetalDevice()->release(); m_Window->SetMetalDevice(nullptr); }
}
