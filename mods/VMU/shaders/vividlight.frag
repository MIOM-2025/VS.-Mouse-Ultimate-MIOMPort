    #pragma header

    uniform sampler2D bitmapOverlay;
    uniform float merge;

    float colorDodge(float base, float blend)
    {
        return (blend == 1.0) ? blend : min(base / (1.0 - blend), 1.0);
    }

    float colorBurn(float base, float blend)
    {
        return (blend == 0.0) ? blend : max((1.0 - ((1.0 - base) / blend)), 0.0);
    }

    float vividLight(float base, float blend)
    {
        return ((blend < 0.5) ? colorBurn(base, (2.0 * blend)) : colorDodge(base, (2.0 * (blend - 0.5))));
    }

    void main()
    {
        vec4 base = texture2D(bitmap, openfl_TextureCoordv);
        vec4 blend = texture2D(bitmapOverlay, openfl_TextureCoordv);
        
        vec4 result = vec4(
            vividLight(base.r, blend.r),
            vividLight(base.g, blend.g),
            vividLight(base.b, blend.b),
            base.a
        );

        gl_FragColor = mix(base, result, merge);
    }