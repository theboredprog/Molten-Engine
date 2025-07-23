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

#include <simd/simd.h>

#include <GLFW/glfw3.h>

#include "application.hpp"
#include "../renderer/renderer-2D.hpp"
#include "window.hpp"
#include "../utils/logger.hpp"
#include "../utils/log-macros.hpp"

Application::Application(unsigned int width, unsigned int height, const char* title)
: m_Window(new Window(width, height, title)), m_LastWidth(width), m_LastHeight(height)
{
    Logger::Init();
    
    m_Renderer2D = new Renderer2D(m_Window);
}

bool Application::Init()
{
    return true;
}

void Application::Run()
{
    m_Renderer2D->PrepareRenderingData();

        while (m_Window->isOpen())
        {
            @autoreleasepool
            {
                int width, height;
                glfwGetWindowSize(m_Window->GetInternalWindow(), &width, &height);

                if (width != m_LastWidth || height != m_LastHeight)
                {
                    m_LastWidth = width;
                    m_LastHeight = height;
                    m_Renderer2D->UpdateProjMatrix(width,height);
                }

                m_Renderer2D->IssueRenderCall();
            }

            m_Window->HandleInputEvents();
        }
}

Application::~Application()
{
    if (m_Renderer2D) delete m_Renderer2D;
    
    if(m_Window) delete m_Window;
}
