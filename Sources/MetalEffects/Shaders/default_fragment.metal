//
//  default_fragment.metal
//
//
//  Created by Tibor Felföldy on 2023-05-26.
//

#include <metal_stdlib>
#include "fragment_type.h"
using namespace metal;

constexpr sampler textureSampler;

fragment float4 default_fragment(constant FragmentParams &params [[buffer(0)]], VertexOut in [[stage_in]], texture2d<float> texture_in [[texture(0)]]) {
    float3 color = texture_in.sample(textureSampler, in.uv).rgb;
    return float4(color, 1);
}
