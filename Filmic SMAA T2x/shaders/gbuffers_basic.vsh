#version 430

uniform mat4 modelViewMatrix, projectionMatrix, textureMatrix;
uniform mat3 normalMatrix;

in vec4  vaColor;
in vec3  vaPosition, vaNormal;
in ivec2 vaUV2;

out vec3  color, normal;
out vec2  uvLM;
out float ambientOcclusion;

#include "lib/common.glsl"
#include "lib/temporalAA/jitter.glsl"
#include "lib/colorTransforms.glsl"

mat4 modelViewProjectionMatrix = projectionMatrix * modelViewMatrix;

void main() {
	gl_Position      = modelViewProjectionMatrix * vec4(vaPosition, 1.0);
	color            = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(vaColor.xyz));
	normal           = normalMatrix * vaNormal;
	uvLM             = 0.00390625 * vaUV2 + 0.03125;
	ambientOcclusion = SRGB_TO_LINSRGB(vaColor.w);

	jitterTAA(gl_Position);
}