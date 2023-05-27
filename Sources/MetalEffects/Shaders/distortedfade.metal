//
//  default_fragment.metal
//
//
//  Created by Tibor Felföldy on 2023-05-26.
//

// Original: https://www.shadertoy.com/view/ltlBzn

#include <metal_stdlib>
#include "fragment_type.h"
using namespace metal;

#define TAU 6.28318530718
#define MAX_ITER 5

constexpr sampler textureSampler;

fragment float4 distorted_fade(constant FragmentParams &params [[buffer(0)]], VertexOut in [[stage_in]], texture2d<float> texture_in [[texture(0)]]) {
    float2 uv = in.uv;
    
    float th = sin(params.time) / 2 + 0.5;
    
    float tex = ((0.3 -.5) + 2. * uv.x ) / 3.;
    float mask = smoothstep( th - .1, th, tex);
    float dist = smoothstep( th - .3, th + .05, tex);
    float col = pow( smoothstep( th - .2, th + .15, tex), 3.);

    
    float3 color = texture_in.sample(textureSampler, uv * (.7 + pow(dist, 2.) * .3 )).rgb;
    float3 discolor = color * float3( 0.8, 0.4, 0.2 );
    
    return float4(mix(discolor, color, col) * mask, 1.0);
}
