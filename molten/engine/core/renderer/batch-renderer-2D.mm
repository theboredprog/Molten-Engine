#include <cmath>
#include <cstring>
#include <Metal/Metal.hpp>
#include <AppKit/AppKit.h>
#include <QuartzCore/CAMetalLayer.hpp>

#include "batch-renderer-2D.hpp"
#include "../application/window.hpp"
#include "../utils/log-macros.hpp"
#include "sprite-2D.hpp"
#include "vertex-data-2D.hpp"
#include "../maths/matrix.hpp"

BatchRenderer2D::BatchRenderer2D(Window* window)
    : m_Window(window), m_MetalCommandQueue(nullptr), m_SamplerState(nullptr), m_ProjBuffer(nullptr)
{
    CreatePipeline();
    CreateBuffers();
    CreateSampler();
}

BatchRenderer2D::~BatchRenderer2D() {
    if (m_Pipeline) m_Pipeline->release();
    if (m_MetalDefaultLibrary) m_MetalDefaultLibrary->release();
    if (m_VertexBuffer) m_VertexBuffer->release();
    if (m_IndexBuffer) m_IndexBuffer->release();
    if (m_MetalCommandQueue) m_MetalCommandQueue->release();
    if (m_SamplerState) m_SamplerState->release();
    if (m_ProjBuffer) m_ProjBuffer->release();
    m_Sprites.clear();
}

void BatchRenderer2D::CreatePipeline()
{
    UpdateProjMatrix(m_Window->GetWidth(), m_Window->GetHeight());
    
    m_MetalDefaultLibrary = m_Window->GetMetalDevice()->newDefaultLibrary();

    auto pipelineDesc = MTL::RenderPipelineDescriptor::alloc()->init();
    pipelineDesc->setVertexFunction(m_MetalDefaultLibrary->newFunction(NS::String::string("vertexShader", NS::UTF8StringEncoding)));
    pipelineDesc->setFragmentFunction(m_MetalDefaultLibrary->newFunction(NS::String::string("fragmentShader", NS::UTF8StringEncoding)));
    pipelineDesc->colorAttachments()->object(0)->setPixelFormat(MTL::PixelFormatBGRA8Unorm);

    // Set up vertex descriptor:
    MTL::VertexDescriptor* vertexDescriptor = MTL::VertexDescriptor::alloc()->init();

    // Attributes:
    // position (float3) at attribute(0)
    auto attr0 = MTL::VertexAttributeDescriptor::alloc()->init();
    attr0->setFormat(MTL::VertexFormatFloat3);
    attr0->setOffset(0);
    attr0->setBufferIndex(0);
    vertexDescriptor->attributes()->setObject(attr0, 0);
    attr0->release();

    // texCoord (float2) at attribute(1) (offset after position: 3 floats * 4 bytes)
    auto attr1 = MTL::VertexAttributeDescriptor::alloc()->init();
    attr1->setFormat(MTL::VertexFormatFloat2);
    attr1->setOffset(sizeof(float) * 3);
    attr1->setBufferIndex(0);
    vertexDescriptor->attributes()->setObject(attr1, 1);
    attr1->release();

    // color (float4) at attribute(2) (offset after position + texCoord: 3 + 2 floats)
    auto attr2 = MTL::VertexAttributeDescriptor::alloc()->init();
    attr2->setFormat(MTL::VertexFormatFloat4);
    attr2->setOffset(sizeof(float) * 5);
    attr2->setBufferIndex(0);
    vertexDescriptor->attributes()->setObject(attr2, 2);
    attr2->release();

    // textureIndex (float) at buffer 0 offset 36 (3+4+2=9 floats *4 bytes)
    auto attr3 = MTL::VertexAttributeDescriptor::alloc()->init();
    attr3->setFormat(MTL::VertexFormatFloat);
    attr3->setOffset(sizeof(float) * 9);
    attr3->setBufferIndex(0);
    vertexDescriptor->attributes()->setObject(attr3, 3);
    attr3->release();

    // Layout for buffer 0:
    auto layout = MTL::VertexBufferLayoutDescriptor::alloc()->init();
    layout->setStride(sizeof(VertexData2D));  // Ensure your VertexData2D is exactly 10 floats (float3 + float4 + float2 + float1)
    layout->setStepFunction(MTL::VertexStepFunctionPerVertex);
    vertexDescriptor->layouts()->setObject(layout, 0);
    layout->release();

    pipelineDesc->setVertexDescriptor(vertexDescriptor);
    vertexDescriptor->release();

    NS::Error* error = nullptr;
    m_Pipeline = m_Window->GetMetalDevice()->newRenderPipelineState(pipelineDesc, &error);
    pipelineDesc->release();

    if (!m_Pipeline) {
        LOG_CORE_ERROR("Failed to create pipeline state: {}", error->localizedDescription()->utf8String());
    }
}

void BatchRenderer2D::CreateBuffers() {
    auto device = m_Window->GetMetalDevice();

    m_VertexBuffer = device->newBuffer(sizeof(VertexData2D) * MaxVertices, MTL::ResourceStorageModeShared);

    uint16_t indices[MaxIndices];
    for (uint32_t i = 0, offset = 0; i < MaxIndices; i += 6, offset += 4) {
        indices[i + 0] = offset + 0;
        indices[i + 1] = offset + 1;
        indices[i + 2] = offset + 2;
        indices[i + 3] = offset + 2;
        indices[i + 4] = offset + 3;
        indices[i + 5] = offset + 0;
    }

    m_IndexBuffer = device->newBuffer(indices, sizeof(indices), MTL::ResourceStorageModeShared);
}

void BatchRenderer2D::CreateSampler() {
    auto device = m_Window->GetMetalDevice();
    MTL::SamplerDescriptor* samplerDesc = MTL::SamplerDescriptor::alloc()->init();
    samplerDesc->setMinFilter(MTL::SamplerMinMagFilterLinear);
    samplerDesc->setMagFilter(MTL::SamplerMinMagFilterLinear);
    samplerDesc->setMipFilter(MTL::SamplerMipFilterNotMipmapped);
    samplerDesc->setSAddressMode(MTL::SamplerAddressModeClampToEdge);
    samplerDesc->setTAddressMode(MTL::SamplerAddressModeClampToEdge);
    m_SamplerState = device->newSamplerState(samplerDesc);
    samplerDesc->release();
}

void BatchRenderer2D::UpdateProjMatrix(unsigned int width, unsigned int height) {
    if (!m_Window) return;

    auto device = m_Window->GetMetalDevice();
    if (!device) return;

    if (m_ProjBuffer) {
        m_ProjBuffer->release();
        m_ProjBuffer = nullptr;
    }

    m_ProjMatrix = Ortho(0.0f, static_cast<float>(width), 0.0f, static_cast<float>(height));
    m_ProjBuffer = device->newBuffer(&m_ProjMatrix, sizeof(simd::float4x4), MTL::ResourceStorageModeShared);
}

void BatchRenderer2D::AddSprite(Sprite2D* sprite) {
    if (m_Sprites.size() < MaxSprites)
        m_Sprites.push_back(sprite);
}

void BatchRenderer2D::UpdateBuffers() {
    m_VertexData.clear();
    m_VertexData.reserve(m_Sprites.size() * 4);

    for (auto* sprite : m_Sprites) {
        simd::float2 pos = sprite->GetPosition();
        simd::float2 size = sprite->GetSize();
        simd::float4 color = sprite->GetColor();
        float rot = sprite->GetRotation();

        simd::float2 halfSize = size * 0.5f;
        simd::float2 quad[4] = {
            {-halfSize.x, -halfSize.y},
            { halfSize.x, -halfSize.y},
            { halfSize.x,  halfSize.y},
            {-halfSize.x,  halfSize.y}
        };

        float cs = std::cos(rot);
        float sn = std::sin(rot);

        for (int i = 0; i < 4; ++i) {
            simd::float2 rotated = {
                quad[i].x * cs - quad[i].y * sn,
                quad[i].x * sn + quad[i].y * cs
            };
            simd::float2 worldPos = pos + rotated;

            VertexData2D vertex;
            vertex.position = simd::float3{worldPos.x, worldPos.y, 0.0f};
            vertex.color = color;
            vertex.texCoord = {(i == 1 || i == 2) ? 1.0f : 0.0f, (i >= 2) ? 1.0f : 0.0f};
            vertex.textureIndex = 0.0f;

            m_VertexData.push_back(vertex);
        }
    }

    std::memcpy(m_VertexBuffer->contents(), m_VertexData.data(), m_VertexData.size() * sizeof(VertexData2D));
}

void BatchRenderer2D::Flush() {
    if (m_Sprites.empty())
        return;

    UpdateBuffers();

    if (!m_MetalCommandQueue) {
        m_MetalCommandQueue = m_Window->GetMetalDevice()->newCommandQueue();
        if (!m_MetalCommandQueue) {
            LOG_CORE_ERROR("Failed to create Metal command queue.");
            return;
        }
    }

    auto commandBuffer = m_MetalCommandQueue->commandBuffer();
    m_MetalDrawable = m_Window->GetMetalLayer()->nextDrawable();

    if (!m_MetalDrawable || !m_MetalDrawable->texture()) {
        LOG_CORE_WARN("Invalid drawable or texture.");
        commandBuffer->commit();
        return;
    }

    MTL::RenderPassDescriptor* renderPassDescriptor = MTL::RenderPassDescriptor::alloc()->init();
    auto colorAttachment = renderPassDescriptor->colorAttachments()->object(0);
    colorAttachment->setTexture(m_MetalDrawable->texture());
    colorAttachment->setLoadAction(MTL::LoadActionClear);
    colorAttachment->setStoreAction(MTL::StoreActionStore);
    colorAttachment->setClearColor(MTL::ClearColor(41.0 / 255.0, 42.0 / 255.0, 48.0 / 255.0, 1.0));

    auto encoder = commandBuffer->renderCommandEncoder(renderPassDescriptor);

    encoder->setRenderPipelineState(m_Pipeline);
    encoder->setVertexBuffer(m_VertexBuffer, 0, 0);
    encoder->setVertexBuffer(m_ProjBuffer, 0, 1);
    encoder->setFragmentSamplerState(m_SamplerState, 0);  // <-- sampler binding fixed here

    encoder->drawIndexedPrimitives(MTL::PrimitiveTypeTriangle,
                                   static_cast<uint32_t>(m_Sprites.size() * 6),
                                   MTL::IndexTypeUInt16,
                                   m_IndexBuffer,
                                   0);
    encoder->endEncoding();

    commandBuffer->presentDrawable(m_MetalDrawable);
    commandBuffer->commit();

    renderPassDescriptor->release();
    Clear();
}

void BatchRenderer2D::Clear() {
    m_Sprites.clear();
}
