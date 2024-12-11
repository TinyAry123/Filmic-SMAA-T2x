#version 430

/* RENDERTARGETS: 0,1 */

uniform sampler2D colortex0, depthtex0;

in vec2 uv;

layout (location = 0) out vec4 outRT0;
layout (location = 1) out vec4 outRT1;

#include "lib/optifineSettings.glsl"
#include "lib/common.glsl"
#include "lib/colorTransforms.glsl"

void main() {
	ivec2 texelCoord = ivec2(viewSize * uv);

	outRT0.xyz = tonemapACES(samplePointNoClamp(colortex0, texelCoord).xyz);
	outRT1.x   = Z_TO_LINDEPTH(samplePointNoClamp(depthtex0, texelCoord).x);
}