const int SMAA_SEARCH_RADIUS         = 16;
const int SMAA_SEARCH_STEPS_DIAGONAL = int(SMAA_SEARCH_RADIUS * inversesqrt(2.0) + 0.5) - 1;

void searchDiagonal1SMAA(out vec2 d, out vec2 e, sampler2D edgesTex, ivec2 texelCoord, ivec2 direction, vec2 rtSize, vec2 fragmentSize) {
	float edgeWeight = 1.0;
	int searchStep   = -1;

	while (searchStep < SMAA_SEARCH_STEPS_DIAGONAL && edgeWeight > 0.9) {
		searchStep++;
		texelCoord += direction;

		e = samplePoint(edgesTex, texelCoord).xy;

		edgeWeight = 0.5 * (e.x + e.y);
	}

	d = vec2(searchStep, edgeWeight);
}

void searchDiagonal2SMAA(out vec2 d, out vec2 e, sampler2D edgesTex, vec2 uv, vec2 direction, vec2 rtSize, vec2 fragmentSize) {
	float edgeWeight = 1.0;
	int searchStep   = -1;

	uv.x += 0.25 * fragmentSize.x;

	while (searchStep < SMAA_SEARCH_STEPS_DIAGONAL && edgeWeight > 0.9) {
		searchStep++;
		uv += direction * fragmentSize;

		e   =  sampleLinear(edgesTex, uv).xy;
		e.x *= abs(5.0 * e.x - 3.75);
		e   =  floor(e + 0.5);

		edgeWeight = 0.5 * (e.x + e.y);
	}

	d = vec2(searchStep, edgeWeight);
}

vec2 areaDiagonalSMAA(sampler2D areaTex, vec2 dist, vec2 e, float offset) {
    return sampleLinear(areaTex, (20.0 * e + dist + 0.5) / vec2(160.0, 560.0) + vec2(0.5, offset / 7.0)).xy;
}

void calculateDiagonalWeightsSMAA(out vec2 weights, sampler2D edgesTex, sampler2D areaTex, ivec2 texelCoord, vec2 uv, vec2 e, vec4 subsampleIndices, vec2 rtSize, vec2 fragmentSize) {
	vec4 d;
	vec2 end;

	weights = vec2(0.0);

	if (e.x > 0.0) {
		searchDiagonal1SMAA(d.xz, end, edgesTex, texelCoord, ivec2(-1,  1), rtSize, fragmentSize);
		d.x += 1.0 - step(0.9, -end.y);
	} else {
		d.xz = vec2(0.0);
	}

	searchDiagonal1SMAA(d.yw, end, edgesTex, texelCoord, ivec2( 1, -1), rtSize, fragmentSize);

	if (d.x + d.y > 2.0) {
		vec4 coords = uv.xyxy + vec4(0.25 - d.x, d.x, d.y, -(0.25 + d.y)) * fragmentSize.xyxy;

		vec4 c =  vec4(sampleLinear(edgesTex, vec2(coords.x - fragmentSize.x, coords.y)).xy, sampleLinear(edgesTex, vec2(coords.z + fragmentSize.x, coords.w)).xy);
		c.xz   *= abs(5.0 * c.xz - 3.75);
		c.yxwz =  floor(c + 0.5);

		vec2 cc = (1.0 - step(0.9, d.zw)) * (2.0 * c.xz + c.yw);

		weights += areaDiagonalSMAA(areaTex, d.xy, cc, subsampleIndices.z);
	}

	searchDiagonal2SMAA(d.xz, end, edgesTex, uv, vec2(-1.0, -1.0), rtSize, fragmentSize);

	if (samplePoint(edgesTex, texelCoord + ivec2( 1,  0)).x > 0.0) {
		searchDiagonal2SMAA(d.yw, end, edgesTex, uv, vec2( 1.0,  1.0), rtSize, fragmentSize);
		d.y += 1.0 - step(0.9, -end.y);
	} else {
		d.yw = vec2(0.0);
	}

	if (d.x + d.y > 2.0) {
		vec4 coords = uv.xyxy + vec4(-d.x, -d.x, d.y, d.y) * fragmentSize.xyxy;

		vec4 c = vec4(sampleLinear(edgesTex, vec2(coords.x - fragmentSize.x, coords.y)).y, sampleLinear(edgesTex, vec2(coords.x, coords.y - fragmentSize.y)).x, sampleLinear(edgesTex, vec2(coords.z + fragmentSize.x, coords.w)).yx);
		
		vec2 cc = (1.0 - step(0.9, d.zw)) * (2.0 * c.xz + c.yw);

		weights += areaDiagonalSMAA(areaTex, d.xy, cc, subsampleIndices.w).yx;
	}
}

float searchLengthSMAA(sampler2D searchTex, vec2 e, float offset) {
	return samplePoint(searchTex, ivec2(vec2(32.0, -32.0) * e + vec2(66.0 * offset + 0.5, 32.5))).x;
}

float searchXLeftSMAA(sampler2D edgesTex, sampler2D searchTex, vec2 uv, float end, vec2 rtSize, vec2 fragmentSize) {
	vec2 e = vec2(0.0, 1.0);

	while (uv.x > end && e.y > 0.8281 && e.x == 0.0) {
		e = sampleLinear(edgesTex, uv).xy;

		uv.x -= 2.0 * fragmentSize.x;
	}

	return uv.x + (3.25 - (255.0 / 127.0) * searchLengthSMAA(searchTex, e, 0.0)) * fragmentSize.x;
}

float searchXRightSMAA(sampler2D edgesTex, sampler2D searchTex, vec2 uv, float end, vec2 rtSize, vec2 fragmentSize) {
	vec2 e = vec2(0.0, 1.0);

	while (uv.x < end && e.y > 0.8281 && e.x == 0.0) {
		e = sampleLinear(edgesTex, uv).xy;
		
		uv.x += 2.0 * fragmentSize.x;
	}
	
	return uv.x - (3.25 - (255.0 / 127.0) * searchLengthSMAA(searchTex, e, 0.5)) * fragmentSize.x;
}

float searchYUpSMAA(sampler2D edgesTex, sampler2D searchTex, vec2 uv, float end, vec2 rtSize, vec2 fragmentSize) {
	vec2 e = vec2(1.0, 0.0);

	while (uv.y > end && e.x > 0.8281 && e.y == 0.0) {
		e = sampleLinear(edgesTex, uv).xy;

		uv.y -= 2.0 * fragmentSize.y;
	}

	return uv.y + (3.25 - (255.0 / 127.0) * searchLengthSMAA(searchTex, e.yx, 0.0)) * fragmentSize.y;
}

float searchYDownSMAA(sampler2D edgesTex, sampler2D searchTex, vec2 uv, float end, vec2 rtSize, vec2 fragmentSize) {
	vec2 e = vec2(1.0, 0.0);

	while (uv.y < end && e.x > 0.8281 && e.y == 0.0) {
		e = sampleLinear(edgesTex, uv).xy;

		uv.y += 2.0 * fragmentSize.y;
	}

	return uv.y - (3.25 - (255.0 / 127.0) * searchLengthSMAA(searchTex, e.yx, 0.5)) * fragmentSize.y;
}

void areaSMAA(out vec2 weights, sampler2D areaTex, vec2 dist, float e1, float e2, float offset) {
    weights = sampleLinear(areaTex, (16.0 * floor(4.0 * vec2(e1, e2) + 0.5) + dist + 0.5) / vec2(160.0, 560.0) + vec2(0.0, offset / 7.0)).xy;
}

void detectHorizontalCornerPatternSMAA(inout vec2 weights, sampler2D edgesTex, vec3 coords, vec2 d, vec2 rtSize, vec2 fragmentSize) {
    vec2 leftRight = step(d.xy, d.yx);
	vec2 factor    = vec2(1.0);
    float rounding = 0.5 / (leftRight.x + leftRight.y);

	if (leftRight.x > 0.0) factor -= rounding * vec2(sampleLinear(edgesTex, vec2(coords.x, coords.y + fragmentSize.y)).x, sampleLinear(edgesTex, vec2(coords.x, coords.y - 2.0 * fragmentSize.y)).x);

	if (leftRight.y > 0.0) factor -= rounding * vec2(sampleLinear(edgesTex, coords.zy + vec2( 1.0,  1.0) * fragmentSize).x, sampleLinear(edgesTex, coords.zy + vec2( 1.0, -2.0) * fragmentSize).x);

    weights *= clamp(factor, 0.0, 1.0);
}

void detectVerticalCornerPatternSMAA(inout vec2 weights, sampler2D edgesTex, vec3 coords, vec2 d, vec2 rtSize, vec2 fragmentSize) {
    vec2 leftRight = step(d.xy, d.yx);
	vec2 factor    = vec2(1.0);
    float rounding = 0.5 / (leftRight.x + leftRight.y);

	if (leftRight.x > 0.0) factor -= rounding * vec2(sampleLinear(edgesTex, vec2(coords.x + fragmentSize.x, coords.y)).y, sampleLinear(edgesTex, vec2(coords.x - 2.0 * fragmentSize.x, coords.y)).y);

	if (leftRight.y > 0.0) factor -= rounding * vec2(sampleLinear(edgesTex, coords.xz + vec2( 1.0,  1.0) * fragmentSize).y, sampleLinear(edgesTex, coords.xz + vec2(-2.0,  1.0) * fragmentSize).y);

    weights *= clamp(factor, 0.0, 1.0);
}

void blendingWeightCalculationSMAA(out vec4 weights, sampler2D edgesTex, sampler2D areaTex, sampler2D searchTex, vec4 subsampleIndices, vec2 uv) {
	vec2 rtSize       = vec2(textureSize(edgesTex, 0));
	vec2 fragmentSize = 1.0 / rtSize;
	ivec2 texelCoord  = ivec2(rtSize * uv);
	vec4 offsets[3];
	vec3 coords;
	vec2 d;

	offsets[0] = uv.xyxy + vec4(-0.250, -0.125,  1.250, -0.125) * fragmentSize.xyxy;
	offsets[1] = uv.xyxy + vec4(-0.125, -0.250, -0.125,  1.250) * fragmentSize.xyxy;
	offsets[2] = vec4(offsets[0].xz, offsets[1].yw) + vec4(-SMAA_SEARCH_RADIUS, SMAA_SEARCH_RADIUS, -SMAA_SEARCH_RADIUS, SMAA_SEARCH_RADIUS) * fragmentSize.xxyy;

	vec2 e = samplePointNoClamp(edgesTex, texelCoord).xy;

	if (e.y > 0.0) {
		calculateDiagonalWeightsSMAA(weights.xy, edgesTex, areaTex, texelCoord, uv, e, subsampleIndices, rtSize, fragmentSize);

		if (weights.x == -weights.y) {
			coords = vec3(searchXLeftSMAA(edgesTex, searchTex, offsets[0].xy, offsets[2].x, rtSize, fragmentSize), offsets[1].y, searchXRightSMAA(edgesTex, searchTex, offsets[0].zw, offsets[2].y, rtSize, fragmentSize));
			d      = abs(floor(rtSize.x * (coords.xz - uv.x) + 0.5));

			areaSMAA(weights.xy, areaTex, sqrt(d), sampleLinear(edgesTex, coords.xy).x, sampleLinear(edgesTex, vec2(coords.z + fragmentSize.x, coords.y)).x, subsampleIndices.y);
		
			coords.y = uv.y;
			detectHorizontalCornerPatternSMAA(weights.xy, edgesTex, coords, d, rtSize, fragmentSize);
		} else {
			e.x = 0.0;
		}
	} else {
		weights.xy = vec2(0.0);
	}

	if (e.x > 0.0) {
		coords = vec3(offsets[0].x, searchYUpSMAA(edgesTex, searchTex, offsets[1].xy, offsets[2].z, rtSize, fragmentSize), searchYDownSMAA(edgesTex, searchTex, offsets[1].zw, offsets[2].w, rtSize, fragmentSize));
		d      = abs(floor(rtSize.y * (coords.yz - uv.y) + 0.5));

		areaSMAA(weights.zw, areaTex, sqrt(d), sampleLinear(edgesTex, coords.xy).y, sampleLinear(edgesTex, vec2(coords.x, coords.z + fragmentSize.y)).y, subsampleIndices.x);
	
		coords.x = uv.x;
		detectVerticalCornerPatternSMAA(weights.zw, edgesTex, coords, d, rtSize, fragmentSize);
	} else {
		weights.zw = vec2(0.0);
	}
}