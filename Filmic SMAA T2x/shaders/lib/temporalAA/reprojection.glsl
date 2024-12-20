mat4 inverseMat4(mat4 m) { // Generated by ChatGPT. 
    float det =
        m[0][0] * (m[1][1] * (m[2][2] * m[3][3] - m[3][2] * m[2][3]) -
                   m[2][1] * (m[1][2] * m[3][3] - m[3][2] * m[1][3]) +
                   m[3][1] * (m[1][2] * m[2][3] - m[2][2] * m[1][3]))
        - m[0][1] * (m[1][0] * (m[2][2] * m[3][3] - m[3][2] * m[2][3]) -
                     m[2][0] * (m[1][2] * m[3][3] - m[3][2] * m[1][3]) +
                     m[3][0] * (m[1][2] * m[2][3] - m[2][2] * m[1][3]))
        + m[0][2] * (m[1][0] * (m[2][1] * m[3][3] - m[3][1] * m[2][3]) -
                     m[2][0] * (m[1][1] * m[3][3] - m[3][1] * m[1][3]) +
                     m[3][0] * (m[1][1] * m[2][3] - m[2][1] * m[1][3]))
        - m[0][3] * (m[1][0] * (m[2][1] * m[3][2] - m[3][1] * m[2][2]) -
                     m[2][0] * (m[1][1] * m[3][2] - m[3][1] * m[1][2]) +
                     m[3][0] * (m[1][1] * m[2][2] - m[2][1] * m[1][2]));

    if (det == 0.0) {
        return mat4(0.0);
    }

    float invDet = 1.0 / det;

    mat4 inv;

    inv[0][0] = invDet * (m[1][1] * (m[2][2] * m[3][3] - m[3][2] * m[2][3]) -
                          m[2][1] * (m[1][2] * m[3][3] - m[3][2] * m[1][3]) +
                          m[3][1] * (m[1][2] * m[2][3] - m[2][2] * m[1][3]));
    inv[0][1] = -invDet * (m[0][1] * (m[2][2] * m[3][3] - m[3][2] * m[2][3]) -
                           m[2][1] * (m[0][2] * m[3][3] - m[3][2] * m[0][3]) +
                           m[3][1] * (m[0][2] * m[2][3] - m[2][2] * m[0][3]));
    inv[0][2] = invDet * (m[0][1] * (m[1][2] * m[3][3] - m[3][2] * m[1][3]) -
                          m[1][1] * (m[0][2] * m[3][3] - m[3][2] * m[0][3]) +
                          m[3][1] * (m[0][2] * m[1][3] - m[1][2] * m[0][3]));
    inv[0][3] = -invDet * (m[0][1] * (m[1][2] * m[2][3] - m[2][2] * m[1][3]) -
                           m[1][1] * (m[0][2] * m[2][3] - m[2][2] * m[0][3]) +
                           m[2][1] * (m[0][2] * m[1][3] - m[1][2] * m[0][3]));

    inv[1][0] = -invDet * (m[1][0] * (m[2][2] * m[3][3] - m[3][2] * m[2][3]) -
                           m[2][0] * (m[1][2] * m[3][3] - m[3][2] * m[1][3]) +
                           m[3][0] * (m[1][2] * m[2][3] - m[2][2] * m[1][3]));
    inv[1][1] = invDet * (m[0][0] * (m[2][2] * m[3][3] - m[3][2] * m[2][3]) -
                          m[2][0] * (m[0][2] * m[3][3] - m[3][2] * m[0][3]) +
                          m[3][0] * (m[0][2] * m[2][3] - m[2][2] * m[0][3]));
    inv[1][2] = -invDet * (m[0][0] * (m[1][2] * m[3][3] - m[3][2] * m[1][3]) -
                           m[1][0] * (m[0][2] * m[3][3] - m[3][2] * m[0][3]) +
                           m[3][0] * (m[0][2] * m[1][3] - m[1][2] * m[0][3]));
    inv[1][3] = invDet * (m[0][0] * (m[1][2] * m[2][3] - m[2][2] * m[1][3]) -
                          m[1][0] * (m[0][2] * m[2][3] - m[2][2] * m[0][3]) +
                          m[2][0] * (m[0][2] * m[1][3] - m[1][2] * m[0][3]));

    inv[2][0] = invDet * (m[1][0] * (m[2][1] * m[3][3] - m[3][1] * m[2][3]) -
                          m[2][0] * (m[1][1] * m[3][3] - m[3][1] * m[1][3]) +
                          m[3][0] * (m[1][1] * m[2][3] - m[2][1] * m[1][3]));
    inv[2][1] = -invDet * (m[0][0] * (m[2][1] * m[3][3] - m[3][1] * m[2][3]) -
                           m[2][0] * (m[0][1] * m[3][3] - m[3][1] * m[0][3]) +
                           m[3][0] * (m[0][1] * m[2][3] - m[2][1] * m[0][3]));
    inv[2][2] = invDet * (m[0][0] * (m[1][1] * m[3][3] - m[3][1] * m[1][3]) -
                          m[1][0] * (m[0][1] * m[3][3] - m[3][1] * m[0][3]) +
                          m[3][0] * (m[0][1] * m[1][3] - m[1][1] * m[0][3]));
    inv[2][3] = -invDet * (m[0][0] * (m[1][1] * m[2][3] - m[2][1] * m[1][3]) -
                           m[1][0] * (m[0][1] * m[2][3] - m[2][1] * m[0][3]) +
                           m[2][0] * (m[0][1] * m[1][3] - m[1][1] * m[0][3]));

    inv[3][0] = -invDet * (m[1][0] * (m[2][1] * m[3][2] - m[3][1] * m[2][2]) -
                           m[2][0] * (m[1][1] * m[3][2] - m[3][1] * m[1][2]) +
                           m[3][0] * (m[1][1] * m[2][2] - m[2][1] * m[1][2]));
    inv[3][1] = invDet * (m[0][0] * (m[2][1] * m[3][2] - m[3][1] * m[2][2]) -
                          m[2][0] * (m[0][1] * m[3][2] - m[3][1] * m[0][2]) +
                          m[3][0] * (m[0][1] * m[2][2] - m[2][1] * m[0][2]));
    inv[3][2] = -invDet * (m[0][0] * (m[1][1] * m[3][2] - m[3][1] * m[1][2]) -
                           m[1][0] * (m[0][1] * m[3][2] - m[3][1] * m[0][2]) +
                           m[3][0] * (m[0][1] * m[1][2] - m[1][1] * m[0][2]));
    inv[3][3] = invDet * (m[0][0] * (m[1][1] * m[2][2] - m[2][1] * m[1][2]) -
                          m[1][0] * (m[0][1] * m[2][2] - m[2][1] * m[0][2]) +
                          m[2][0] * (m[0][1] * m[1][2] - m[1][1] * m[0][2]));

    return inv;
}

mat4 gbufferPreviousProjectionInverse = inverseMat4(gbufferPreviousProjection);
mat4 gbufferPreviousModelViewInverse  = inverseMat4(gbufferPreviousModelView);

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

vec3 reprojectionPositionTAA2(vec3 viewSpacePosition) { // Current view space --> previous view space.     
    vec3 p2 = (gbufferModelViewInverse * vec4(viewSpacePosition, 1.0)).xyz;

    vec3 p3 = p2 + cameraPosition - previousCameraPosition;

    vec3 p4 = (gbufferPreviousModelView * vec4(p3, 1.0)).xyz;

    return p4;
}

vec3 reprojectionPositionInverseTAA(vec3 screenSpacePosition) { // Previous screen space --> current screen space. 
    vec3 p0 = 2.0 * screenSpacePosition - 1.0;

    vec3 p1 = projectAndDivide(gbufferPreviousProjectionInverse, p0);
    
    vec3 p2 = (gbufferPreviousModelViewInverse * vec4(p1, 1.0)).xyz;

    vec3 p3 = p2 + previousCameraPosition - cameraPosition;

    vec3 p4 = (gbufferModelView * vec4(p3, 1.0)).xyz;

    vec3 p5 = projectAndDivide(gbufferProjection, p4);
    
    vec3 p6 = 0.5 * p5 + 0.5;

    return p6;
}

vec3 reprojectionPositionInverseTAA2(vec3 viewSpacePosition) { // Previous view space --> current view space. 
    vec3 p2 = (gbufferPreviousModelViewInverse * vec4(viewSpacePosition, 1.0)).xyz;

    vec3 p3 = p2 + previousCameraPosition - cameraPosition;

    vec3 p4 = (gbufferModelView * vec4(p3, 1.0)).xyz;

    return p4;
}