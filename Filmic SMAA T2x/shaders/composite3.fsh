#version 430

/* RENDERTARGETS: 0,1,2 */

uniform sampler2D colortex0, colortex1, colortex2, colortex13;

in vec2 uv;

layout (location = 0) out vec4 outRT0;
layout (location = 1) out vec4 outRT1;
layout (location = 2) out vec4 outRT2;

#include "lib/common.glsl"
#include "lib/SMAA/neighborhoodBlending.glsl"

void main() {
	neighborhoodBlendingSMAATemporal(outRT0.xyz, outRT1.xyz, outRT2.xy, colortex0, colortex1, colortex13, uv);
}