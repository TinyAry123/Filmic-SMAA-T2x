#version 430

/* RENDERTARGETS: 0 */

uniform sampler2D colortex0;

in vec2 uv;

layout (location = 0) out vec4 outRT0;

#include "lib/common.glsl"
#include "lib/colorTransforms.glsl"

void main() {
	outRT0.xyz = LINSRGB_TO_SRGB(ACESCG_TO_LINSRGB(samplePointNoClamp(colortex0, ivec2(viewSize * uv)).xyz));
}