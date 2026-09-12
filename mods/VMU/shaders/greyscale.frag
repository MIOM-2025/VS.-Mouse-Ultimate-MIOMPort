#pragma header

uniform float strength;

void main()
{
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 grayscale = vec3(gray);
    vec3 mixed = mix(color.rgb, grayscale, strength);
    gl_FragColor = vec4(mixed, color.a);
}
