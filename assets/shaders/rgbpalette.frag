#pragma header

uniform vec3 uR;
uniform vec3 uG;
uniform vec3 uB;
uniform float uMult;

void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
    
    if (color.a == 0.0 || uMult == 0.0) {
        gl_FragColor = color;
        return;
    }
    
    vec3 newColor = min(color.r * uR + color.g * uG + color.b * uB, vec3(1.0));
    
    vec3 finalColor = mix(color.rgb, newColor, uMult);
    
    gl_FragColor = vec4(finalColor, color.a);
}