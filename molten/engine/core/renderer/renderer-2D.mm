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

#include "renderer-2D.h"

#include <random>
#include <algorithm>
#include <unordered_set>

#include <Metal/Metal.hpp>
#include <QuartzCore/CAMetalLayer.hpp>

#include "../application/window.h"
#include "vertex-data-2D.h"
#include "../utils/log-macros.h"
#include "../application/window.h"
#include "sprite-2D.h"
#include "texture-2D.h"

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

void Renderer2D::UpdateProjMatrix(unsigned int width, unsigned int height)
{
    if (!m_Window) return;
    
    auto device = m_Window->GetMetalDevice();
    if (!device) return;

    if (m_ProjBuffer)
    {
        m_ProjBuffer->release();
        m_ProjBuffer = nullptr;
    }

    m_ProjMatrix = Ortho(0.0f, width, 0.0f, height);

    m_ProjBuffer = device->newBuffer(&m_ProjMatrix, sizeof(simd::float4x4), MTL::ResourceStorageModeShared);
}


void Renderer2D::PrepareRenderingData()
{
    if (!m_Window) { CORE_ASSERT(false, "Window pointer is null."); return; }

    auto device = m_Window->GetMetalDevice();
    if (!device) { CORE_ASSERT(false, "Metal device is null."); return; }

    for (size_t i = 0; i < m_Queue.size(); i++)
    {
        Sprite2D* sprite = m_Queue[i];
        if (!sprite) { LOG_CORE_ERROR("Null sprite at index "); continue; }
        
        auto texture = m_Queue[i]->GetTexture();
        
        if (texture) texture->SetMetalDevice(device);
        
        else LOG_CORE_WARN("Sprite texture null at index {}", i);

        auto vertexData = new VertexData2D[6];
        
        // Quad base vertices (unit square centered at origin)
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

        // Add these members to your Sprite2D class:
        // simd::float2 m_Scale = {100.0f, 100.0f}; // default scale in pixels
        // float m_Rotation = 0.0f; // rotation in radians

        float cosAngle = cos(sprite->GetRotation());
        float sinAngle = sin(sprite->GetRotation());

        for (int i = 0; i < 6; i++)
        {
            // Rotate
            float rotatedX = posOffsets[i].x * cosAngle - posOffsets[i].y * sinAngle;
            float rotatedY = posOffsets[i].x * sinAngle + posOffsets[i].y * cosAngle;

            // Scale and translate to position
            float finalX = sprite->GetPosition().x + rotatedX *  sprite->GetSize().x;
            float finalY =  sprite->GetPosition().y + rotatedY * sprite->GetSize().y;

            vertexData[i].position = simd::float3{finalX, finalY, 0.0f};
            vertexData[i].texCoord = texCoords[i];
            vertexData[i].color = sprite->GetColor();
        }
        
        if (!vertexData) { LOG_CORE_WARN("Null vertex data for sprite at index {}", i); continue; }

        if (m_VertexBuffers[i])
        {
            m_VertexBuffers[i]->release();
            m_VertexBuffers[i] = nullptr;
        }

        m_VertexBuffers[i] = device->newBuffer(vertexData, sizeof(VertexData2D) * 6, MTL::ResourceStorageModeShared);

        if (!m_VertexBuffers[i]) { LOG_CORE_ERROR("Failed to create Metal buffer for sprite index {}", i); return; }
    }
    
    UpdateProjMatrix(m_Window->GetWidth(), m_Window->GetHeight());

    if (m_MetalDefaultLibrary) { m_MetalDefaultLibrary->release(); m_MetalDefaultLibrary = nullptr; }

    m_MetalDefaultLibrary = device->newDefaultLibrary();
    if (!m_MetalDefaultLibrary) { LOG_CORE_ERROR("Failed to load Metal default library."); return; }

    if (m_MetalCommandQueue) { m_MetalCommandQueue->release(); m_MetalCommandQueue = nullptr; }

    m_MetalCommandQueue = device->newCommandQueue();
    if (!m_MetalCommandQueue) { LOG_CORE_ERROR("Failed to create Metal command queue."); return; }

    auto vertexShader = m_MetalDefaultLibrary->newFunction(NS::String::string("spriteVertexShader", NS::UTF8StringEncoding));
    auto fragmentShader = m_MetalDefaultLibrary->newFunction(NS::String::string("spriteFragmentShader", NS::UTF8StringEncoding));

    if (!vertexShader || !fragmentShader) { LOG_CORE_ERROR("Shader function not found in Metal library."); return; }

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
        LOG_CORE_ERROR("Failed to create Render Pipeline State: {}", error->localizedDescription()->utf8String());
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

    if (!m_MetalSamplerState) { LOG_CORE_ERROR("Failed to create Metal sampler state."); return; }
}

void Renderer2D::IssueRenderCall()
{
    @autoreleasepool
    {
        if (!m_MetalCommandQueue || !m_MetalRenderPSO)
        {
            LOG_CORE_ERROR("Cannot issue render call: CommandQueue or PipelineState not ready.");
            return;
        }

        m_MetalDrawable = m_Window->GetMetalLayer()->nextDrawable();
        if (!m_MetalDrawable)
        {
            LOG_CORE_WARN("Metal drawable is null. Possibly invalid layer size or window not ready.");
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

        encoder->setVertexBuffer(m_ProjBuffer, 0, 1);
        
        for (size_t i = 0; i < m_Queue.size(); i++)
        {
            if (!m_VertexBuffers[i]) continue;

            encoder->setVertexBuffer(m_VertexBuffers[i], 0, 0);
            
            auto tex = m_Queue[i]->GetTexture();
            
            if (tex) encoder->setFragmentTexture(tex->GetMetalTexture(), 0);
            
            else encoder->setFragmentTexture(nullptr, 0);
            
            encoder->setFragmentSamplerState(m_MetalSamplerState, 0);

            encoder->drawPrimitives(MTL::PrimitiveTypeTriangle, vertexStart, vertexCount);
        }

        encoder->endEncoding();

        m_MetalCommandBuffer->presentDrawable(m_MetalDrawable);
        m_MetalCommandBuffer->commit();

        m_MetalCommandBuffer->waitUntilCompleted();

        renderPassDescriptor->release();
    }
}

void Renderer2D::Cleanup()
{
    for (auto buffer : m_VertexBuffers)
        if (buffer) buffer->release();

    m_VertexBuffers.clear();


    m_Queue.clear();
}

Renderer2D::~Renderer2D()
{
    if (m_MetalRenderPSO) { m_MetalRenderPSO->release(); m_MetalRenderPSO = nullptr; }
    if (m_MetalCommandQueue) { m_MetalCommandQueue->release(); m_MetalCommandQueue = nullptr; }
    if (m_MetalDefaultLibrary) { m_MetalDefaultLibrary->release(); m_MetalDefaultLibrary = nullptr; }
    if (m_MetalSamplerState) { m_MetalSamplerState->release(); m_MetalSamplerState = nullptr; }
    
    if (m_Window && m_Window->GetMetalDevice()) { m_Window->GetMetalDevice()->release(); m_Window->SetMetalDevice(nullptr); }
}
