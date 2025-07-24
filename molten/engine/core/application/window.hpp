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

#import <AppKit/NSWindow.h>

class GLFWwindow;

namespace MTL { class Device; }
namespace CA { class MetalLayer; }

class Window
{
private:
    
    unsigned int m_Width;
    unsigned int m_Height;
    
    const char* m_Title;
    
    GLFWwindow* m_InternalWindow;
    NSWindow* m_MetalWindow;
    
    MTL::Device* m_MetalDevice;
    CA::MetalLayer* m_MetalLayer;
    
    static void frameBufferSizeCallback(GLFWwindow *window, int width, int height);
    
    bool InitGlfw();
    
public:
    
    explicit Window(unsigned int width, unsigned int height, const char* title);
    
    bool isOpen();
    
    void HandleInputEvents();
    
    void Close();
    
    inline unsigned int GetWidth() const { return m_Width; }
    
    inline unsigned int GetHeight() const { return m_Height; }
    
    inline void SetWidth(unsigned int width) { m_Width = width; }
    
    inline void SetHeight(unsigned int height) { m_Height = height; }
    
    inline GLFWwindow* GetInternalWindow() const { return m_InternalWindow; }
    
    inline NSWindow* GetMetalWindow() const { return m_MetalWindow; }
    
    inline MTL::Device* GetMetalDevice() const { return m_MetalDevice; }
    
    inline CA::MetalLayer* GetMetalLayer() const { return m_MetalLayer; }

    inline void SetMetalDevice(MTL::Device* device) { m_MetalDevice = device; }

    inline void SetMetalLayer(CA::MetalLayer* layer) { m_MetalLayer = layer; }
};
