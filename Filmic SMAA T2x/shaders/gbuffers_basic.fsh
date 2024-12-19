#version 430

/* RENDERTARGETS: 0,1 */

uniform sampler2D lightmap;

in vec3  color, normal;
in vec2  uvLM;
in float ambientOcclusion;

layout (location = 0) out vec4 outRT0;
layout (location = 1) out vec4 outRT1;

#include "lib/common.glsl"
#include "lib/colorTransforms.glsl"

void main() {
	outRT0 = vec4(color * ambientOcclusion, 1.0) * sample2DCatmullRomLM(lightmap, uvLM);
	outRT1 = vec4(normal, 0.0);
}