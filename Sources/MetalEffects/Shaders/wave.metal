//
//  default_fragment.metal
//
//
//  Created by Tibor Felföldy on 2023-05-26.
//

// Original: https://www.shadertoy.com/view/Xsc3z2

#include <metal_stdlib>
#include "fragment_type.h"
using namespace metal;

#define TAU 6.28318530718
#define MAX_ITER 5

constexpr sampler textureSampler;

fragment float4 wave_fragment(constant FragmentParams &params [[buffer(0)]], VertexOut in [[stage_in]], texture2d<float> texture_in [[texture(0)]]) {
    float waveStrength = 0.02;
    float frequency = 30.0;
    float waveSpeed = 5.0;
    float4 sunlightColor = float4(1.0,0.91,0.75, 1.0);
    float sunlightStrength = 5.0;
    float centerLight = 2.;
    float oblique = .25;
    
    float2 tapPoint = float2(0.5);
    
    float2 uv = in.uv;
    float modifiedTime = params.time * waveSpeed;
    
    // Calculate the aspect ratio?
    float aspectRatio = 1;
    
    float2 distVec = uv - tapPoint;
    distVec.x *= aspectRatio;
    float distance = length(distVec);
    
    float multiplier = (distance < 1.0) ? ((distance-1.0)*(distance-1.0)) : 0.0;
    float addend = (sin(frequency*distance-modifiedTime)+centerLight) * waveStrength * multiplier;
    float2 newTexCoord = uv + addend*oblique;
    
    float4 colorToAdd = sunlightColor * sunlightStrength * addend;
    
    return texture_in.sample(textureSampler, newTexCoord) + colorToAdd;
}
