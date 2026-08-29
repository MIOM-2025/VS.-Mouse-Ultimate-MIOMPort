#pragma header

// Uniform input for blur radius (set from Haxe/Flixel)
uniform float blurSize;

// Texture and output aliases (compatible with Flixel's shader system)
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main

void mainImage()
{
    // Obtain texture coordinates and screen resolution (runtime values, safe inside function)
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;

    float Pi = 6.28318530718; // 2 * PI for full circle

    // Gaussian blur settings
    float Directions = 32.0;   // Number of blur directions (higher = better quality, slower)
    float Quality = 6.0;       // Sampling quality (higher = smoother, slower)
    float Size = blurSize;     // Blur radius in pixels (passed from outside)

    // Convert radius to normalized texture coordinate space
    vec2 Radius = Size / iResolution.xy;

    // Initial pixel color
    vec4 Color = texture(iChannel0, uv);

    // Accumulate samples in all directions with decreasing weight (gaussian approximation)
    for (float d = 0.0; d < Pi; d += Pi / Directions)
    {
        for (float i = 1.0 / Quality; i <= 1.0; i += 1.0 / Quality)
        {
            Color += texture(iChannel0, uv + vec2(cos(d), sin(d)) * Radius * i);
        }
    }

    // Average the accumulated samples (adjust divisor to avoid over-darkening)
    Color /= Quality * Directions - 15.0;

    // Output final color
    fragColor = Color;
}