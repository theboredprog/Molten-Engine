//
//  renderer.mm
//  MyApp
//
//  Created by Gabriele Vierti on 21/07/25.
//

#include <iostream>
#include <cstdlib>

#include <simd/simd.h> // maths lib by apple, equivalent to glm if you've worked with opengl or vulkan.
// glm is compatible with metal, but it has important differences: https://stackoverflow.com/questions/54930382/is-the-glm-math-library-compatible-with-apples-metal-shading-language

#include "renderer.hpp"

Renderer::Renderer(NSWindow* window)
: m_MetalWindow(window) {}

bool Renderer::Init(int width, int height)
{
    m_MetalDevice = MTL::CreateSystemDefaultDevice();
    if (!m_MetalDevice)
    {
        std::cerr << "[ERROR] Failed to create Metal device." << std::endl;
        return false;
    }
    
    m_MetalLayer = [CAMetalLayer layer];
    if (!m_MetalLayer)
    {
        std::cerr << "[ERROR] Failed to create CAMetalLayer." << std::endl;
        return false;
    }
    
    if (!m_MetalWindow)
    {
        std::cerr << "[ERROR] Failed to get native NSWindow from GLFW." << std::endl;
        return false;
    }
    
    m_MetalLayer.device = (__bridge id<MTLDevice>)m_MetalDevice;
    m_MetalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    m_MetalLayer.drawableSize = CGSizeMake(width, height); // set the resolution of the drawable metal area
    m_MetalWindow.contentView.wantsLayer = YES;
    m_MetalWindow.contentView.layer = getMetalLayer();
    
    return true;
}

void Renderer::PrepareRenderingData()
{
    // Setup the vertices of the triangle
    simd::float3 triangleVertices[] =
    {
        {-0.5f, -0.5f, 0.0f},
        { 0.5f, -0.5f, 0.0f},
        { 0.0f,  0.5f, 0.0f}
    };

    // create the vertex buffer
    // pointer: giving it a ref to the data,
    // length: the size in bites of it
    // options: in this case we tell metal that the data can be shared between CPU and GPU, so that both can access it.
    m_TriangleVertexBuffer = m_MetalDevice->newBuffer(&triangleVertices,
                                                  sizeof(triangleVertices),
                                                      MTL::ResourceStorageModeShared);
    
    // create a new default library
    // xcode compiles all .metal source files into a single default library when you compile your project
    // in this case, our MTL::Library* will give us access to all our metal source code from a single source.
    // In case you get any errors here, make sure your metal source files are included in the Build Phases section of
    // your project.
    m_MetalDefaultLibrary = m_MetalDevice->newDefaultLibrary();
    
    if(!m_MetalDefaultLibrary)
    {
        std::cerr << "[ERROR] Failed to load the Metal default library." << std::endl;
        return;
    }
    
    // create the command queue
    // the command queue contains multiple command buffers
    // command buffers store individual commands that instruct the gpu, via the use of shaders.
    // a command queue allows to create command buffers
    // the way we use command buffers is through something called Command Encoder, which allows us
    // to, you guessed it, encode commands onto them.
    // the command queue is responsible for creating command buffers, which represent a set of tasks for the gpu
    
    m_MetalCommandQueue = m_MetalDevice->newCommandQueue();
    
    // now we are going to create our render pipeline
    // a render pipeline is an object that contains the GPU's rendering state, including shaders, vertex data, and other
    // rendering settings.
    // they are setup once, and can be used for similar objects that share graphics similarities
    // in this case our render pipeline is setup to render individual triangles
    
    // the first thing to do is grab our vertex and fragment shaders from the metal library, specifying the names of the functions
    MTL::Function* vertexShader = m_MetalDefaultLibrary->newFunction(NS::String::string("vertexShader", NS::ASCIIStringEncoding));
    
    if (!vertexShader)
    {
        std::cerr << "[ERROR] Vertex shader not found in library." << std::endl;
        return;
    }
    
    MTL::Function* fragmentShader = m_MetalDefaultLibrary->newFunction(NS::String::string("fragmentShader", NS::ASCIIStringEncoding));

    if (!fragmentShader)
    {
        std::cerr << "[ERROR] Fragment shader not found in library." << std::endl;
        return;
    }
    
    // create the pipeline object
    MTL::RenderPipelineDescriptor* renderPipelineDescriptor = MTL::RenderPipelineDescriptor::alloc()->init();

    // and configure it
    // set label
    renderPipelineDescriptor->setLabel(NS::String::string("Triangle Rendering Pipeline", NS::ASCIIStringEncoding));
    
    // set vertex and fragment shaders
    renderPipelineDescriptor->setVertexFunction(vertexShader);
    renderPipelineDescriptor->setFragmentFunction(fragmentShader);

    if (!renderPipelineDescriptor)
    {
        std::cerr << "[ERROR] Failed to set the Render Pipeline Descriptor." << std::endl;
        return;
    }

    // set the pixel format, which needs to match the format of our render target
    MTL::PixelFormat pixelFormat = (MTL::PixelFormat)m_MetalLayer.pixelFormat;
    // specify the format and layout of the color buffer that is used to store the output
    // of the color shader
    // this buffer is where the final color info of each pixel of the image is stored.
    renderPipelineDescriptor->colorAttachments()->object(0)->setPixelFormat(pixelFormat);

    // we then use a metal device to represent a compiled render pipeline
    // we create a new pipeline state and take the descriptor as input
    // a pipeline is a series of stages that process vertex and fragment data to produce the final image
    // once we have created this object we can use it to render objects by encoding render commands to
    // a command buffer and submitting it to the GPU for rendering.
    // you can create a MTL::RenderPipelineState for each render pipeline you may want - we only need one in this case
    NS::Error* error;
    m_MetalRenderPSO = m_MetalDevice->newRenderPipelineState(renderPipelineDescriptor, &error);
    
    if (!m_MetalRenderPSO)
    {
        std::cerr << "[ERROR] Failed to create Render Pipeline State: " << error->localizedDescription()->utf8String() << std::endl;
        return;
    }

    // finally release the memory for the descriptor (because we used alloc() to create it)
    renderPipelineDescriptor->release();
}

void Renderer::Render()
{
    // why autoreleasepool?
    // read: https://github.com/bkaradzic/metal-cpp/blob/metal-cpp_macOS15.2_iOS18.2/README.md#autoreleasepools-and-objects
    // technically you could do:
    // m_MetalDrawable = (__bridge CA::MetalDrawable*)[m_MetalLayer nextDrawable];
    // [m_MetalDrawable retain];   // take ownership
    // draw here
    // [m_MetalDrawable release];  // release ownership manually
    // but it's verbose and goes against cocoa's memory flow, so it's highly discouraged.
    // this prevents memory leaks as well.
    @autoreleasepool
    {
        // Apple's metal-cpp wrapper expects C++ RAII-style, so to be safe, we use __bridge_retained
        m_MetalDrawable = (__bridge_retained CA::MetalDrawable*)[m_MetalLayer nextDrawable];
    
        // in metal, a render pass is a collection of rendering commands that takes a set if input resources
        // like textures, buffers etc and processes them through the graphics pipeline to produce an output
        // tipically a rendered image.
        // to perform a render pass you create a Command Encoder using the configured Render Pass Descriptor
        // the encoder is responsible for encoding draw commands, setting the pipeline's state and providing
        // resources to the graphics pipeline.
        // once you have encoded all the GPU commands, you end the encoding process and the render pass
        // is executed on the GPU when the command is committed.
        
        // create a command buffer
        m_MetalCommandBuffer = m_MetalCommandQueue->commandBuffer();

        // hold a collection of attachments for pixels generated by a render pass
        MTL::RenderPassDescriptor* renderPassDescriptor = MTL::RenderPassDescriptor::alloc()->init();
        
        // specify the textures or render targets to store the results of the render pass
        MTL::RenderPassColorAttachmentDescriptor* cd = renderPassDescriptor->colorAttachments()->object(0);
        
        // give it the texture for our metal drawable
        cd->setTexture(m_MetalDrawable->texture());
        
        // set clear color (the initial color for all pixels in the buffer, acting as a "background color")
        cd->setLoadAction(MTL::LoadActionClear);
        cd->setClearColor(MTL::ClearColor(41.0f/255.0f, 42.0f/255.0f, 48.0f/255.0f, 1.0));
        
        // store that action in our metal drawable
        cd->setStoreAction(MTL::StoreActionStore);

        // encode render commands to a command buffer
        MTL::RenderCommandEncoder* renderCommandEncoder = m_MetalCommandBuffer->renderCommandEncoder(renderPassDescriptor);
        
        // before we encode any commands, we need to tell the command encoder which render pipeline to
        // process our commands in the context of.
        // we set the pipeline state to our previously created m_MetalRenderPSO object which defines
        // the triangle rendering pipeline
        renderCommandEncoder->setRenderPipelineState(m_MetalRenderPSO);
        
        // set the vertex buffer
        renderCommandEncoder->setVertexBuffer(m_TriangleVertexBuffer, 0, 0);
        
        // set the primitive type
        MTL::PrimitiveType typeTriangle = MTL::PrimitiveTypeTriangle;
        
        // specify the start vertex to draw triangles from, and the total count
        NS::UInteger vertexStart = 0;
        NS::UInteger vertexCount = 3;
        
        // now we tell it to draw the triangle
        renderCommandEncoder->drawPrimitives(typeTriangle, vertexStart, vertexCount);
        
        // once we are finished with our command, we end the encoding
        renderCommandEncoder->endEncoding();

        // tell the command buffer to present the drawable
        m_MetalCommandBuffer->presentDrawable(m_MetalDrawable);
        
        // send these commands to the GPU
        m_MetalCommandBuffer->commit();
        
        // tell the current thread to wait until the gpu does it's work
        m_MetalCommandBuffer->waitUntilCompleted();

        // release the render pass descriptor.
        renderPassDescriptor->release();
        
        // just to be sure, release the drawable since we are done
        m_MetalDrawable->release();
        m_MetalDrawable = nullptr;
    }
}

void Renderer::Cleanup()
{
    // this is all done to prevent memory leaks
    if (m_MetalRenderPSO)
    {
        m_MetalRenderPSO->release();
        m_MetalRenderPSO = nullptr;
    }
    
    if (m_TriangleVertexBuffer)
    {
        m_TriangleVertexBuffer->release();
        m_TriangleVertexBuffer = nullptr;
    }
    
    if (m_MetalCommandQueue)
    {
        m_MetalCommandQueue->release();
        m_MetalCommandQueue = nullptr;
    }
    
    if (m_MetalDefaultLibrary)
    {
        m_MetalDefaultLibrary->release();
        m_MetalDefaultLibrary = nullptr;
    }
    
    if (m_MetalDevice)
    {
        m_MetalDevice->release();
        m_MetalDevice = nullptr;
    }
    
    // m_MetalLayer is managed by Cocoa views, so no need to release it manually.
}
