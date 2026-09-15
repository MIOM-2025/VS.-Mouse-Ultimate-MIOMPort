import funkin.backend.shaders.WiggleEffect;
import openfl.filters.ShaderFilter;

if (!FlxG.save.data.modcharts) {
    disableScript();
    return;
}

var wiggleEffect:WiggleEffect;
var camSustains:HudCamera;

function create() {
    wiggleEffect = new WiggleEffect();
    wiggleEffect.waveFrequency = 9.42; 
    wiggleEffect.waveSpeed = 10;
    wiggleEffect.waveAmplitude = 0; 

    camSustains = new HudCamera();
    camSustains.bgColor = 0;
    camSustains.downscroll = Options.downscroll; 
    camSustains.setFilters([new ShaderFilter(wiggleEffect.shader)]);
    
    FlxG.cameras.add(camSustains, false);
}

function onNoteCreation(event) {
    var note = event.note;
    if (note.strumLine == strumLines.members[0] && note.isSustainNote) {
        note.cameras = [camSustains];
    }
}

function stepHit(curStep:Int) {
    wiggleEffect.waveAmplitude = 0;

    if ((curStep >= 299 && curStep < 304) || (curStep >= 335 && curStep < 350) || (curStep >= 368 && curStep < 385)) {
        wiggleEffect.waveAmplitude = 0.005;
    }
}

function postUpdate(elapsed:Float) {
    camSustains.scroll.set(camHUD.scroll.x, camHUD.scroll.y);
    camSustains.zoom = camHUD.zoom;
    
    wiggleEffect.shader.uTime.value = [Conductor.songPosition / 1000];
}