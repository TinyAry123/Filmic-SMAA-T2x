vec3 reprojectionPositionTAA(vec3 screenSpacePosition) { // Current screen space --> previous screen space. 
    vec3 p0 = 2.0 * screenSpacePosition - 1.0;

    vec3 p1 = projectAndDivide(gbufferProjectionInverse, p0);
    
    vec3 p2 = (gbufferModelViewInverse * vec4(p1, 1.0)).xyz;

    vec3 p3 = p2 + cameraPosition - previousCameraPosition;

    vec3 p4 = (gbufferPreviousModelView * vec4(p3, 1.0)).xyz;

    vec3 p5 = projectAndDivide(gbufferPreviousProjection, p4);
    
    vec3 p6 = 0.5 * p5 + 0.5;

    return p6;
}