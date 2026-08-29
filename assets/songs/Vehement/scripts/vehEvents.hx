importScript("data/scripts/lyrics");

import openfl.display.BlendMode;
import flixel.effects.FlxFlicker;
import flixel.util.FlxColor;

if(PlayState.variation != null) {
    disableScript();
    return;
}

var adjustColor:CustomShader = new CustomShader('adjustColor');
var vehVignette, redVig, redGrad, spotLight:FunkinSprite;
var vfxSprites:Array<FunkinSprite> = [];
var mainSprites:Array<FunkinSprite> = [];
var vSprites:Array<FunkinSprite> = [];

public var mickeyChar = strumLines.members[0].characters;
public var donaldChar = strumLines.members[2].characters;
public var goofyChar = strumLines.members[3].characters;

var elapsedTime:Float = 0.0;
var canFlicker:Bool = false;
var allowDonaldTween:Bool = true;
var donaldTween:FlxTween = null;
var minX:Float = donaldChar[0].x - 100;

var saturation:CustomShader;
var black:FunkinSprite;

function create() introLength = 1;
function postCreate() {
    FlxG.camera.fade(FlxColor.BLACK, 0.001, false);

    for (s in stage.stageSprites) {
        var spriteName:String = Std.string(s.name);
        s.color = 0xFFFFFFFF;
        
        if (spriteName == "donald" || spriteName == "goofy") continue;
        if (spriteName == "V-fgA" || spriteName == "V-lightBulb") s.visible = false;
        
        if (StringTools.contains(spriteName, "V-")) {
            s.visible = false;
            vSprites.push(s);
        } else {
            mainSprites.push(s);
        }
    }

    black = new FunkinSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
    black.scale.set(FlxG.width * 10, FlxG.height * 10); 
    black.updateHitbox();
    black.screenCenter();
    black.scrollFactor.set();
    black.alpha = 0;

    if (!Options.lowMemoryMode) {
        vehVignette = new FunkinSprite(-325, -177.5);
        redVig = new FunkinSprite();
        redGrad = new FunkinSprite();

        redVig.blend = redGrad.blend = 9;
        vehVignette.scale.set(0.75, 0.75);

        spotLight = new FunkinSprite(0, 0);
        spotLight.alpha = 0;
        spotLight.blend = BlendMode.ADD;
        spotLight.loadGraphic(Paths.image('stages/clubhouse/spotlight'));
        spotLight.scale.set(2, 2.25);
        spotLight.updateHitbox();
        insert(members.indexOf(stage.stageSprites['V-fg2'])-1,spotLight);

        vfxSprites = [vehVignette, redVig, redGrad];

        for (s in vfxSprites) {
            s.antialiasing = Options.antialiasing;
            s.cameras = [camHUD];
            s.alpha = 0;
            insert(0, s);
        }
    }
    
    insert(members.indexOf(stage.stageSprites['donald']) + 1, black);

    setUpChars();
}

function setUpChars(){
    goofyChar[0].scale.set(0.8, 0.8);
    goofyChar[1].scale.set(0.75, 0.75);
    goofyChar[2].scale.set(0.75, 0.75);

    for(i in 1...3){
        goofyChar[i].setPosition(goofyChar[0].x, goofyChar[0].y);
        goofyChar[i].x = 1100;
        goofyChar[i].y -= 150; 

        remove(goofyChar[i]);
        insert(members.indexOf(strumLines.members[1].characters[0]) - 1, goofyChar[i]);
    }

    donaldChar[1].setPosition(donaldChar[0].x, donaldChar[0].y);
    donaldChar[1].x = 200;
    donaldChar[1].y -= 100;

    remove(donaldChar[1]);
    insert(members.indexOf(strumLines.members[0].characters[0]) - 1, donaldChar[1]);

    remove(mickeyChar[2]);
    insert(members.indexOf(strumLines.members[1].characters[0]) + 1, mickeyChar[2]);

    for (i in 0...4) swapChars(i, 0);
    goofyChar[0].visible = false;
}

function swapChars(m:Int, c:Int){
    var chosenStrum = strumLines.members[m].characters;
    for(i in 0...chosenStrum.length) chosenStrum[i].visible = false;
    if(c != null) chosenStrum[c].visible = true;
}

var bulb = stage.stageSprites.get("V-lightBulb");
function update(elapsed:Float) {
    elapsedTime += elapsed;
    
    if (spotLight != null && curBeat > 368 && elapsedTime >= 0.5) {
        elapsedTime = 0.0;
        spotLight.skew.set(FlxG.random.float(-1, 1), FlxG.random.float(-1, 1));
    }

    if (bulb != null && bulb.visible) 
        bulb.angle = Math.sin(Conductor.songPosition / 1500) * 12;
}

function postUpdate(elapsed:Float) {
    if (allowDonaldTween && donaldChar[0].animation.curAnim.name == "idle-alt") {
        if (donaldTween == null) donaldTween = FlxTween.tween(donaldChar[0], {x: minX}, 4, {type: FlxTween.PINGPONG, ease: FlxEase.sineInOut});
        else donaldTween.active = true;
    } else if (donaldTween != null) {
        donaldTween.active = false;
    }
}

function stepHit() {
    if (curStep == 952) {
        for (s in vSprites) {s.visible = true; s.alpha = 1; s.color = FlxColor.WHITE;} 
        for (y in mainSprites) { y.kill(); remove(y); }
        mainSprites = [];
        FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
    }

    if (curStep == 1464) {
        stage.stageSprites.get("V-fg").visible = false;
        stage.stageSprites.get("V-fgA").visible = true;
        var bulb = stage.stageSprites.get("V-lightBulb");
        bulb.origin.set(bulb.frameWidth / 2, 0);
        bulb.offset.set(0, 0);
        bulb.visible = true;
    }
    
    switch (curStep) {
        case 798:
            swapChars(0, 2); 
            mickeyChar[2].playAnim("nerves", true, "LOCK");
        case 1260, 1713: mickeyChar[3].playAnim("laugh", true, "LOCK");
        case 1910: mickeyChar[3].playAnim("bois", true, "LOCK");
    }
}

function beatHit(curBeat:Int) {
    if (curBeat == 0) FlxG.camera.fade(0xFF000000, (Conductor.stepCrochet / 1000) * 16, true);
    if (curBeat == 5) FlxG.camera.fade(0xFF000000, 0.001, true);
    if (curBeat == 492) for (cam in FlxG.cameras.list) cam.fade(0xFF000000, (Conductor.stepCrochet / 1000) * 32, false);

    if (canFlicker && FlxG.random.bool(15)) {
        FlxFlicker.flicker(spotLight, FlxG.random.float(0.15, 0.35), FlxG.random.float(0.02, 0.06), true, false, function() {
            spotLight.alpha = 0.5;
        });
    }

    switch(curBeat) {
        case 103: 
            goofyChar[0].visible = true;
            stage.stageSprites['goofy'].visible = false;
        case 136:
            bgFade(true);
            remove(gf); add(gf);
        case 152:
            bgFade(false);
            black.alpha = 0;
        case 196: dad.playAnim("nerves", true, "LOCK");
        case 212:
            FlxTween.tween(camHUD, {alpha: 0.5}, 0.5, {ease: FlxEase.quadOut});
            camHUD.shake(0.005, 0.5);
        case 213: 
            FlxTween.tween(camHUD, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
        case 232:
            bgFade(true);
        case 236:
            camHUD.shake(0.005, 0.5);
            bgFade(false);
            if (!Options.lowMemoryMode) {
                vehVignette.frames = Paths.getSparrowAtlas('stages/clubhouse/vehVignette');
                vehVignette.animation.addByPrefix('i', 'sorry', 24, true);
                vehVignette.playAnim('i');
                
                redVig.loadGraphic(Paths.image('stages/clubhouse/altVig')); 
                redGrad.loadGraphic(Paths.image('stages/clubhouse/feralVig2')); 

                saturation = new CustomShader("saturation");
                saturation.sat = 1; saturation.contrast = 1;
                if(Options.gameplayShaders) FlxG.camera.addShader(saturation);

                FlxTween.tween(vehVignette, {alpha: 1}, 4);
                FlxTween.tween(redVig, {alpha: 0.175}, 4);
                FlxTween.tween(redGrad, {alpha: 0.225}, 4);

                var dur:Float = (Conductor.stepCrochet / 1000) * 16;
                FlxTween.num(1, 1.2, dur, {ease: FlxEase.cubeIn}, (val:Float) -> {
                    saturation.sat = val; saturation.contrast = val;
                });
            }
        case 240:
            allowDonaldTween = false;
            if (donaldTween != null) donaldTween.cancel(); 
            donaldChar[0].setPosition(200, donaldChar[0].y - 100);
            goofyChar[0].setPosition(1100, goofyChar[0].y - 150);

            adjustColor.brightness = 0;
            adjustColor.hue = 0;
            adjustColor.contrast = 0;

            if(Options.gameplayShaders){
                for (grp in [stage.stageSprites, [boyfriend, gf, mickeyChar, donaldChar, goofyChar]]) {
                    for (a in grp) {
                        a.shader = adjustColor;
                    }
                }
                FlxTween.tween(adjustColor, {brightness: -30, hue: -15, contrast: 15}, 1, {ease: FlxEase.quadOut});
            }
        case 305, 309: FlxTween.tween(dad, {alpha: 0.5}, 0.5);
        case 307, 312: FlxTween.tween(dad, {alpha: 1}, 0.75);
        case 316, 428: // zoom in
            FlxTween.tween(black, {alpha: 0.375}, 1);
            FlxTween.tween(camGame, {angle: 5}, 2, {ease: FlxEase.cubeIn});
            FlxTween.tween(camHUD, {alpha: 0.5}, 2, {ease: FlxEase.cubeIn});
            if (!Options.lowMemoryMode) {
                FlxTween.num(1.2, 0.8, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.cubeIn}, (v:Float) -> {
                    saturation.sat = v; saturation.contrast = 1.2 - (1.2 - v) * 0.5;
                });
            }

        case 320, 432: // zoom out
            FlxTween.tween(black, {alpha: 0}, 1);
            FlxTween.tween(camGame, {angle: 0}, 2, {ease: FlxEase.cubeOut});
            FlxTween.tween(camHUD, {alpha: 1}, 2, {ease: FlxEase.cubeOut});
            if (!Options.lowMemoryMode) {
                FlxTween.num(0.8, 1.2, (Conductor.stepCrochet / 1000) * 8, {ease: FlxEase.cubeOut}, (v:Float) -> {
                    saturation.sat = v; saturation.contrast = v;
                });
            }

        case 364:
            bgFade(true);
            if (!Options.lowMemoryMode) {
                FlxTween.num(1.2, 0.6, (Conductor.stepCrochet / 1000) * 16, {ease: FlxEase.cubeIn}, (v:Float) -> {
                    saturation.sat = v; saturation.contrast = 1.2 - (1.2 - v) * 0.33; 
                });
                FlxTween.tween(vehVignette, {alpha: 1}, 4);
                FlxTween.tween(redVig, {alpha: 0.175}, 4);
                FlxTween.tween(redGrad, {alpha: 0.225}, 4);

                spotLight.flipX = true;
                spotLight.x += 600;
                spotLight.y -= 700;
            }
        case 372: // its such a shitty process im So Sorry for you
            if (!Options.lowMemoryMode) { add(spotLight); canFlicker = true; spotLight.alpha = 1; }
        case 379:
            if (!Options.lowMemoryMode) {
                spotLight.flipX = false;
                FlxTween.tween(spotLight, {x: -380, y: -800}, 0.001, {ease: FlxEase.quadOut});
            }
        case 387:
            if (!Options.lowMemoryMode) {
                spotLight.flipX = true;
                FlxTween.tween(spotLight, {x: 500, y: -500}, 0.001, {ease: FlxEase.quadOut});
            }
        case 394:
            if (!Options.lowMemoryMode) {
                FlxTween.tween(spotLight, {alpha: 0, x: 500, y: -850}, 2, {ease: FlxEase.quadInOut});
                canFlicker = false;
            }
        case 396, 412, 432, 472:
            bgFade(false); 
            if (!Options.lowMemoryMode) {
                remove(spotLight);
                FlxTween.num(0.7, 1.2, (Conductor.stepCrochet / 1000), {ease: FlxEase.cubeIn}, (v:Float) -> {
                    saturation.sat = v; saturation.contrast = 1.2;
                });
                vehVignette.alpha = 1; redVig.alpha = 0.5; redGrad.alpha = 0.45;
            }

        case 404, 428, 468:
            if (!Options.lowMemoryMode) {
                FlxTween.num(1.2, 0.7, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (v:Float) -> {
                    saturation.sat = v; saturation.contrast = 1.2 - (1.2 - v) * 0.4;
                });
                FlxTween.tween(vehVignette, {alpha: 0.5}, 1);
                FlxTween.tween(redVig, {alpha: 0.2}, 1);
                FlxTween.tween(redGrad, {alpha: 0.15}, 1);
            }

        case 474:
            FlxTween.tween(camHUD, {alpha: 0}, 1);
            if (!Options.lowMemoryMode) {
                FlxTween.num(1.2, 1, (Conductor.stepCrochet / 1000) * 4, {ease: FlxEase.cubeIn}, (v:Float) -> {
                    saturation.sat = v; saturation.contrast = v;
                });
            }
    }
}

function bgFade(fade:Bool) {
    for (sprite in mainSprites) FlxTween.color(sprite, 1, sprite.color, fade ? 0xFFADADAD : 0xFFFFFFFF, {ease: FlxEase.quadOut});
    for (s in vSprites) FlxTween.color(s, 1, s.color, fade ? 0xFFADADAD : 0xFFFFFFFF, {ease: FlxEase.quadOut});
}

function onNoteHit(e){
    if(e.noteType == "laugh") dad.playAnim(e.noteType, true, "LOCK");
    if (e.note.noteType == 'noAnim') e.cancelAnim();
}

function onCountdown(event) event.cancel();