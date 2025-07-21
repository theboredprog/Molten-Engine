//
//  triangle-shader.metal
//  MyApp
//
//  Created by Gabriele Vierti on 21/07/25.
//

// shader programs run concurrently on the gpu so each vertex input will be processed simultaneously, reason why we need
// a vertexID to know which vertex we are working on
// since we have 3 vertices, we'll have three instances of the vertex shader running at the same time
// the second input is the vertexPositions buffer, containing the position of our vertices
// the constant - keyword is called and "address space name" to tell the gpu to keep the vertex positions buffer in
// non-modifiable, read only memory - since we aren't going to change this data, this speeds up things as well.
// you can read more about address space names here in section 4.0: https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf
// we'll use the vertexID to index the appropriate vertex per shader and we are going to cast our vertexPositions buffer to a vector type of float4, since vertex functions are required to output positions in 4 dimensional clip-space coords.
// here is an excellent write up on why that's necessary: https://learnopengl.com/Getting-started/Transformations
// in short:
// In Metal (and most modern graphics APIs), the vertex shader must output a position in clip-space, which is a 4D vector (float4), not just 2D or 3D. This is because the GPU needs:
// X, Y, Z → for positioning in 3D space.
// W → for perspective division: after processing, the GPU divides x, y, z by w to transform the position from clip-space to normalized device coordinates (NDC).
// This step enables effects like perspective (farther objects appear smaller) and is essential for correct rasterization.
// So, we cast to float4 to:
// - match the required return type of the vertex function,
// - ensure proper perspective handling and rendering.
// float4 is required because Metal’s vertex shaders must output clip-space coordinates, and clip-space is a 4D space used for correct perspective projection and rasterization.

#include <metal_stdlib>
using namespace metal;

// struct that holds our input stuff passed from the cpu
// as shaders grow, this is the correct way to pass multiple inputs into the shader
struct VertexOut
{
    float4 position [[position]]; // must mark which float4 is position!
};

// tell metal this is the vertex shader
vertex VertexOut vertexShader(uint vertexID [[vertex_id]], constant float3* vertexPositions)
{
    VertexOut out;
    
    out.position = float4(vertexPositions[vertexID], 1.0);
    
    return out;
}

// tell metal this is our fragment shader
fragment float4 fragmentShader(VertexOut in [[stage_in]])
{
    float4 mintColor = float4(1.0, 0.5, 0.2, 1.0);

    return mintColor;
}

