
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
    float sinTime;
};

vertex out_vertex_t pass_through_vertex(custom_vertex_t in [[stage_in]],
                                        constant SCNSceneBuffer& scn_frame [[buffer(0)]])
{
    out_vertex_t out;
    out.position = in.position;
    out.uv = float2((in.position.x + 1.0) * 0.5 , (in.position.y + 1.0) * -0.5);
    out.sinTime = scn_frame.sinTime;
    return out;
};

fragment half4 pass_through(out_vertex_t vert [[stage_in]],
                            texture2d<float, access::sample> colorSampler [[texture(0)]])
{

    float4 fragment_color = colorSampler.sample( s, vert.uv);
    return half4(fragment_color);
};

fragment half4 mix_add(out_vertex_t vert [[stage_in]],
                       texture2d<float, access::sample> color1Sampler [[texture(0)]],
                       texture2d<float, access::sample> color2Sampler [[texture(1)]])
{
    float4 fragment_color_1 = color1Sampler.sample( s, vert.uv);
    float4 fragment_color_2 = color2Sampler.sample( s, vert.uv);
    //float4 combined = max(fragment_color_1, fragment_color_2);
    //float4 combined = mix(fragment_color_1, fragment_color_2, 0.5);
    float4 combined = fragment_color_1 + fragment_color_2;
    //return half4(fragment_color_1 + fragment_color_2);
    //return half4(saturate(combined.x), saturate(combined.y), saturate(combined.z) , 1.0);
    return half4(combined);
};


// http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
constant float offset[] = { 0.0, 1.0, 2.0, 3.0, 4.0 };
constant float weight[] = { 0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162 };

fragment half4 blur_horizontal(out_vertex_t vert [[stage_in]],
                                          texture2d<float, access::sample> colorSampler [[texture(0)]])
{

    float4 FragmentColor = colorSampler.sample( s, vert.uv) * weight[0];
    for (int i=1; i<5; i++) {
        FragmentColor += colorSampler.sample( s, ( vert.uv + float2(offset[i], 0.0)/324.0 ) ) * weight[i];
        FragmentColor += colorSampler.sample( s, ( vert.uv - float2(offset[i], 0.0)/324.0 ) ) * weight[i];
    }
    return half4(FragmentColor);
}

fragment half4 blur_vertical(out_vertex_t vert [[stage_in]],
                             texture2d<float, access::sample> colorSampler [[texture(0)]])
{

    float4 FragmentColor = colorSampler.sample( s, vert.uv) * weight[0];
    for (int i=1; i<5; i++) {
        FragmentColor += colorSampler.sample( s, ( vert.uv + float2(0.0, offset[i])/324.0 ) ) * weight[i];
        FragmentColor += colorSampler.sample( s, ( vert.uv - float2(0.0, offset[i])/324.0 ) ) * weight[i];
    }
    return half4(FragmentColor);

};


//
//  https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson5
//


fragment half4 blur9_horizontal(out_vertex_t vert [[stage_in]],
                                texture2d<float, access::sample> colorSampler [[texture(0)]])
{

    float4 sum = float4(0.0);

    //our original texcoord for this fragment
    float2 tc = vert.uv;

    //the amount to blur, i.e. how far off center to sample from
    //1.0 -> blur by one pixel
    //2.0 -> blur by two pixels, etc.
    float blur = (abs(vert.sinTime) + 1) * 2.0/500.0;

    //the direction of our blur
    //(1.0, 0.0) -> x-axis blur
    //(0.0, 1.0) -> y-axis blur
    float hstep = 1.0;
    float vstep = 0.0;

    //apply blurring, using a 9-tap filter with predefined gaussian weights

    sum += colorSampler.sample(s, float2(tc.x - 4.0*blur*hstep, tc.y - 4.0*blur*vstep)) * 0.0162162162;
    sum += colorSampler.sample(s, float2(tc.x - 3.0*blur*hstep, tc.y - 3.0*blur*vstep)) * 0.0540540541;
    sum += colorSampler.sample(s, float2(tc.x - 2.0*blur*hstep, tc.y - 2.0*blur*vstep)) * 0.1216216216;
    sum += colorSampler.sample(s, float2(tc.x - 1.0*blur*hstep, tc.y - 1.0*blur*vstep)) * 0.1945945946;

    sum += colorSampler.sample(s, float2(tc.x, tc.y)) * 0.2270270270;

    sum += colorSampler.sample(s, float2(tc.x + 1.0*blur*hstep, tc.y + 1.0*blur*vstep)) * 0.1945945946;
    sum += colorSampler.sample(s, float2(tc.x + 2.0*blur*hstep, tc.y + 2.0*blur*vstep)) * 0.1216216216;
    sum += colorSampler.sample(s, float2(tc.x + 3.0*blur*hstep, tc.y + 3.0*blur*vstep)) * 0.0540540541;
    sum += colorSampler.sample(s, float2(tc.x + 4.0*blur*hstep, tc.y + 4.0*blur*vstep)) * 0.0162162162;

    //discard alpha for our simple demo, multiply by vertex color and return
    sum.a = 1.0;
    return half4(sum);
}

fragment half4 blur9_vertical(out_vertex_t vert [[stage_in]],
                                texture2d<float, access::sample> colorSampler [[texture(0)]])
{

    float4 sum = float4(0.0);

    //our original texcoord for this fragment
    float2 tc = vert.uv;

    //the amount to blur, i.e. how far off center to sample from
    //1.0 -> blur by one pixel
    //2.0 -> blur by two pixels, etc.
    float blur = (abs(vert.sinTime) + 1) * 2.0/500.0;

    //the direction of our blur
    //(1.0, 0.0) -> x-axis blur
    //(0.0, 1.0) -> y-axis blur
    float hstep = 0.0;
    float vstep = 1.0;

    //apply blurring, using a 9-tap filter with predefined gaussian weights

    sum += colorSampler.sample(s, float2(tc.x - 4.0*blur*hstep, tc.y - 4.0*blur*vstep)) * 0.0162162162;
    sum += colorSampler.sample(s, float2(tc.x - 3.0*blur*hstep, tc.y - 3.0*blur*vstep)) * 0.0540540541;
    sum += colorSampler.sample(s, float2(tc.x - 2.0*blur*hstep, tc.y - 2.0*blur*vstep)) * 0.1216216216;
    sum += colorSampler.sample(s, float2(tc.x - 1.0*blur*hstep, tc.y - 1.0*blur*vstep)) * 0.1945945946;

    sum += colorSampler.sample(s, float2(tc.x, tc.y)) * 0.2270270270;

    sum += colorSampler.sample(s, float2(tc.x + 1.0*blur*hstep, tc.y + 1.0*blur*vstep)) * 0.1945945946;
    sum += colorSampler.sample(s, float2(tc.x + 2.0*blur*hstep, tc.y + 2.0*blur*vstep)) * 0.1216216216;
    sum += colorSampler.sample(s, float2(tc.x + 3.0*blur*hstep, tc.y + 3.0*blur*vstep)) * 0.0540540541;
    sum += colorSampler.sample(s, float2(tc.x + 4.0*blur*hstep, tc.y + 4.0*blur*vstep)) * 0.0162162162;

    //discard alpha for our simple demo, multiply by vertex color and return
    sum.a = 1.0;
    return half4(sum);
}

fragment half4 blur15_horizontal(out_vertex_t vert [[stage_in]],
                                texture2d<float, access::sample> colorSampler [[texture(0)]])
{

    float4 sum = float4(0.0);

    //our original texcoord for this fragment
    float2 tc = vert.uv;

    //the amount to blur, i.e. how far off center to sample from
    //1.0 -> blur by one pixel
    //2.0 -> blur by two pixels, etc.
    float blur = (abs(vert.sinTime) + 1) * 1.0/500.0;

    //the direction of our blur
    //(1.0, 0.0) -> x-axis blur
    //(0.0, 1.0) -> y-axis blur
    float hstep = 1.0;
    float vstep = 0.0;

    //apply blurring, using a 15-tap filter with predefined gaussian weights
    sum += colorSampler.sample(s, float2(tc.x - 7.0*blur*hstep, tc.y - 7.0*blur*vstep)) * 0.009033;
    sum += colorSampler.sample(s, float2(tc.x - 6.0*blur*hstep, tc.y - 6.0*blur*vstep)) * 0.018476;
    sum += colorSampler.sample(s, float2(tc.x - 5.0*blur*hstep, tc.y - 5.0*blur*vstep)) * 0.033851;
    sum += colorSampler.sample(s, float2(tc.x - 4.0*blur*hstep, tc.y - 4.0*blur*vstep)) * 0.055555;
    sum += colorSampler.sample(s, float2(tc.x - 3.0*blur*hstep, tc.y - 3.0*blur*vstep)) * 0.08167;
    sum += colorSampler.sample(s, float2(tc.x - 2.0*blur*hstep, tc.y - 2.0*blur*vstep)) * 0.107545;
    sum += colorSampler.sample(s, float2(tc.x - 1.0*blur*hstep, tc.y - 1.0*blur*vstep)) * 0.126854;

    sum += colorSampler.sample(s, float2(tc.x, tc.y)) * 0.134032;

    sum += colorSampler.sample(s, float2(tc.x + 1.0*blur*hstep, tc.y + 1.0*blur*vstep)) * 0.126854;
    sum += colorSampler.sample(s, float2(tc.x + 2.0*blur*hstep, tc.y + 2.0*blur*vstep)) * 0.107545;
    sum += colorSampler.sample(s, float2(tc.x + 3.0*blur*hstep, tc.y + 3.0*blur*vstep)) * 0.08167;
    sum += colorSampler.sample(s, float2(tc.x + 4.0*blur*hstep, tc.y + 4.0*blur*vstep)) * 0.055555;
    sum += colorSampler.sample(s, float2(tc.x + 5.0*blur*hstep, tc.y + 5.0*blur*vstep)) * 0.033851;
    sum += colorSampler.sample(s, float2(tc.x + 6.0*blur*hstep, tc.y + 6.0*blur*vstep)) * 0.018476;
    sum += colorSampler.sample(s, float2(tc.x + 7.0*blur*hstep, tc.y + 7.0*blur*vstep)) * 0.009033;

    //discard alpha for our simple demo, multiply by vertex color and return
    sum.a = 1.0;
    return half4(sum);
}

fragment half4 blur15_vertical(out_vertex_t vert [[stage_in]],
                                 texture2d<float, access::sample> colorSampler [[texture(0)]])
{

    float4 sum = float4(0.0);

    //our original texcoord for this fragment
    float2 tc = vert.uv;

    //the amount to blur, i.e. how far off center to sample from
    //1.0 -> blur by one pixel
    //2.0 -> blur by two pixels, etc.
    float blur = (abs(vert.sinTime) + 1) * 1.0/500.0;

    //the direction of our blur
    //(1.0, 0.0) -> x-axis blur
    //(0.0, 1.0) -> y-axis blur
    float hstep = 0.0;
    float vstep = 1.0;

    //apply blurring, using a 15-tap filter with predefined gaussian weight
    sum += colorSampler.sample(s, float2(tc.x - 7.0*blur*hstep, tc.y - 7.0*blur*vstep)) * 0.009033;
    sum += colorSampler.sample(s, float2(tc.x - 6.0*blur*hstep, tc.y - 6.0*blur*vstep)) * 0.018476;
    sum += colorSampler.sample(s, float2(tc.x - 5.0*blur*hstep, tc.y - 5.0*blur*vstep)) * 0.033851;
    sum += colorSampler.sample(s, float2(tc.x - 4.0*blur*hstep, tc.y - 4.0*blur*vstep)) * 0.055555;
    sum += colorSampler.sample(s, float2(tc.x - 3.0*blur*hstep, tc.y - 3.0*blur*vstep)) * 0.08167;
    sum += colorSampler.sample(s, float2(tc.x - 2.0*blur*hstep, tc.y - 2.0*blur*vstep)) * 0.107545;
    sum += colorSampler.sample(s, float2(tc.x - 1.0*blur*hstep, tc.y - 1.0*blur*vstep)) * 0.126854;

    sum += colorSampler.sample(s, float2(tc.x, tc.y)) * 0.134032;

    sum += colorSampler.sample(s, float2(tc.x + 1.0*blur*hstep, tc.y + 1.0*blur*vstep)) * 0.126854;
    sum += colorSampler.sample(s, float2(tc.x + 2.0*blur*hstep, tc.y + 2.0*blur*vstep)) * 0.107545;
    sum += colorSampler.sample(s, float2(tc.x + 3.0*blur*hstep, tc.y + 3.0*blur*vstep)) * 0.08167;
    sum += colorSampler.sample(s, float2(tc.x + 4.0*blur*hstep, tc.y + 4.0*blur*vstep)) * 0.055555;
    sum += colorSampler.sample(s, float2(tc.x + 5.0*blur*hstep, tc.y + 5.0*blur*vstep)) * 0.033851;
    sum += colorSampler.sample(s, float2(tc.x + 6.0*blur*hstep, tc.y + 6.0*blur*vstep)) * 0.018476;
    sum += colorSampler.sample(s, float2(tc.x + 7.0*blur*hstep, tc.y + 7.0*blur*vstep)) * 0.009033;

    //discard alpha for our simple demo, multiply by vertex color and return
    sum.a = 1.0;
    return half4(sum);
}

//
// Replacement rendering
//

struct node_uniforms {
    float4 emission_color;
};


struct MyNodeBuffer {
    float4x4 modelTransform;
    float4x4 modelViewTransform;
    float4x4 normalTransform;
    float4x4 modelViewProjectionTransform;
};


typedef struct {
    float3 position [[ attribute(SCNVertexSemanticPosition) ]];
    float3 normal  [[ attribute(SCNVertexSemanticNormal) ]];
    float4 color  [[ attribute(SCNVertexSemanticColor) ]];
} BloomShaderVertexInput;

struct BloomShaderVertexOut
{
    float4 position [[position]];
    float3 color;
    float bloom;
};


vertex BloomShaderVertexOut bloom_vertex(BloomShaderVertexInput in [[ stage_in ]],
                                        constant SCNSceneBuffer& scn_frame [[buffer(0)]],
                                        constant MyNodeBuffer& scn_node [[buffer(1)]]
                                        )
{

    BloomShaderVertexOut vert;
    vert.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
    vert.color = in.color.rgb;
    vert.bloom = in.color.a; // * abs(sin(scn_frame.time + in.position.z));

    return vert;
}


fragment half4 bloom_fragment(BloomShaderVertexOut in [[stage_in]])
{
    half4 color;

    color = half4(in.color.r * in.bloom ,in.color.g * in.bloom, in.color.b * in.bloom, 1.0);
    //color = half4(0.0 ,in.bloomRadius / 4 ,0.0, 0.1);
    //color = half4(uniforms.emission_color);
    
    return color;
}





