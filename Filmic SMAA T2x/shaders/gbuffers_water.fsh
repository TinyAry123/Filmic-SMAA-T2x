#version 430

/* RENDERTARGETS: 0,1 */

uniform sampler2D gtexture, lightmap;
uniform float     alphaTestRef;

in vec3  color, normal;
in vec2  uv, uvLM;
in float ambientOcclusion;

layout (location = 0) out vec4 outRT0;
layout (location = 1) out vec4 outRT1;

#include "lib/common.glsl"
#include "lib/colorTransforms.glsl"

void main() {
	outRT0 = sampleLinear(gtexture, uv);

	if (outRT0.w < alphaTestRef) discard;

	outRT0 = vec4(color * ambientOcclusion, 1.0) * LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(outRT0)) * sample2DCatmullRomLM(lightmap, uvLM);
	outRT1 = vec4(normal, 0.0);
}