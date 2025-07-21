//
//  mtl_engine.hpp
//  MyApp
//
//  Created by Gabriele Vierti on 20/07/25.
//
//
//  mtl_engine.hpp
//  MyApp
//
//  Created by Gabriele Vierti on 20/07/25.
//

#pragma once
#define GLFW_INCLUDE_NONE
#import <GLFW/glfw3.h>

#include "renderer.hpp"

#include <memory>

class Application
{
private:

    bool initWindow();

    GLFWwindow* m_GlfwWindow;
    
    int m_Width;
    int m_Height;
    const char* m_Title;
    
    std::unique_ptr<Renderer> m_Renderer;
    
public:
    
    Application(int width, int height, const char* title);
    
    void Init();
    
    void Run();
    
    void Cleanup();
};
