#pragma header
uniform float iTime;
void main() {
    vec2 uv = openfl_TextureCoordv;
    
    // using a low frequency (5.0) for that smooth red-line look
    // this math ensures the top of one segment matches the bottom of the next
    float wave = sin((uv.y * 5.0) + (iTime * 2.0)) * 0.1;
    
    uv.x += wave;
    gl_FragColor = flixel_texture2D(bitmap, uv);
}