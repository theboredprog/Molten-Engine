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

#include <iostream>

#define GLFW_INCLUDE_NONE
#import <GLFW/glfw3.h>

#define GLFW_EXPOSE_NATIVE_COCOA
#import <GLFW/glfw3native.h>

void glfwErrorCallback(int error, const char* description)
{
    std::cerr << "[GLFW ERROR] (" << error << "): " << description << std::endl;
}

bool Window::InitGLFW()
{
    if(!glfwInit())
    {
        std::cerr << "[ERROR] Failed to initialize GLFW." << std::endl;
        glfwTerminate();
        return false;
    }
    
    glfwSetErrorCallback(glfwErrorCallback);
    
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    
    m_InternalWindow = glfwCreateWindow(m_Width, m_Height, m_Title, NULL, NULL);
    
    if (!m_InternalWindow)
    {
        std::cerr << "[ERROR] Failed to create GLFW window." << std::endl;
        glfwTerminate();
        return false;
    }
    
    int width, height;
    glfwGetFramebufferSize(m_InternalWindow, &width, &height);
    
    m_MetalWindow = glfwGetCocoaWindow(m_InternalWindow);
    if (!m_MetalWindow)
    {
        std::cerr << "[ERROR] Failed to get native NSWindow from GLFW." << std::endl;
        return false;
    }
    
    return true;
}

Window::Window(unsigned int width, unsigned int height, const char* title)
: m_Width(width), m_Height(height), m_Title(title) { InitGLFW(); }

bool Window::isOpen()
{
    return !glfwWindowShouldClose(m_InternalWindow);
}

void Window::HandleInputEvents()
{
    glfwPollEvents();
}

void Window::Close()
{
    glfwDestroyWindow(m_InternalWindow);
    glfwTerminate();
}
