#pragma header

// Takes an image as the input.
uniform float merge;
uniform sampler2D bitmapOverlay;
uniform bool hardlight;

const float thresh = (1. / 255.);

vec4 blendOverlay(vec4 base, vec4 blend) {
    // Depending on the base color, compute a linear interpolation
    // between black (base layer = 0), the top layer (base layer = 0.5), and white (base layer = 1.0)
    
    // HARDLIGHT only inverts base and blend relationship. same math as overlay !!
    // https://en.wikipedia.org/wiki/Blend_modes#Hard_Light
    
    if (merge * blend.a <= thresh) return base;
    
    blend.rgb /= blend.a;
    return mix(base, mix(1. - 2. * (1. - base) * (1. - blend), 2. * base * blend, step(hardlight ? blend : base, vec4(.5))), blend.a * merge);
}

void main() {
    vec4 base = flixel_texture2D(bitmap, openfl_TextureCoordv);
    vec4 blend = texture2D(bitmapOverlay, openfl_TextureCoordv);
    
    gl_FragColor = blendOverlay(base, blend);
}
