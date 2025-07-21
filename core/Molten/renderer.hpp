//
//  renderer.h
//  MyApp
//
//  Created by Gabriele Vierti on 21/07/25.
//

#include <Metal/Metal.h>
#include <QuartzCore/CAMetalLayer.h>
#include <Metal/Metal.hpp>
#include <QuartzCore/CAMetalLayer.hpp>

#import <AppKit/AppKit.h>

class Renderer
{
private:
    
    MTL::Device* m_MetalDevice;
    
    CAMetalLayer* m_MetalLayer;
    
    NSWindow* m_MetalWindow;
    
    // triangle stuff
    MTL::Buffer* m_TriangleVertexBuffer;
    MTL::Library* m_MetalDefaultLibrary;
    MTL::CommandQueue* m_MetalCommandQueue;
    MTL::RenderPipelineState* m_MetalRenderPSO;
    CA::MetalDrawable* m_MetalDrawable;
    MTL::CommandBuffer* m_MetalCommandBuffer;
    
public:
    
    Renderer(NSWindow* window);
    
    bool Init(int width, int height);
    
    void Render();
    void Cleanup();
    
    // helper function for the example
    void PrepareRenderingData();
    
    inline MTL::Device* getMetalDevice() { return m_MetalDevice; }
    inline CAMetalLayer* getMetalLayer() { return m_MetalLayer; }
};
