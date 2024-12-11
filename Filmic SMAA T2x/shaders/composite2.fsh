#version 430

/* RENDERTARGETS: 13 */

uniform sampler2D colortex13, colortex14, colortex15;

in vec2 uv;

layout (location = 0) out vec4 outRT13;

#include "lib/common.glsl"
#include "lib/SMAA/blendingWeightCalculation.glsl"

vec4 subsampleIndices1X = vec4(0.0);

vec4 subsampleIndicesT2X = vec4[2](
	vec4(1.0, 1.0, 1.0, 0.0),
	vec4(2.0, 2.0, 2.0, 0.0)
)[frameMod2];

void main() {
	blendingWeightCalculationSMAA(outRT13, colortex13, colortex14, colortex15, subsampleIndicesT2X, uv);
}