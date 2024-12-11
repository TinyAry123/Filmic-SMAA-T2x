void neighborhoodBlendingSMAA1X(out vec3 color, sampler2D colorTex, sampler2D blendTex, vec2 uv) { // For SMAA 1x. 
	vec2 rtSize       = vec2(textureSize(colorTex, 0));
	vec2 fragmentSize = 1.0 / rtSize;
	ivec2 texelCoord  = ivec2(rtSize * uv);

	vec4 a = vec4(samplePoint(blendTex, texelCoord + ivec2( 1,  0)).w, samplePoint(blendTex, texelCoord + ivec2( 0,  1)).y, samplePointNoClamp(blendTex, texelCoord).zx);

	if (a.x + a.y + a.z + a.w >= 0.0000001) {
		uv += max(a.x, a.z) > max(a.y, a.w) ? vec2(mix(a.x, -a.z, a.z / (a.x + a.z)) * fragmentSize.x, 0.0) : vec2(0.0, mix(a.y, -a.w, a.w / (a.y + a.w)) * fragmentSize.y);

		color = sample2DCatmullRom(colorTex, uv).xyz;
	
		return;
	}

	color = samplePointNoClamp(colorTex, texelCoord).xyz;
}

void neighborhoodBlendingSMAAT2X(out vec3 color, out float depth, sampler2D colorTex, sampler2D depthTex, sampler2D blendTex, vec2 uv) { // For SMAA T2x. Anti-alias color and depth, with no AA fragments resampled at center for more stability (can be omitted). Set subsampleIndices accordingly in blendingWeightCalculation. 
	vec2 rtSize       = vec2(textureSize(colorTex, 0));
	vec2 fragmentSize = 1.0 / rtSize;
	ivec2 texelCoord  = ivec2(rtSize * uv);

	vec4 a = vec4(samplePoint(blendTex, texelCoord + ivec2( 1,  0)).w, samplePoint(blendTex, texelCoord + ivec2( 0,  1)).y, samplePointNoClamp(blendTex, texelCoord).zx);

	if (a.x + a.y + a.z + a.w >= 0.0000001) {
		uv += max(a.x, a.z) > max(a.y, a.w) ? vec2(mix(a.x, -a.z, a.z / (a.x + a.z)) * fragmentSize.x, 0.0) : vec2(0.0, mix(a.y, -a.w, a.w / (a.y + a.w)) * fragmentSize.y);

		color = sample2DCatmullRom(colorTex, uv).xyz;
		depth = sample2DCatmullRom(depthTex, uv).x;
	
		return;
	}

	color = sample2DCatmullRom(colorTex, uv + jitterOffsetsTAA[frameMod2]).xyz;
	depth = sample2DCatmullRom(depthTex, uv + jitterOffsetsTAA[frameMod2]).x;
}