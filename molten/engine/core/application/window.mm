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

#include "window.hpp"

#define GLFW_INCLUDE_NONE
#import <GLFW/glfw3.h>

#define GLFW_EXPOSE_NATIVE_COCOA
#import <GLFW/glfw3native.h>

#include <Metal/Metal.h>
#include <Metal/Metal.hpp>

#include <QuartzCore/CAMetalLayer.h>
#include <QuartzCore/CAMetalLayer.hpp>

#include "../utils/log-macros.hpp"
#include "application.hpp"
#include "input.hpp"

void glfwErrorCallback(int error, const char* description)
{
    LOG_CORE_ERROR("({}): {}", error, description);
}

void Window::frameBufferSizeCallback(GLFWwindow *window, int width, int height)
{
    auto win = static_cast<Window*>(glfwGetWindowUserPointer(window));
    
    if (win && win->m_MetalLayer)
    {
        win->m_MetalLayer->setDrawableSize(CGSizeMake(width, height));
    }
}

bool Window::InitGlfw()
{
    if(!glfwInit())
    {
        CORE_ASSERT(false, "Failed to initialize GLFW.");
        glfwTerminate();
        return false;
    }
    
    glfwSetErrorCallback(glfwErrorCallback);
    
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    
    m_InternalWindow = glfwCreateWindow(m_Width, m_Height, m_Title, NULL, NULL);
    
    if (!m_InternalWindow)
    {
        CORE_ASSERT(false, "Failed to create GLFW window.");
        glfwTerminate();
        return false;
    }
    
    int width;
    int height;
    
    glfwGetFramebufferSize(m_InternalWindow, &width, &height);
    
    glfwSetWindowUserPointer(m_InternalWindow, this);
    glfwSetFramebufferSizeCallback(m_InternalWindow, frameBufferSizeCallback);
    
    m_MetalWindow = glfwGetCocoaWindow(m_InternalWindow);
    if (!m_MetalWindow)
    {
        CORE_ASSERT(false, "Failed to get native NSWindow from GLFW.");
        return false;
    }
    
    m_MetalDevice = MTL::CreateSystemDefaultDevice();
    if (!m_MetalDevice)
    {
        CORE_ASSERT(false, "Failed to create Metal device.");
        return false;
    }
    
    m_MetalLayer = CA::MetalLayer::layer();
    if (!m_MetalLayer)
    {
        CORE_ASSERT(false, "Failed to create CAMetalLayer.");
        return false;
    }
    
    m_MetalLayer->setDevice(m_MetalDevice);
    m_MetalLayer->setPixelFormat(MTL::PixelFormat::PixelFormatBGRA8Unorm);
    m_MetalLayer->setDrawableSize(CGSizeMake(width, height));
    
    m_MetalWindow.contentView.wantsLayer = YES;
    m_MetalWindow.contentView.layer = (__bridge CALayer*)m_MetalLayer;
    
    return true;
}

Window::Window(unsigned int width, unsigned int height, const char* title)
: m_Width(width), m_Height(height), m_Title(title) { InitGlfw(); }

bool Window::isOpen()
{
    return !glfwWindowShouldClose(m_InternalWindow);
}

void Window::HandleInputEvents()
{
    glfwPollEvents();
    Input::Update();
}

void Window::Close()
{
    glfwDestroyWindow(m_InternalWindow);
    glfwTerminate();
}
