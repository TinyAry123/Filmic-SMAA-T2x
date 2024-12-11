#version 430

/* RENDERTARGETS: 2 */

uniform sampler2D colortex1;

in vec2 uv;

layout (location = 0) out vec4 outRT2;

#include "lib/common.glsl"
#include "lib/temporalAA/reprojection.glsl"

void main() {
	vec3 screenSpacePosition = vec3(uv, LINDEPTH_TO_Z(samplePointNoClamp(colortex1, ivec2(viewSize * uv)).x));

	outRT2.xyz = reprojectionPositionTAA(screenSpacePosition);
	outRT2.xy  = screenSpacePosition.xy - outRT2.xy;           // Screen space velocity in xy. 
	outRT2.z   = Z_TO_LINDEPTH(outRT2.z);                      // Reprojected position depth in z. 
}