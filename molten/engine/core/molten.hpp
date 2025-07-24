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

#include "application/application.hpp"
#include "renderer/renderer-2D.hpp"
#include "renderer/sprite-2D.hpp"
#include "application/game.hpp"

#define LOG_CLIENT
#include "utils/log-macros.hpp"

//TODO: fix this batch renderer color thing. please.
//TODO: organize this better - it's a mess to make a game like this, interacting with the renderer directly etc managing the app etc..
//TODO: turn radians to degrees - much more understandable
//TODO: batch 2d sprites - make a decent 2d renderer (this also includes creating the data directly in the renderer, not the sprite)
//TODO: be able to use 2D spritesheets, specify index and get the appropriate texture.
//TODO: 2D animations
//TODO: 2D phisics
//TODO: entity component system
//TODO: scripting with c++ api
//TODO: audio
//TODO: make simple 2d game
//TODO: 3D model importing
//TODO: phisically based rendering
//TODO: simple fx
//TODO: 3D phisics
//TODO: gizmos
//TODO: editor
//TODO: properly exporting and packaging
//TODO: raytracing/pathtracing
