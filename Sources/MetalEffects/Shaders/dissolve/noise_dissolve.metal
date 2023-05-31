//
//  noise_dissolve.metal
//
//
//  Created by Tibor Felföldy on 2023-05-28.
//

#include <metal_stdlib>
#include "../fragment_type.h"
using namespace metal;

constant float EDGE_WIDTH = 0.02;

constexpr sampler textureSampler;

float4 overlay(float4 bottom, float4 top) {
    return top*top.a + bottom*(1-top.a);
}

float noise_edge(float value,
                 texture2d<float> noise_texture,
                 texture2d<float> texture,
                 float2 uv) {
    if (texture.sample(textureSampler, uv).a == 0) {
        return 0;
    }
    float dissolveValue = noise_texture.sample(textureSampler, uv).r * 2;
    if (value > dissolveValue) {
        return 0;
    }
    return 1 - step(value, dissolveValue - EDGE_WIDTH);
}

fragment float4 noise_dissolve(constant FragmentParams &params [[buffer(0)]],
                               VertexOut in [[stage_in]],
                               texture2d<float> texture_in [[texture(0)]],
                               texture2d<float> noise_texture [[texture(1)]]) {
    float dissolve = params.time;
    
    float dissolveValue = noise_texture.sample(textureSampler, in.uv).r * 2;
    float4 color = texture_in.sample(textureSampler, in.uv);
    
    if (dissolve > dissolveValue) {
        color.a = 0;
    }
    
    float4 edge_color = noise_edge(dissolve, noise_texture, texture_in, in.uv) * float4(0, 1, 0, 1);
    
    return overlay(color, edge_color);
}
