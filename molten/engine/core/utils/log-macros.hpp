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

#pragma once

#include <cassert>
#include "logger.hpp"

#ifndef LOG_CLIENT

#define LOG_CORE_TRACE(...)    Logger::Core()->trace(__VA_ARGS__)
#define LOG_CORE_INFO(...)     Logger::Core()->info(__VA_ARGS__)
#define LOG_CORE_WARN(...)     Logger::Core()->warn(__VA_ARGS__)
#define LOG_CORE_ERROR(...)    Logger::Core()->error(__VA_ARGS__)
#define LOG_CORE_CRITICAL(...) Logger::Core()->critical(__VA_ARGS__)

#else

#define LOG_TRACE(...)         Logger::Client()->trace(__VA_ARGS__)
#define LOG_INFO(...)          Logger::Client()->info(__VA_ARGS__)
#define LOG_WARN(...)          Logger::Client()->warn(__VA_ARGS__)
#define LOG_ERROR(...)         Logger::Client()->error(__VA_ARGS__)
#define LOG_CRITICAL(...)      Logger::Client()->critical(__VA_ARGS__)

#endif

#ifdef NDEBUG
    #define CORE_ASSERT(x, ...) (void)0
    #define ASSERT(x, ...)      (void)0
#else
    #define CORE_ASSERT(x, ...) \
        if (!(x)) { \
            LOG_CORE_CRITICAL(__VA_ARGS__); \
            assert(x); \
        }

    #define ASSERT(x, ...) \
        if (!(x)) { \
            LOG_CRITICAL(__VA_ARGS__); \
            assert(x); \
        }
#endif
