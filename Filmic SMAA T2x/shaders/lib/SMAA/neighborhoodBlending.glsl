void neighborhoodBlendingSMAA1X(out vec3 color, sampler2D colorTex, sampler2D blendTex, vec2 uv) {
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

void neighborhoodBlendingSMAATemporal(out vec3 color, out vec3 position, out vec2 blendingOffset, sampler2D colorTex, sampler2D positionTex, sampler2D blendTex, vec2 uv) {
	vec2 rtSize       = vec2(textureSize(colorTex, 0));
	vec2 fragmentSize = 1.0 / rtSize;
	ivec2 texelCoord  = ivec2(rtSize * uv);

	vec4 a = vec4(samplePoint(blendTex, texelCoord + ivec2( 1,  0)).w, samplePoint(blendTex, texelCoord + ivec2( 0,  1)).y, samplePointNoClamp(blendTex, texelCoord).zx);

	if (a.x + a.y + a.z + a.w >= 0.0000001) {
		blendingOffset =  max(a.x, a.z) > max(a.y, a.w) ? vec2(mix(a.x, -a.z, a.z / (a.x + a.z)) * fragmentSize.x, 0.0) : vec2(0.0, mix(a.y, -a.w, a.w / (a.y + a.w)) * fragmentSize.y);
		uv             += blendingOffset;

		color    = sample2DCatmullRom(colorTex, uv).xyz;
		position = sample2DCatmullRom(positionTex, uv).xyz;
	
		return;
	}

	blendingOffset = vec2(0.0);

	color    = samplePointNoClamp(colorTex, texelCoord).xyz;
	position = samplePointNoClamp(positionTex, texelCoord).xyz;
}