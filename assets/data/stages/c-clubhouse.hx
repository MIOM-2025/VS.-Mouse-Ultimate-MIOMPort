import openfl.filters.ShaderFilter;
import openfl.display.BlendMode;

function postCreate() {
    if(!Options.gameplayShaders) return;
    var blurEffect = new ShaderFilter(new CustomShader("blur"));
    blurEffect.shader.blurSize = 4.0;
}