import openfl.filters.ShaderFilter;

var rainbowShader:CustomShader;
var shaderFilter:ShaderFilter;
var timer:Float = 0;
var rainbowActive:Bool = false;

function create() {
    if(PlayState.variation != "Legacy"){
        disableScript();
        return;
    }

    if(!Options.gameplayShaders){
        disableScript();
        return;
    }

    rainbowShader = new CustomShader("rgbpalette");
    rainbowShader.uR = [1, 0, 0];
    rainbowShader.uG = [0, 1, 0];
    rainbowShader.uB = [0, 0, 1];
    rainbowShader.uMult = 1.0;

    shaderFilter = new ShaderFilter(rainbowShader);
}

function toggleRainbow(on:Bool) {
    rainbowActive = on;
    if (on) {
        FlxG.camera.setFilters([shaderFilter]);
    } else {
        FlxG.camera.setFilters([]);
    }
}

function beatHit(curBeat:Int) {
    switch(curBeat) {
        case 32, 128: toggleRainbow(true);
        case 64, 160: toggleRainbow(false);
    }
}

function postUpdate(elapsed:Float) {
    if (!rainbowActive) return;

    timer += elapsed * 1;
    var brightness:Float = 0.7; 
    
    var r = ((Math.sin(timer) + 1) / 2) * brightness;
    var g = ((Math.sin(timer + (2 * Math.PI / 3)) + 1) / 2) * brightness;
    var b = ((Math.sin(timer + (4 * Math.PI / 3)) + 1) / 2) * brightness;

    rainbowShader.uR = [r, g, b];
    rainbowShader.uG = [g, b, r];
    rainbowShader.uB = [b, r, g];
}

function destroy() {
    FlxG.camera.setFilters([]);
}