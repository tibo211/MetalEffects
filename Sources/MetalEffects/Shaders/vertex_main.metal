//
//  vertex_main.metal
//
//
//  Created by Tibor Felföldy on 2023-05-26.
//

#include <metal_stdlib>
#include "fragment_type.h"
using namespace metal;

vertex VertexOut vertex_main(const device float2 *vertex_in [[buffer(0)]], unsigned int vid[[vertex_id]]) {
    float2 v = vertex_in[vid];
    VertexOut out;
    out.position = float4(v.x, v.y, 0, 1);
    // Update the positions to 0...1 from -1...1.
    float2 uv = (v + 1) / 2;
    // Invert y axis.
    out.uv = float2(uv.x, 1 - uv.y);
    return out;
}
