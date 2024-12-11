#version 430

/* RENDERTARGETS: 13 */

uniform sampler2D colortex0, colortex1;

in vec2 uv;

layout (location = 0) out vec4 outRT13;

#include "lib/common.glsl"
#include "lib/SMAA/edgeDetection.glsl"

void main() {
	colorEdgeDetectionSMAA(outRT13.xy, colortex0, uv);
	depthEdgeDetectionSMAA(outRT13.zw, colortex1, uv);

	outRT13.xy = max(outRT13.xy, outRT13.zw);
}