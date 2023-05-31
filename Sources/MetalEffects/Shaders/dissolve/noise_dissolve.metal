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
    if (bottom.a == 0) {
        return top;
    }
    return top * top.a + bottom * (1-top.a);
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

float blur(float value,
           texture2d<float> noise,
           texture2d<float> texture,
           float2 uv) {
    float blurSize = 0.002;
    
    float sum = 0;
    sum += noise_edge(value, noise, texture, float2(uv.x - 4.0 * blurSize, uv.y)) * 0.05;
    sum += noise_edge(value, noise, texture, float2(uv.x - 3.0 * blurSize, uv.y)) * 0.09;
    sum += noise_edge(value, noise, texture, float2(uv.x - 2.0 * blurSize, uv.y)) * 0.12;
    sum += noise_edge(value, noise, texture, float2(uv.x - blurSize, uv.y)) * 0.15;
    sum += noise_edge(value, noise, texture, float2(uv.x, uv.y)) * 0.16;
    sum += noise_edge(value, noise, texture, float2(uv.x + blurSize, uv.y)) * 0.15;
    sum += noise_edge(value, noise, texture, float2(uv.x + 2.0 * blurSize, uv.y)) * 0.12;
    sum += noise_edge(value, noise, texture, float2(uv.x + 3.0 * blurSize, uv.y)) * 0.09;
    sum += noise_edge(value, noise, texture, float2(uv.x + 4.0 * blurSize, uv.y)) * 0.05;
    
    sum += noise_edge(value, noise, texture, float2(uv.x, uv.y - 4.0 * blurSize)) * 0.05;
    sum += noise_edge(value, noise, texture, float2(uv.x, uv.y - 3.0 * blurSize)) * 0.09;
    sum += noise_edge(value, noise, texture, float2(uv.x, uv.y - 2.0 * blurSize)) * 0.12;
    sum += noise_edge(value, noise, texture, float2(uv.x, uv.y - blurSize)) * 0.15;
    sum += noise_edge(value, noise, texture, float2(uv.x, uv.y)) * 0.16;
    sum += noise_edge(value, noise, texture, float2(uv.x, uv.y + blurSize)) * 0.15;
    sum += noise_edge(value, noise, texture, float2(uv.x, uv.y + 2.0 * blurSize)) * 0.12;
    sum += noise_edge(value, noise, texture, float2(uv.x, uv.y + 3.0 * blurSize)) * 0.09;
    sum += noise_edge(value, noise, texture, float2(uv.x, uv.y + 4.0 * blurSize)) * 0.05;
    
    return sum;
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
    
    float edge_value = noise_edge(dissolve, noise_texture, texture_in, in.uv);
    float edge_blur = blur(dissolve, noise_texture, texture_in, in.uv);
    float4 edge_color = mix(float4(1, 1, 0, edge_blur), float4(1, 1, 1, 1), edge_value);
    
    return overlay(color, edge_color);
}
