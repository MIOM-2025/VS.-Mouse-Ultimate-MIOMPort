#pragma header

const float amount = 1.0;

uniform float dim;
uniform float Size;

void main(void)
{
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 texSize = openfl_TextureSize;
    vec2 scale = Size / texSize;

    vec4 color = flixel_texture2D(bitmap, uv);
    vec4 sum = color;

    // 8 directions hardcoded (angles: 0, 45, 90, 135, 180, 225, 270, 315)
    sum += flixel_texture2D(bitmap, uv + vec2( 1.0,  0.0) * scale);
    sum += flixel_texture2D(bitmap, uv + vec2( 0.70710678,  0.70710678) * scale);
    sum += flixel_texture2D(bitmap, uv + vec2( 0.0,  1.0) * scale);
    sum += flixel_texture2D(bitmap, uv + vec2(-0.70710678,  0.70710678) * scale);
    sum += flixel_texture2D(bitmap, uv + vec2(-1.0,  0.0) * scale);
    sum += flixel_texture2D(bitmap, uv + vec2(-0.70710678, -0.70710678) * scale);
    sum += flixel_texture2D(bitmap, uv + vec2( 0.0, -1.0) * scale);
    sum += flixel_texture2D(bitmap, uv + vec2( 0.70710678, -0.70710678) * scale);

    // Compensation factor: original 128 samples / 8 samples = 16, combined with denominator
    float factor = 16.0 / (dim * 128.0 - 15.0);
    sum *= factor;

    vec4 bloom = (color / dim) + sum;
    gl_FragColor = bloom;
}