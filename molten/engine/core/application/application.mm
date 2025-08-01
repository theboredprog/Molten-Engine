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

#include "application.h"

#include <simd/simd.h>

#include <GLFW/glfw3.h>

#include "window.h"
#include "../utils/logger.h"

#include "../utils/log-macros.h"

#include "../renderer/renderer-2D.h"

#include "game.h"

#include "input.h"

Application::Application(unsigned int width, unsigned int height, const char* title, Game* game)
: m_Window(new Window(width, height, title)), m_Game(game)
{
    Input::Initialize(m_Window->GetInternalWindow());
    
    Logger::Init();
    
    m_Renderer = new Renderer2D(m_Window);
    
    if (m_Game) m_Game->SetApplication(this);
    if (m_Game) m_Game->OnStart();
    
    m_Renderer->PrepareRenderingData();
}

void Application::Run()
{
    double lastTime = glfwGetTime();
    
    while (m_Window->isOpen())
    {
        m_Window->HandleInputEvents();
        m_Renderer->PrepareRenderingData();
        
        double currentTime = glfwGetTime();
        float deltaTime = static_cast<float>(currentTime - lastTime);
        lastTime = currentTime;

        if (m_Game)
            m_Game->OnUpdate(deltaTime);
        
        @autoreleasepool
        {
            int width, height;
            glfwGetWindowSize(m_Window->GetInternalWindow(), &width, &height);
            
            if (width != m_Window->GetWidth() || height != m_Window->GetHeight())
            {
                m_Window->SetWidth(width);
                m_Window->SetHeight(height);
                
                //TODO: update renderer proj matrix.
                m_Renderer->UpdateProjMatrix(width, height);
            }
            
            m_Renderer->IssueRenderCall();
        }
    }
    
    if (m_Game) m_Game->OnShutdown();
}

Application::~Application()
{
    if(m_Window) delete m_Window;

    if(m_Renderer)
    {
        m_Renderer->Cleanup();
        delete m_Renderer;
    }
}
