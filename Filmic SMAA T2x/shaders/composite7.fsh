#version 430

/* RENDERTARGETS: 0,1,5,6 */

uniform sampler2D colortex0, colortex1, colortex2, colortex5, colortex6;

in vec2 uv;

layout (location = 0) out vec4 outRT0;
layout (location = 1) out vec4 outRT1;
layout (location = 2) out vec4 outRT5;
layout (location = 3) out vec4 outRT6;

#include "lib/common.glsl"
#include "lib/temporalAA/blending.glsl"

void main() {
	blendingPass2TAA(outRT0, outRT1.x, outRT5, outRT6.x, colortex0, colortex1, colortex2, colortex5, colortex6);
}