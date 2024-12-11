#version 430

/* RENDERTARGETS: 0 */

uniform sampler2D colortex0;

in vec2 uv;

layout (location = 0) out vec4 outRT0;

#include "lib/common.glsl"

void main() {
	outRT0 = samplePointNoClamp(colortex0, ivec2(viewSize * uv));
}