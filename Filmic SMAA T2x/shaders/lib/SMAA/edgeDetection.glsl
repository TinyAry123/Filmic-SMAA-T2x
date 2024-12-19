const float SMAA_COLOR_EDGE_THRESHOLD = 0.0625;
const float SMAA_DEPTH_EDGE_THRESHOLD = 4.0;

void colorEdgeDetectionSMAA(out vec2 edges, sampler2D colorTex, vec2 uv) {
    ivec2 texelCoord = ivec2(textureSize(colorTex, 0) * uv);
    vec4 delta;
    vec3 d;

    vec3 colorCenter = samplePointNoClamp(colorTex, texelCoord).xyz;

    delta.x = distance(colorCenter, samplePoint(colorTex, texelCoord + ivec2(-1,  0)).xyz);
    delta.y = distance(colorCenter, samplePoint(colorTex, texelCoord + ivec2( 0, -1)).xyz);

    edges = step(SMAA_COLOR_EDGE_THRESHOLD, delta.xy);
    
    d.x = length(delta.xy);

    if (edges.x + edges.y > 0.0) {
        delta.z = distance(colorCenter, samplePoint(colorTex, texelCoord + ivec2( 1,  0)).xyz);
        delta.w = distance(colorCenter, samplePoint(colorTex, texelCoord + ivec2( 0,  1)).xyz);

        d.y = length(delta.zw);

        delta.z = distance(colorCenter, samplePoint(colorTex, texelCoord + ivec2(-2,  0)).xyz);
        delta.w = distance(colorCenter, samplePoint(colorTex, texelCoord + ivec2( 0, -2)).xyz);

        d.z = length(delta.zw);

        if (d.x > d.y) {
            delta.z = d.x;
            d.x     = d.y;
            d.y     = delta.z;
        }

        if (d.y > d.z) {
            delta.z = d.y;
            d.y     = d.z;
            d.z     = delta.z;
        }
        
        if (d.x > d.y) {
            delta.z = d.x;
            d.x     = d.y;
            d.y     = delta.z;
        }

        edges = step(mixCatmullRom(d.x, d.y, d.z, d.z, 0.75), 2.0 * delta.xy);
    }
}

void depthEdgeDetectionSMAA(out vec2 edges, sampler2D positionTex, vec2 uv) {
    ivec2 texelCoord = ivec2(textureSize(positionTex, 0) * uv);
    vec4 delta;
    vec3 d;

    float depthCenter = samplePointNoClamp(positionTex, texelCoord).z;

    delta.x = abs(depthCenter - samplePoint(positionTex, texelCoord + ivec2(-1,  0)).z);
    delta.y = abs(depthCenter - samplePoint(positionTex, texelCoord + ivec2( 0, -1)).z);

    edges = step(SMAA_DEPTH_EDGE_THRESHOLD, delta.xy);
    
    d.x = length(delta.xy);

    if (edges.x + edges.y > 0.0) {
        delta.z = abs(depthCenter - samplePoint(positionTex, texelCoord + ivec2( 1,  0)).z);
        delta.w = abs(depthCenter - samplePoint(positionTex, texelCoord + ivec2( 0,  1)).z);

        d.y = length(delta.zw);

        delta.z = abs(depthCenter - samplePoint(positionTex, texelCoord + ivec2(-2,  0)).z);
        delta.w = abs(depthCenter - samplePoint(positionTex, texelCoord + ivec2( 0, -2)).z);

        d.z = length(delta.zw);

        if (d.x > d.y) {
            delta.z = d.x;
            d.x     = d.y;
            d.y     = delta.z;
        }

        if (d.y > d.z) {
            delta.z = d.y;
            d.y     = d.z;
            d.z     = delta.z;
        }
        
        if (d.x > d.y) {
            delta.z = d.x;
            d.x     = d.y;
            d.y     = delta.z;
        }

        edges = step(mixCatmullRom(d.x, d.y, d.z, d.z, 0.75), 2.0 * delta.xy);
    }
}