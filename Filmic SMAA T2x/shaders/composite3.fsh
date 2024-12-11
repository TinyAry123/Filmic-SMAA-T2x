#version 430

/* RENDERTARGETS: 0,1 */

uniform sampler2D colortex0, colortex1, colortex13;

in vec2 uv;

layout (location = 0) out vec4 outRT0;
layout (location = 1) out vec4 outRT1;

#include "lib/common.glsl"
#include "lib/SMAA/neighborhoodBlending.glsl"

void main() {
	neighborhoodBlendingSMAAT2X(outRT0.xyz, outRT1.x, colortex0, colortex1, colortex13, uv);
}