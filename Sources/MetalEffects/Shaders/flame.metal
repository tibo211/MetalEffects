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

constexpr sampler textureSampler;

float noise(float3 p) {
    float3 i = floor(p);
    float4 a = dot(i, float3(1., 57., 21.)) + float4(0., 57., 21., 78.);
    float3 f = cos((p-i)*acos(-1.))*(-.5)+.5;
    a = mix(sin(cos(a)*a),sin(cos(1.+a)*(1.+a)), f.x);
    a.xy = mix(a.xz, a.yw, f.y);
    return mix(a.x, a.y, f.z);
}

float sphere(float3 p, float4 spr) {
    return length(spr.xyz-p) - spr.w;
}

float flame(float3 p, float time) {
    float d = sphere(p*float3(1.,0.5,0.7), float4(.0,-1.,.0,1.));
    return d + (noise(p+float3(.0,time*2.,.0)) + noise(p*3.)*.5)*.25*(p.y);
}

float scene(float3 p, float time) {
    return min(100.-length(p) , abs(flame(p, time)) );
}

float4 raymarch(float3 org, float3 dir, float time) {
    float d = 0.0, glow = 0.0, eps = 0.02;
    float3  p = org;
    bool glowed = false;
    
    for(int i=0; i<64; i++)
    {
        d = scene(p, time) + eps;
        p += d * dir;
        if( d>eps )
        {
            if(flame(p, time) < .0)
                glowed=true;
            if(glowed)
                glow = float(i)/64.;
        }
    }
    return float4(p,glow);
}

fragment float4 flame_fragment(constant FragmentParams &params [[buffer(0)]], VertexOut in [[stage_in]], texture2d<float> texture_in [[texture(0)]]) {
    float color = texture_in.sample(textureSampler, in.uv).r;
    
    float time = params.time;
    
    float2 v = in.uv * 2 - 1;
    v.y = 1 - v.y;
    float3 org = float3(0., -2., 4.);
    float3 dir = normalize(float3(v.x*1.6, -v.y, -1.5));
    
    float4 p = raymarch(org, dir, time);
    float glow = p.w;
        
    float4 col = mix(float4(1.,.5,.1,1.), float4(0.1,.5,1.,1.), p.y*.02+.4) * color;

    return mix(float4(0.), col, pow(glow*2.,4.));
}
