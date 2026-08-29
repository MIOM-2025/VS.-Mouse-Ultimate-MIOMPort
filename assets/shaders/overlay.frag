#pragma header
uniform sampler2D overlayTexture;
uniform float sourceAlpha;
float overlay( float S, float D ) {
    return float( D > 0.5 ) * ( 2.0 * (S + D - D * S ) - 1.0 )
    + float( D <= 0.5 ) * ( ( 2.0 * D ) * S );
}
void main() {
    vec4 D = texture2D( bitmap, openfl_TextureCoordv );  //destination color
    vec4 S = texture2D( overlayTexture, openfl_TextureCoordv );  //source color
    gl_FragColor = vec4(
        mix(
            vec3( overlay( S.r, D.r ), overlay( S.g, D.g ), overlay( S.b, D.b ) ),
            D.rgb,
            1.0 - sourceAlpha
        ),
        D.a
    );
}
