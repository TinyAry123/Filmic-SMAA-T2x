void jitterTAA(inout vec4 clipSpacePosition) {
    clipSpacePosition.xy += 2.0 * clipSpacePosition.w * jitterOffsetsTAA[frameMod2]; // Offsets should be in [-w, w] clip space range. 
}