/*
This file is included and universal for all shader files. 

All LOD's are disabled for colortex0-15. 
Built-in texelFetch() does not automatically clamp texel coord (returns zero outside uv [0, 1]). 

samplePointNoClamp(sampler1D | sampler2D | sampler3D, int | ivec2 | ivec3) - use when texel coord is already calculated and clamped. 
samplePoint(sampler1D | sampler2D | sampler3D, int | ivec2 | ivec3)        - use when texel coord is already calculated. 
sampleNearest(sampler1D | sampler2D | sampler3D, float | vec2 | vec3)      - rounds uv to nearest texel. 
sampleLinear(sampler1D | sampler2D | sampler3D, float | vec2 | vec3)       - lerp() between texels at sub-pixel coord. 
sample2DCatmullRom5Taps(sampler2D, vec2)                                   - 5 bilinear taps, approximation of 2D Catmull-Rom filtering at sub-pixel coord. 
sample2DCatmullRom9Taps(sampler2D, vec2)                                   - 9 bilinear taps, approximation of 2D Catmull-Rom filtering at sub-pixel coord. 
sample2DCatmullRom(sampler2D, vec2)                                        - Full 16-tap 2D Catmull-Rom filtering at sub-pixel coord. 
sample2DLanczos4(sampler2D, vec2)                                          - Full 2D 4-lobed Lanczos filtering (only intended for fixed-scale downsampling). 

projectAndDivide(mat4, vec3) - Helper function for matrix projection and perspective division for 4D homogeneous coordinate systems. 

Z_TO_LINDEPTH(float) - OpenGL's z (screen space depth) to a usable form of linear depth. 
LINDEPTH_TO_Z(float) - Inverse. 

TBI: 
1. sample2DCatmullRom5Taps()
2. sample2DCatmullRom9Taps()
3. sample2DLanczos4()
*/

uniform mat4  gbufferProjection, gbufferModelView, gbufferProjectionInverse, gbufferModelViewInverse, gbufferPreviousProjection, gbufferPreviousModelView;
uniform vec3  cameraPosition, previousCameraPosition;
uniform vec2  viewSize, texelSize;
uniform float frameTime, near, far;
uniform int   frameMod2, previousFrameMod2;

#define samplePointNoClamp(tex, xy) texelFetch(tex, xy, 0)
#define samplePoint(tex, xy)        texelFetch(tex, clamp(xy, ivec2(0, 0), textureSize(tex, 0) - 1), 0)
#define sampleLinear(tex, uv)       texture(tex, uv)

vec3 eyeCameraPosition = cameraPosition + gbufferModelViewInverse[3].xyz;

vec2 jitterOffsetsTAA[2] = vec2[2](
    texelSize * vec2( 0.25, -0.25),
    texelSize * vec2(-0.25,  0.25)
);

vec4 sampleNearest(sampler1D tex, float u) {
    int texSize = textureSize(tex, 0);

    return samplePointNoClamp(tex, clamp(int(texSize * u), 0, texSize - 1));
}

vec4 sampleNearest(sampler2D tex, vec2 uv) {
    ivec2 texSize = textureSize(tex, 0);

    return samplePointNoClamp(tex, clamp(ivec2(texSize * uv), ivec2(0, 0), texSize - 1));
}

vec4 sampleNearest(sampler3D tex, vec3 uvw) {
    ivec3 texSize = textureSize(tex, 0);

    return samplePointNoClamp(tex, clamp(ivec3(texSize * uvw), ivec3(0, 0, 0), texSize - 1));
}

float mixCatmullRom(float a, float b, float c, float d, float t) {
    return b + t * (0.5 * (c - a) + t * (a + 2.0 * c - 2.5 * b - 0.5 * d + t * (1.5 * (b - c) + 0.5 * (d - a))));
}

vec2 mixCatmullRom(vec2 a, vec2 b, vec2 c, vec2 d, float t) {
    return vec2(mixCatmullRom(a.x, b.x, c.x, d.x, t), mixCatmullRom(a.y, b.y, c.y, d.y, t));
}

vec3 mixCatmullRom(vec3 a, vec3 b, vec3 c, vec3 d, float t) {
    return vec3(mixCatmullRom(a.x, b.x, c.x, d.x, t), mixCatmullRom(a.y, b.y, c.y, d.y, t), mixCatmullRom(a.z, b.z, c.z, d.z, t));
}

vec4 mixCatmullRom(vec4 a, vec4 b, vec4 c, vec4 d, float t) {
    return vec4(mixCatmullRom(a.x, b.x, c.x, d.x, t), mixCatmullRom(a.y, b.y, c.y, d.y, t), mixCatmullRom(a.z, b.z, c.z, d.z, t), mixCatmullRom(a.w, b.w, c.w, d.w, t));
}

vec4 sample2DCatmullRom(sampler2D tex, vec2 uv) {
    ivec2 texSize         = textureSize(tex, 0);
    ivec2 texSizeMinusOne = texSize - 1;

    vec2 xy      = texSize * uv - 0.5;
    vec2 weights = fract(xy);
    ivec2 xy00   = ivec2(floor(xy)) - 1;

    vec4 texel00 = samplePointNoClamp(tex, clamp(xy00 + ivec2(0, 0), ivec2(0, 0), texSizeMinusOne));
    vec4 texel01 = samplePointNoClamp(tex, clamp(xy00 + ivec2(0, 1), ivec2(0, 0), texSizeMinusOne));
    vec4 texel02 = samplePointNoClamp(tex, clamp(xy00 + ivec2(0, 2), ivec2(0, 0), texSizeMinusOne));
    vec4 texel03 = samplePointNoClamp(tex, clamp(xy00 + ivec2(0, 3), ivec2(0, 0), texSizeMinusOne));
    vec4 texel10 = samplePointNoClamp(tex, clamp(xy00 + ivec2(1, 0), ivec2(0, 0), texSizeMinusOne));
    vec4 texel11 = samplePointNoClamp(tex, clamp(xy00 + ivec2(1, 1), ivec2(0, 0), texSizeMinusOne));
    vec4 texel12 = samplePointNoClamp(tex, clamp(xy00 + ivec2(1, 2), ivec2(0, 0), texSizeMinusOne));
    vec4 texel13 = samplePointNoClamp(tex, clamp(xy00 + ivec2(1, 3), ivec2(0, 0), texSizeMinusOne));
    vec4 texel20 = samplePointNoClamp(tex, clamp(xy00 + ivec2(2, 0), ivec2(0, 0), texSizeMinusOne));
    vec4 texel21 = samplePointNoClamp(tex, clamp(xy00 + ivec2(2, 1), ivec2(0, 0), texSizeMinusOne));
    vec4 texel22 = samplePointNoClamp(tex, clamp(xy00 + ivec2(2, 2), ivec2(0, 0), texSizeMinusOne));
    vec4 texel23 = samplePointNoClamp(tex, clamp(xy00 + ivec2(2, 3), ivec2(0, 0), texSizeMinusOne));
    vec4 texel30 = samplePointNoClamp(tex, clamp(xy00 + ivec2(3, 0), ivec2(0, 0), texSizeMinusOne));
    vec4 texel31 = samplePointNoClamp(tex, clamp(xy00 + ivec2(3, 1), ivec2(0, 0), texSizeMinusOne));
    vec4 texel32 = samplePointNoClamp(tex, clamp(xy00 + ivec2(3, 2), ivec2(0, 0), texSizeMinusOne));
    vec4 texel33 = samplePointNoClamp(tex, clamp(xy00 + ivec2(3, 3), ivec2(0, 0), texSizeMinusOne));

    vec4 interp0Y = mixCatmullRom(texel00, texel01, texel02, texel03, weights.y);
    vec4 interp1Y = mixCatmullRom(texel10, texel11, texel12, texel13, weights.y);
    vec4 interp2Y = mixCatmullRom(texel20, texel21, texel22, texel23, weights.y);
    vec4 interp3Y = mixCatmullRom(texel30, texel31, texel32, texel33, weights.y);

    return mixCatmullRom(interp0Y, interp1Y, interp2Y, interp3Y, weights.x);
}

vec3 projectAndDivide(mat4 matrix, vec3 position) {
	vec4 homogeneousPosition = matrix * vec4(position, 1.0);

	return homogeneousPosition.xyz / homogeneousPosition.w;
}

float Z_TO_LINDEPTH(float depth) {
	return far * near / mix(far, near, depth);
}

float LINDEPTH_TO_Z(float depth) {
	return far * (near - depth) / (depth * (near - far));
}