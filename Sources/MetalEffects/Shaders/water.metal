//
//  default_fragment.metal
//
//
//  Created by Tibor Felföldy on 2023-05-26.
//

// Original: https://www.shadertoy.com/view/MdX3zr

#include <metal_stdlib>
#include "fragment_type.h"
using namespace metal;

#define TAU 6.28318530718
#define MAX_ITER 5

float mod(float x, float y) {
    return x - y * floor(x / y);
}

fragment float4 water_fragment(constant FragmentParams &params [[buffer(0)]], VertexOut in [[stage_in]]) {
    
    float time = params.time / 2;
    
    float2 p = float2(mod(in.uv.x*TAU, TAU)-250.0, mod(in.uv.y*TAU, TAU)-250.0);
    
    float2 i = p;
    float c = 1.0;
    float inten = .005;
    
    for (int n = 0; n < MAX_ITER; n++)
    {
        float t = time * (1.0 - (3.5 / float(n+1)));
        i = p + float2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
        c += 1.0/length(float2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
    }
        
    c /= float(MAX_ITER);
    c = 1.17-pow(c, 1.4);
    float3 color = float3(pow(abs(c), 8.0));
    color = clamp(color, 0.0, 1.0);
    return float4(color, color.r);
}
