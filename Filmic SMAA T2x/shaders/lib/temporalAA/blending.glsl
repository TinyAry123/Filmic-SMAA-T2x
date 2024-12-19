ivec2 neighborhoodOffsetsTAA[9] = ivec2[9](
    ivec2( 0,  0),
    ivec2( 0,  1),
    ivec2( 1,  0),
    ivec2(-1,  0),
    ivec2( 0, -1),
    ivec2(-1,  1),
    ivec2( 1,  1),
    ivec2( 1, -1),
    ivec2(-1, -1)
);

float linstep(float a, float b, float variable) {
    return clamp((variable - a) / (b - a), 0.0, 1.0);
}

float smoothCurve(float variable) {
    return variable * variable * (3.0 - 2.0 * variable);
}

void blendingPass1TAA(out vec4 blended1, out vec4 blended2, out vec4 iter1, out vec4 iter2, sampler2D currentTex1, sampler2D currentTex2, sampler2D currentTex3, sampler2D previousTex1, sampler2D previousTex2) {
    ivec2 texelCoord = ivec2(viewSize * uv);

    vec4 current1 = samplePointNoClamp(currentTex1, texelCoord);
    vec4 current2 = samplePointNoClamp(currentTex2, texelCoord);

    vec3 currentColorMin  = current1.xyz;
    vec3 currentColorMax  = current1.xyz;
    float currentDepthMin = current2.z;
    float currentDepthMax = current2.z;
    vec3 currentColorTemp;
    float currentDepthTemp;
    ivec2 reprojectionOffset;

    for (int i = 1; i < 9; i++) {
        ivec2 texelCoordTemp = clamp(texelCoord + neighborhoodOffsetsTAA[i], ivec2(0, 0), ivec2(viewSize) - 1);

        currentColorTemp = samplePointNoClamp(currentTex1, texelCoordTemp).xyz;
        currentDepthTemp = samplePointNoClamp(currentTex2, texelCoordTemp).z;
        currentColorMin  = min(currentColorMin, currentColorTemp);
        currentColorMax  = max(currentColorMax, currentColorTemp);
        currentDepthMin  = min(currentDepthMin, currentDepthTemp);

        if (currentDepthTemp > currentDepthMax) {
            currentDepthMax    = currentDepthTemp;
            reprojectionOffset = texelCoordTemp - texelCoord;
        }
    }

    vec3 viewSpacePosition = samplePointNoClamp(currentTex2, texelCoord + reprojectionOffset).xyz;
    vec2 blendingOffset    = samplePointNoClamp(currentTex3, texelCoord + reprojectionOffset).xy;
    vec2 reprojectedUV     = 0.5 * projectAndDivide(gbufferPreviousProjection, reprojectionPositionTAA2(viewSpacePosition)).xy + 0.5 - blendingOffset - texelSize * reprojectionOffset;

    vec4 previous1 = sample2DCatmullRom(previousTex1, reprojectedUV);
    vec4 previous2 = sample2DCatmullRom(previousTex2, reprojectedUV);

    blended1.xyz = mix(previous1.xyz, current1.xyz, 0.5);
    blended2.xyz = mix(reprojectionPositionInverseTAA2(previous2.xyz), current2.xyz, 0.5);

    float weightColor = linstep(0.00390625, 0.0625, distance(blended1.xyz, clamp(blended1.xyz, currentColorMin, currentColorMax)));
    float weightDepth = linstep(1.0, 4.0, abs(blended2.z - clamp(blended2.z, currentDepthMin, currentDepthMax)));
    float weightFinal = smoothCurve(max(weightColor, weightDepth));

    blended1.xyz = mix(blended1.xyz, current1.xyz, weightFinal);
    blended2.xyz = mix(blended2.xyz, current2.xyz, weightFinal);

    iter1 = current1;
    iter2 = current2;
}

void blendingPass2TAA(); // Temporal filter needs implementation. 