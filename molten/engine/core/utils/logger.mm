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

#include "logger.hpp"
#include <spdlog/sinks/stdout_color_sinks.h>

std::shared_ptr<spdlog::logger> Logger::s_CoreLogger;
std::shared_ptr<spdlog::logger> Logger::s_ClientLogger;

void Logger::Init()
{
    spdlog::set_pattern("%^[%T] %n: %v%$"); // Color, timestamp, logger name, message

    s_CoreLogger = spdlog::stdout_color_mt("CORE");
    s_CoreLogger->set_level(spdlog::level::trace);

    s_ClientLogger = spdlog::stdout_color_mt("CLIENT");
    s_ClientLogger->set_level(spdlog::level::trace);
}

std::shared_ptr<spdlog::logger>& Logger::Core() { return s_CoreLogger; }

std::shared_ptr<spdlog::logger>& Logger::Client() { return s_ClientLogger; }
