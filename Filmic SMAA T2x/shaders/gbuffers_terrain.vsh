#version 430

uniform mat4 modelViewMatrix, projectionMatrix, textureMatrix;
uniform mat3 normalMatrix;
uniform vec3 chunkOffset;

in vec4  vaColor;
in vec3  vaPosition, vaNormal;
in vec2  vaUV0;
in ivec2 vaUV2;

out vec3  color, normal;
out vec2  uv, uvLM;
out float ambientOcclusion;

#include "lib/common.glsl"
#include "lib/temporalAA/jitter.glsl"
#include "lib/colorTransforms.glsl"

mat4 modelViewProjectionMatrix = projectionMatrix * modelViewMatrix;

void main() {
	gl_Position      = modelViewProjectionMatrix * vec4(vaPosition + chunkOffset, 1.0);
	color            = LINSRGB_TO_ACESCG(SRGB_TO_LINSRGB(vaColor.xyz));
	normal           = normalMatrix * vaNormal;
	uv               = (textureMatrix * vec4(vaUV0, 0.0, 1.0)).xy;
	uvLM             = 0.00390625 * vaUV2 + 0.03125;
	ambientOcclusion = SRGB_TO_LINSRGB(vaColor.w);

	jitterTAA(gl_Position);
}