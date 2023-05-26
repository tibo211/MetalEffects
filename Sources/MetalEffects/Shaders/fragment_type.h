//
//  Header.h
//  
//
//  Created by Tibor Felföldy on 2023-05-26.
//

#ifndef Header_h
#define Header_h

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

struct FragmentParams {
    float time;
};

#endif /* Header_h */
