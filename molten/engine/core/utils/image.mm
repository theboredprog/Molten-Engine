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

#include "image.hpp"

#define STB_IMAGE_IMPLEMENTATION
#include "../../third_party/stbi/stbi-image.h"

#include <iostream>
#include <cassert>

Image::Image(const char* filepath)
: m_Filepath(filepath), m_Data(nullptr), m_Width(0), m_Height(0), m_Channels(0)
{
    stbi_set_flip_vertically_on_load(true);
    m_Data = stbi_load(filepath, &m_Width, &m_Height, &m_Channels, STBI_rgb_alpha);

    if (!m_Data)
    {
        std::cerr << "[ERROR] Failed to load image: " << filepath << std::endl;
        m_Width = m_Height = m_Channels = 0;
    }
}

Image::~Image()
{
    stbi_image_free(m_Data);
}
