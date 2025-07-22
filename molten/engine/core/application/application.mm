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

#include "application.hpp"

#include "../renderer/metal/renderer-2D.hpp"

#include <iostream>

Application::Application(unsigned int width, unsigned int height, const char* title)
: m_Width(width), m_Height(height), m_Title(title), m_Window(new InternalWindow(m_Width, m_Height, m_Title))
{
    /*m_Renderer = new Renderer(m_Window->GetInternalWindow());
    
    if(!m_Renderer->Init(width, height))
    {
        std::cerr << "[ERROR] Failed to initialize the renderer." << std::endl;
        m_Window->Close();
        return;
    }

    m_Renderer->PrepareRenderingData();*/
}

bool Application::Init()
{
    return true;
}

void Application::Run()
{
    while (m_Window->isOpen())
    {
        @autoreleasepool
        {
            //m_Renderer->Render();
        }
        
        m_Window->HandleInputEvents();
    }
}

void Application::Cleanup()
{
    /*if (m_Renderer)
    {
        m_Renderer->Cleanup();
        delete m_Renderer;
    }*/
    
    if(m_Window)
    {
        delete m_Window;
    }
}
