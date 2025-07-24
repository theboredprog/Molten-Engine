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

#include "application/application.h"
#include "renderer/renderer-2D.h"
#include "renderer/sprite-2D.h"
#include "application/game.h"
#include "application/input.h"

#define LOG_CLIENT
#include "utils/log-macros.h"

//TODO: batch 2d sprites - make a decent 2d renderer - right now it's the most inefficent thing ever, reconstructing vertex data every frame; Ideally it would take all sprites in at once, create a spritesheet with all the images, gather all the data, make a huge buffer, send it to the gpu for drawing and only update this buffer when we want to change the positions of the sprites in the game - this keeps everything on the screen with only a single draw call, with minimal overhead.

//TODO: cleanup the code and comment on how it works - it's a mess rn.
//TODO: turn radians to degrees - much more understandable
//TODO: be able to use 2D spritesheets, specify index and get the appropriate texture.
//TODO: 2D blending (alpha blending)
//TODO: 2D depth sorting
//TODO: 2D animations
//TODO: 2D phisics
//TODO: entity component system
//TODO: audio
//TODO: make simple 2d game
//TODO: 3D model reading and importing
//TODO: 3D phisically based rendering
//TODO: user interface
//TODO: gizmos
//TODO: simple fx (gaussian blur, hdr, bloom, ssao, antialiasing)
//TODO: 3D phisics
//TODO: custom editor
//TODO: properly exporting and packaging
//TODO: raytracing/pathtracing
//TODO: custom ui
//TODO: custom maths lib
