
#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

struct custom_vertex_t
{
    float4 position [[attribute(SCNVertexSemanticPosition)]];
};

constexpr sampler s = sampler(coord::normalized,
                              address::repeat,
                              filter::linear);

struct out_vertex_t
{
    float4 position [[position]];
    float2 uv;
};

vertex out_vertex_t pass_through_vertex(custom_vertex_t in [[stage_in]])
{
    out_vertex_t out;
    out.position = in.position;
    out.uv = float2((in.position.x + 1.0) * 0.5 , (in.position.y + 1.0) * -0.5);
    return out;
};

fragment half4 pass_through_fragment(out_vertex_t vert [[stage_in]],
                                     texture2d<float, access::sample> colorSampler [[texture(0)]])
{
    float vStep = 0.02;
    float2 p2 = float2(vert.uv.x + 2.0 * vStep, vert.uv.y);
    float2 p1 = float2(vert.uv.x + 1.0 * vStep, vert.uv.y);
    float2 p0 = vert.uv;
    float2 n1 = float2(vert.uv.x - 1.0 * vStep, vert.uv.y);
    float2 n2 = float2(vert.uv.x - 2.0 * vStep, vert.uv.y);

    float4 v_p2 = colorSampler.sample( s , p2 ) * 0.1;
    float4 v_p1 = colorSampler.sample( s , p1 ) * 0.2;
    float4 v_p0 = colorSampler.sample( s , p0 ) * 0.4;
    float4 v_n1 = colorSampler.sample( s , n1 ) * 0.2;
    float4 v_n2 = colorSampler.sample( s , n2 ) * 0.1;

    float4 sum = v_p2 + v_p1 + v_p0 + v_n1 + v_n2;

    //float4 col = colorSampler.sample( s , vert.uv );

    return half4(sum);
};
