#version 430

uniform mat4 modelViewMatrix, projectionMatrix;

in vec3 vaPosition;
in vec2 vaUV0;

out vec2 uv;

mat4 modelViewProjectionMatrix = projectionMatrix * modelViewMatrix;

#include "lib/common.glsl"

void main() {
	gl_Position = modelViewProjectionMatrix * vec4(vaPosition, 1.0);
	uv          = vaUV0;
}