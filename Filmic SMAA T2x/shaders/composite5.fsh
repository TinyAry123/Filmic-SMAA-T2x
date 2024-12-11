#version 430

/* RENDERTARGETS: 0,1,3,4 */

uniform sampler2D colortex0, colortex1, colortex2, colortex3, colortex4;

in vec2 uv;

layout (location = 0) out vec4 outRT0;
layout (location = 1) out vec4 outRT1;
layout (location = 2) out vec4 outRT3;
layout (location = 3) out vec4 outRT4;

#include "lib/common.glsl"
#include "lib/temporalAA/blending.glsl"

void main() {
	blendingPass1TAA(outRT0, outRT1.x, outRT3, outRT4.x, colortex0, colortex1, colortex2, colortex3, colortex4);
}