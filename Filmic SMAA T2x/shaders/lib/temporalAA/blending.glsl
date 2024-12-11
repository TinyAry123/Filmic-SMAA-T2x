ivec2 neighborhoodOffsetsTAA[8] = ivec2[8](
    ivec2( 0,  1),
    ivec2( 1,  0),
    ivec2(-1,  0),
    ivec2( 0, -1),
    ivec2(-1,  1),
    ivec2( 1,  1),
    ivec2( 1, -1),
    ivec2(-1, -1)
);

const float accumulationWeight = 256.0; // [16, 256]. Higher values mean less accumulation over time. 16 = sweet spot, requires good handling of disocclusion (TBI). 256 = sharp, less stable. 

void blendingPass1TAA(out vec4 blendedColor, out float blendedDepth, out vec4 iterColor, out float iterDepth, sampler2D currentColorTex, sampler2D currentDepthTex, sampler2D velocityTex, sampler2D previousColorTex, sampler2D previousDepthTex) {
    ivec2 texelCoord = ivec2(viewSize * uv);

    vec4 currentColor  = vec4(samplePointNoClamp(currentColorTex, texelCoord).xyz, frameTime);
    float currentDepth = samplePointNoClamp(currentDepthTex, texelCoord).x;
    vec3 velocity      = samplePointNoClamp(velocityTex, texelCoord).xyz;

    vec4 previousColor  = sample2DCatmullRom(previousColorTex, uv - velocity.xy);
    float previousDepth = sample2DCatmullRom(previousDepthTex, uv - velocity.xy).x;

    blendedColor = 0.5 * (previousColor + currentColor);
    blendedDepth = 0.5 * (previousDepth + currentDepth);

    vec3 currentColorMin = currentColor.xyz;
    vec3 currentColorMax = currentColor.xyz;
    vec3 currentColorTemp;

    for (int i = 0; i < 8; i++) {
        currentColorTemp = samplePoint(currentColorTex, texelCoord + neighborhoodOffsetsTAA[i]).xyz;

        currentColorMin = min(currentColorMin, currentColorTemp);
        currentColorMax = max(currentColorMax, currentColorTemp);
    }

    float weightColor = smoothstep(0.0625, 0.25, distance(blendedColor.xyz, clamp(blendedColor.xyz, currentColorMin, currentColorMax)));

    float weightFinal = weightColor;

    blendedColor = mix(blendedColor, currentColor, weightFinal);
    blendedDepth = mix(blendedDepth, currentDepth, weightFinal);
    iterColor    = currentColor;
    iterDepth    = currentDepth;
}

void blendingPass2TAA(out vec4 blendedColor, out float blendedDepth, out vec4 iterColor, out float iterDepth, sampler2D currentColorTex, sampler2D currentDepthTex, sampler2D velocityTex, sampler2D previousColorTex, sampler2D previousDepthTex) {
    ivec2 texelCoord = ivec2(viewSize * uv);

    vec4 currentColor  = samplePointNoClamp(currentColorTex, texelCoord);
    float currentDepth = samplePointNoClamp(currentDepthTex, texelCoord).x;
    vec3 velocity      = samplePointNoClamp(velocityTex, texelCoord).xyz;

    vec4 previousColor  = sample2DCatmullRom(previousColorTex, uv - velocity.xy);
    float previousDepth = sample2DCatmullRom(previousDepthTex, uv - velocity.xy).x;

    float alpha = 1.0 - exp(-accumulationWeight * currentColor.w);

    blendedColor = mix(previousColor, currentColor, alpha);
    blendedDepth = mix(previousDepth, currentDepth, alpha);

    vec3 currentColorMin = currentColor.xyz;
    vec3 currentColorMax = currentColor.xyz;
    vec3 currentColorTemp;

    for (int i = 0; i < 8; i++) {
        currentColorTemp = samplePoint(currentColorTex, texelCoord + neighborhoodOffsetsTAA[i]).xyz;

        currentColorMin = min(currentColorMin, currentColorTemp);
        currentColorMax = max(currentColorMax, currentColorTemp);
    }

    float weightColor = smoothstep(0.0625, 0.25, distance(blendedColor.xyz, clamp(blendedColor.xyz, currentColorMin, currentColorMax)));

    float weightFinal = weightColor;

    blendedColor = max(mix(blendedColor, currentColor, weightFinal), 0.0);
    blendedDepth = max(mix(blendedDepth, currentDepth, weightFinal), 0.0);
    iterColor    = blendedColor;
    iterDepth    = blendedDepth;
}

/*
TBI:
- disocclusion handling:
    1. velocity expansion by depth method (nearest-depth velocity)
    2. depth testing (compare neighborhood of reprojected depths with previous depth for accuracy)
    3. normal comparison (maybe)
- accurate depth blending:
    1. inverse reprojection (requires inverse mat4 for certain matrices)
*/