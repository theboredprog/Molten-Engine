//
//  mtl_engine.mm
//  MyApp
//
//  Created by Gabriele Vierti on 20/07/25.
//

#include "application.hpp"

#include <iostream>

#define GLFW_EXPOSE_NATIVE_COCOA
#import <GLFW/glfw3native.h>

void glfwErrorCallback(int error, const char* description)
{
    std::cerr << "[GLFW ERROR] (" << error << "): " << description << std::endl;
}

bool Application::initWindow()
{
    glfwSetErrorCallback(glfwErrorCallback);
    
    if(!glfwInit())
    {
        std::cerr << "[ERROR] Failed to initialize GLFW." << std::endl;
        glfwTerminate();
        return false;
    }
    
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    
    m_GlfwWindow = glfwCreateWindow(m_Width, m_Height, m_Title, NULL, NULL);
    
    if (!m_GlfwWindow)
    {
        std::cerr << "[ERROR] Failed to create GLFW window." << std::endl;
        glfwTerminate();
        return false;
    }
    
    int width, height; // width and height of the framebuffer
    glfwGetFramebufferSize(m_GlfwWindow, &width, &height); // set the variables to the size of the framebuffer
    
    // make unique to better control the lifetime
    m_Renderer = std::make_unique<Renderer>(glfwGetCocoaWindow(m_GlfwWindow));
    
    if(!m_Renderer->Init(width, height))
    {
        std::cerr << "[ERROR] Failed to initialize the renderer." << std::endl;
        m_Renderer.reset(); // auto deletes
        glfwDestroyWindow(m_GlfwWindow);
        glfwTerminate();
        return false;
    }

    // prepare the data to draw the triangle
    m_Renderer->PrepareRenderingData();
    
    return true;
}

Application::Application(const int width, const int height, const char* title)
: m_Width(width), m_Height(height), m_Title(title) {}

void Application::Init()
{
    if(!initWindow())
    {
        std::cerr << "[ERROR] Failed to initialize the window." << std::endl;
        glfwDestroyWindow(m_GlfwWindow);
        glfwTerminate();
        return;
    }
}

void Application::Run()
{
    while (!glfwWindowShouldClose(m_GlfwWindow))
    {
        @autoreleasepool
        {
            m_Renderer->Render();
        }
        glfwPollEvents();
    }
}

void Application::Cleanup()
{
    if (m_Renderer)
    {
        m_Renderer->Cleanup();
    }
    
    glfwTerminate();
}
