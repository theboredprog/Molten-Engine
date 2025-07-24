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

#include "input.h"

#include <GLFW/glfw3.h>

#include "../utils/log-macros.h"

int Input::MapKeycodeToGLFW(Keycode key)
{
    return static_cast<int>(key);
}

GLFWwindow* Input::s_Window = nullptr;
std::unordered_map<int, bool> Input::s_KeysDown;
std::unordered_map<int, bool> Input::s_KeysUp;
std::unordered_map<int, bool> Input::s_KeysHeld;

void Input::Initialize(GLFWwindow* window)
{
    s_Window = window;
    glfwSetKeyCallback(window, KeyCallback);
}

void Input::KeyCallback(GLFWwindow* window, int key, int scancode, int action, int mods)
{
    if (action == GLFW_PRESS)
    {
        s_KeysDown[key] = true;
        s_KeysHeld[key] = true;
    }
    else if (action == GLFW_RELEASE)
    {
        s_KeysUp[key] = true;
        s_KeysHeld[key] = false;
    }
}

void Input::Update()
{
    // Clear keys down/up at the start of each frame
    s_KeysDown.clear();
    s_KeysUp.clear();
}

bool Input::GetKeyDown(Keycode key)
{
    int glfwKey = MapKeycodeToGLFW(key);
    if (glfwKey == -1) return false;
    return s_KeysDown[glfwKey];
}

bool Input::GetKeyUp(Keycode key)
{
    int glfwKey = MapKeycodeToGLFW(key);
    if (glfwKey == -1) return false;
    return s_KeysUp[glfwKey];
}

bool Input::GetKeyHeld(Keycode key)
{
    int glfwKey = MapKeycodeToGLFW(key);
    if (glfwKey == -1) return false;
    return s_KeysHeld[glfwKey];
}
