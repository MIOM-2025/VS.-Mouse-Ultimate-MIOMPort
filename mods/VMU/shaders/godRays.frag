#pragma header

uniform vec2 lightPos;
uniform float weight;
uniform float decay;
uniform float density;
uniform float exposure;

void main() {
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 deltaTexCoord = (uv - lightPos);
    deltaTexCoord *= 1.0 / float(100) * density;
    
    vec4 color = texture2D(bitmap, uv);
    float illuminationDecay = 1.0;
    
    for (int i = 0; i < 100; i++) {
        uv -= deltaTexCoord;
        vec4 sample = texture2D(bitmap, uv);
        sample *= illuminationDecay * weight;
        color += sample;
        illuminationDecay *= decay;
    }
    
    gl_FragColor = color * exposure;
}