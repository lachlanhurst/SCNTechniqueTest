
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

// http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
constant float offset[] = { 0.0, 1.0, 2.0, 3.0, 4.0 };
constant float weight[] = { 0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162 };

fragment half4 pass_through_fragment_hori(out_vertex_t vert [[stage_in]],
                                          texture2d<float, access::sample> colorSampler [[texture(0)]])
{

    float4 FragmentColor = colorSampler.sample( s, vert.uv) * weight[0];
    for (int i=1; i<5; i++) {
        FragmentColor += colorSampler.sample( s, ( vert.uv + float2(offset[i], 0.0)/224.0 ) ) * weight[i];
        FragmentColor += colorSampler.sample( s, ( vert.uv - float2(offset[i], 0.0)/224.0 ) ) * weight[i];
    }
    return half4(FragmentColor);
}

fragment half4 pass_through_fragment_vert(out_vertex_t vert [[stage_in]],
                                     texture2d<float, access::sample> colorSampler [[texture(0)]])
{

    float4 FragmentColor = colorSampler.sample( s, vert.uv) * weight[0];
    for (int i=1; i<5; i++) {
        FragmentColor += colorSampler.sample( s, ( vert.uv + float2(0.0, offset[i])/224.0 ) ) * weight[i];
        FragmentColor += colorSampler.sample( s, ( vert.uv - float2(0.0, offset[i])/224.0 ) ) * weight[i];
    }
    return half4(FragmentColor);

};
