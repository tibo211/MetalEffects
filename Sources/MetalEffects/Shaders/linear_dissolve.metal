//
//  linear_dissolve.metal
//
//
//  Created by Tibor Felföldy on 2023-05-28.
//

#include <metal_stdlib>
#include "fragment_type.h"
using namespace metal;

constant float EDGE_WIDTH = 0.01;

constexpr sampler textureSampler;

fragment float4 linear_dissolve(constant FragmentParams &params [[buffer(0)]], VertexOut in [[stage_in]], texture2d<float> texture_in [[texture(0)]]) {
    float dissolve = 1 - fract(params.time / 3);
    
    float alpha = 1;
    
    if (dissolve > in.uv.y) {
        alpha = 0;
    }
    
    float3 color = texture_in.sample(textureSampler, in.uv).rgb;
    
    float edge = 1 - step(dissolve, in.uv.y - EDGE_WIDTH);
    
    color = mix(color, float3(0, 1, 0), edge);
    
    // TODO: This won't be needed after transparency is fixed.
    color = mix(float3(0), color, alpha);
        
    return float4(color, alpha);
}
