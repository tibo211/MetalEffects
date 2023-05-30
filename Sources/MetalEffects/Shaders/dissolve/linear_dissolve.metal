//
//  linear_dissolve.metal
//
//
//  Created by Tibor Felföldy on 2023-05-28.
//

#include <metal_stdlib>
#include "../fragment_type.h"
using namespace metal;

constant float EDGE_WIDTH = 0.02;

constexpr sampler textureSampler;

fragment float4 linear_dissolve(constant FragmentParams &params [[buffer(0)]], VertexOut in [[stage_in]], texture2d<float> texture_in [[texture(0)]]) {
    float dissolve = fract(params.time / 3);
    
    float alpha = 1;
    if (dissolve > in.uv.y) {
        alpha = 0;
    }
    
    float4 sample = texture_in.sample(textureSampler, in.uv);
    
    float edge = 1 - step(dissolve, in.uv.y - EDGE_WIDTH);
    
    float3 color = mix(sample.rgb, float3(0, 1, 0), edge);
        
    return float4(color.rgb, sample.a * alpha);
}
