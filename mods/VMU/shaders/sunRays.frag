#pragma header

uniform vec2 lightPos;
uniform float weight;
uniform float decay;
uniform float density;
uniform float exposure;

#define SAMPLES 40 

void main() {
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 coord = uv;
    
    vec4 tex = flixel_texture2D(bitmap, uv);
    float occ = tex.a;
        
    vec2 dtc = (coord - lightPos) * (1.0 / float(SAMPLES) * density);
    dtc.x *= 4.0;
    dtc.y *= 0.05;
    
    float dither = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    float illumdecay = 1.0;
    
    for(int i=0; i<SAMPLES; i++) {
        coord -= dtc;
        float s = flixel_texture2D(bitmap, coord + (dtc * dither)).a;
        s *= illumdecay * weight;
        occ += s;
        illumdecay *= decay;
    }
        
    vec3 rayColor = vec3(1.0, 0.4, 0.0);
    vec3 glow = (occ - tex.a) * exposure * rayColor;
    
    gl_FragColor = vec4(tex.rgb + glow, tex.a);
}