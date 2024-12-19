const mat3 LINSRGB_TO_ACESCG_MAT3 = transpose(mat3( // D60 white point (no CAT), ACES AP1 primaries. 
	 0.603141864824168,  0.326348820905406,  0.048032249371334,
     0.070048330959323,  0.919956672718104,  0.012762703393258,
     0.022148857622425,  0.116083383633969,  0.940986978255483
));

const mat3 ACESCG_TO_LINSRGB_MAT3 = transpose(mat3(
	 1.731058556100512, -0.603969140699731, -0.080144783067437,
    -0.131436577092243,  1.134774421114367, -0.008690380522257,
    -0.024528364846909, -0.125756450585716,  1.065675421645792
));

const mat3 LINSRGB_TO_LMS_MAT3 = transpose(mat3( // D65 white point (no CAT), sRGB primaries. 
	 0.412221470800000,  0.536332536300000,  0.051445992900000,
	 0.211903498200000,  0.680699545100000,  0.107396956600000,
	 0.088302461900000,  0.281718837600000,  0.629978700500000
));

const mat3 LMS_TO_LINSRGB_MAT3 = transpose(mat3(
	 4.076741662100000, -3.307711591300000,  0.230969929200000,
	-1.268438004600000,  2.609757401100000, -0.341319396500000,
	-0.004196086300000, -0.703418614700000,  1.707614701000000
));

const mat3 LMSCBRT_TO_OKLAB_MAT3 = transpose(mat3( // D65 white point (no CAT), sRGB primaries. 
	 0.210454255300000,  0.793617785000000, -0.004072046800000,
	 1.977998495100000, -2.428592205000000,  0.450593709900000,
	 0.025904037100000,  0.782771766200000, -0.808675766000000
));

const mat3 OKLAB_TO_LMSCBRT_MAT3 = transpose(mat3(
	 1.000000000000000,  0.396337777400000,  0.215803757300000,
	 1.000000000000000, -0.105561345800000, -0.063854172800000,
	 1.000000000000000, -0.089484177500000, -1.291485548000000
));

vec3 LINSRGB_TO_ACESCG(vec3 color) {
    return LINSRGB_TO_ACESCG_MAT3 * color;
}

vec4 LINSRGB_TO_ACESCG(vec4 color) {
    return vec4(LINSRGB_TO_ACESCG(color.xyz), color.w);
}

vec3 ACESCG_TO_LINSRGB(vec3 color) {
    return ACESCG_TO_LINSRGB_MAT3 * color;
}

vec4 ACESCG_TO_LINSRGB(vec4 color) {
    return vec4(ACESCG_TO_LINSRGB(color.xyz), color.w);
}

vec3 LINSRGB_TO_LMS(vec3 color) {
	return LINSRGB_TO_LMS_MAT3 * color;
}

vec4 LINSRGB_TO_LMS(vec4 color) {
	return vec4(LINSRGB_TO_LMS(color.xyz), color.w);
}

vec3 LMS_TO_LINSRGB(vec3 color) {
	return LMS_TO_LINSRGB_MAT3 * color;
}

vec4 LMS_TO_LINSRGB(vec4 color) {
	return vec4(LMS_TO_LINSRGB(color.xyz), color.w);
}

float LMS_TO_LMSCBRT(float color) {
	return sign(color) * pow(abs(color), 0.333333333333333);
}

vec2 LMS_TO_LMSCBRT(vec2 color) {
	return vec2(LMS_TO_LMSCBRT(color.x), LMS_TO_LMSCBRT(color.y));
}

vec3 LMS_TO_LMSCBRT(vec3 color) {
	return vec3(LMS_TO_LMSCBRT(color.x), LMS_TO_LMSCBRT(color.y), LMS_TO_LMSCBRT(color.z));
}

vec4 LMS_TO_LMSCBRT(vec4 color) {
	return vec4(LMS_TO_LMSCBRT(color.x), LMS_TO_LMSCBRT(color.y), LMS_TO_LMSCBRT(color.z), color.w);
}

float LMSCBRT_TO_LMS(float color) {
	return color * color * color;
}

vec2 LMSCBRT_TO_LMS(vec2 color) {
	return vec2(LMSCBRT_TO_LMS(color.x), LMSCBRT_TO_LMS(color.y));
}

vec3 LMSCBRT_TO_LMS(vec3 color) {
	return vec3(LMSCBRT_TO_LMS(color.x), LMSCBRT_TO_LMS(color.y), LMSCBRT_TO_LMS(color.z));
}

vec4 LMSCBRT_TO_LMS(vec4 color) {
	return vec4(LMSCBRT_TO_LMS(color.x), LMSCBRT_TO_LMS(color.y), LMSCBRT_TO_LMS(color.z), color.w);
}

vec3 LMSCBRT_TO_OKLAB(vec3 color) {
	return LMSCBRT_TO_OKLAB_MAT3 * color;
}

vec4 LMSCBRT_TO_OKLAB(vec4 color) {
	return vec4(LMSCBRT_TO_OKLAB(color.xyz), color.w);
}

vec3 OKLAB_TO_LMSCBRT(vec3 color) {
	return OKLAB_TO_LMSCBRT_MAT3 * color;
}

vec4 OKLAB_TO_LMSCBRT(vec4 color) {
	return vec4(OKLAB_TO_LMSCBRT(color.xyz), color.w);
}

vec3 LINSRGB_TO_OKLAB(vec3 color) {
	return LMSCBRT_TO_OKLAB(LMS_TO_LMSCBRT(LINSRGB_TO_LMS(color)));
}

vec4 LINSRGB_TO_OKLAB(vec4 color) {
	return vec4(LINSRGB_TO_OKLAB(color.xyz), color.w);
}

vec3 OKLAB_TO_LINSRGB(vec3 color) {
	return LMS_TO_LINSRGB(LMSCBRT_TO_LMS(OKLAB_TO_LMSCBRT(color)));
}

vec4 OKLAB_TO_LINSRGB(vec4 color) {
	return vec4(OKLAB_TO_LINSRGB(color.xyz), color.w);
}

float LINSRGB_TO_SRGB(float color) {
	return color <= 0.003130804953560 ? 12.920000000000000 * color : 1.055000000000000 * pow(color, 0.416666666666667) - 0.055000000000000;
}

vec2 LINSRGB_TO_SRGB(vec2 color) {
	return vec2(LINSRGB_TO_SRGB(color.x), LINSRGB_TO_SRGB(color.y));
}

vec3 LINSRGB_TO_SRGB(vec3 color) {
	return vec3(LINSRGB_TO_SRGB(color.x), LINSRGB_TO_SRGB(color.y), LINSRGB_TO_SRGB(color.z));
}

vec4 LINSRGB_TO_SRGB(vec4 color) {
	return vec4(LINSRGB_TO_SRGB(color.x), LINSRGB_TO_SRGB(color.y), LINSRGB_TO_SRGB(color.z), color.w);
}

float SRGB_TO_LINSRGB(float color) {
	return color <= 0.040450000000000 ? 0.077399380804954 * color : pow(0.947867298578199 * color + 0.052132701421801, 2.400000000000000);
}

vec2 SRGB_TO_LINSRGB(vec2 color) {
	return vec2(SRGB_TO_LINSRGB(color.x), SRGB_TO_LINSRGB(color.y));
}

vec3 SRGB_TO_LINSRGB(vec3 color) {
	return vec3(SRGB_TO_LINSRGB(color.x), SRGB_TO_LINSRGB(color.y), SRGB_TO_LINSRGB(color.z));
}

vec4 SRGB_TO_LINSRGB(vec4 color) {
	return vec4(SRGB_TO_LINSRGB(color.x), SRGB_TO_LINSRGB(color.y), SRGB_TO_LINSRGB(color.z), color.w);
}

float tonemapACES(float color) {
    color = max(color, 0.0);

    return color * (2.51 * color + 0.03) / (color * (2.43 * color + 0.59) + 0.14);
}

vec2 tonemapACES(vec2 color) {
    return vec2(tonemapACES(color.x), tonemapACES(color.y));
}

vec3 tonemapACES(vec3 color) {
    return vec3(tonemapACES(color.x), tonemapACES(color.y), tonemapACES(color.z));
}

vec4 tonemapACES(vec4 color) {
    return vec4(tonemapACES(color.x), tonemapACES(color.y), tonemapACES(color.z), color.a);
}

vec4 sample2DCatmullRomLM(sampler2D tex, vec2 uv) { // Temporary 2D Catmull-Rom sampling for lightmaps to simulate interpolation in ACEScg color space. 
	ivec2 texSize         = textureSize(tex, 0);
    ivec2 texSizeMinusOne = texSize - 1;

    vec2 xy      = texSize * uv - 0.5;
    vec2 weights = fract(xy);
    ivec2 xy00   = ivec2(floor(xy)) - 1;

    vec4 texel00 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(0, 0), ivec2(0, 0), texSizeMinusOne))));
    vec4 texel01 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(0, 1), ivec2(0, 0), texSizeMinusOne))));
    vec4 texel02 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(0, 2), ivec2(0, 0), texSizeMinusOne))));
    vec4 texel03 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(0, 3), ivec2(0, 0), texSizeMinusOne))));
    vec4 texel10 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(1, 0), ivec2(0, 0), texSizeMinusOne))));
    vec4 texel11 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(1, 1), ivec2(0, 0), texSizeMinusOne))));
    vec4 texel12 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(1, 2), ivec2(0, 0), texSizeMinusOne))));
    vec4 texel13 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(1, 3), ivec2(0, 0), texSizeMinusOne))));
    vec4 texel20 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(2, 0), ivec2(0, 0), texSizeMinusOne))));
    vec4 texel21 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(2, 1), ivec2(0, 0), texSizeMinusOne))));
    vec4 texel22 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(2, 2), ivec2(0, 0), texSizeMinusOne))));
    vec4 texel23 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(2, 3), ivec2(0, 0), texSizeMinusOne))));
    vec4 texel30 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(3, 0), ivec2(0, 0), texSizeMinusOne))));
    vec4 texel31 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(3, 1), ivec2(0, 0), texSizeMinusOne))));
    vec4 texel32 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(3, 2), ivec2(0, 0), texSizeMinusOne))));
    vec4 texel33 = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(samplePointNoClamp(tex, clamp(xy00 + ivec2(3, 3), ivec2(0, 0), texSizeMinusOne))));

    vec4 interp0Y = mixCatmullRom(texel00, texel01, texel02, texel03, weights.y);
    vec4 interp1Y = mixCatmullRom(texel10, texel11, texel12, texel13, weights.y);
    vec4 interp2Y = mixCatmullRom(texel20, texel21, texel22, texel23, weights.y);
    vec4 interp3Y = mixCatmullRom(texel30, texel31, texel32, texel33, weights.y);

    return mixCatmullRom(interp0Y, interp1Y, interp2Y, interp3Y, weights.x);
}