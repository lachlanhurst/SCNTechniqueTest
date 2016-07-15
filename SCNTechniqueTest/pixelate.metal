//
//  pixelate.metal
//  SCNTechniqueTest
//
//  Created by Lachlan Hurst on 15/07/2016.
//  Copyright © 2016 Lachlan Hurst. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

struct custom_vertex_t
{
    float4 position [[attribute(SCNVertexSemanticPosition)]];
};

constexpr sampler s = sampler(coord::normalized,
                              address::repeat,
                              filter::nearest);

struct out_vertex_t
{
    float4 position [[position]];
    float2 uv;
};

vertex out_vertex_t pixelate_pass_through_vertex(custom_vertex_t in [[stage_in]],
                                                 constant SCNSceneBuffer& scn_frame [[buffer(0)]])
{
    out_vertex_t out;
    out.position = in.position;
    out.uv = float2((in.position.x + 1.0) * 0.5 , (in.position.y + 1.0) * -0.5);
    return out;
};

fragment half4 pixelate_pass_through_fragment(out_vertex_t vert [[stage_in]],
                                              texture2d<float, access::sample> colorSampler [[texture(0)]])
{
    float4 fragment_color = colorSampler.sample( s, vert.uv);
    return half4(fragment_color);
};

