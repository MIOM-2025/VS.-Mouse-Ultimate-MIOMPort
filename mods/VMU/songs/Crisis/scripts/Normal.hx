if(PlayState.variation != null) {
    disableScript();
    return;
}

import flixel.math.FlxBasePoint;
import openfl.filters.ShaderFilter;

importScript('data/scripts/dropshadow-effect');

static var camMoveOffset:Float = 15;
static var camFollowChars:Bool = true;

var movement = new FlxBasePoint();
var camChar:FlxCamera;
public var rays:CustomShader;
public var vignette:CustomShader;
var mainSprites:Array<FunkinSprite> = [];

public var donaldChar = strumLines.members[0].characters[1];
public var bfChar = strumLines.members[1].characters[1];

var stickerChars:Array<String> = ['goofy', 'donald', 'mickey', 'bf', 'gf', 'marko'];
var stickerActive:Bool = false;
var sticker:FunkinSprite;

// special thanks to bromaster819 for help with changing character stuff!

function create() {
    for (s in stage.stageSprites) {
        var spriteName:String = Std.string(s.name);
        s.color = 0xFFFFFFFF;

        mainSprites.push(s);
    }

    camFollowChars = true;
    introLength = 1;
}

function postCreate() {
    if (FlxG.save.data.stickers && !Options.lowMemoryMode) {
        var characters:Array<String> = ['goofy', 'donald', 'mickey', 'bf', 'gf', 'marko'];
        for (char in characters) {
            for (i in 1...4) {
                var path = 'transitionSwag/' + char + 'Sticker' + i;
                graphicCache.cache(Paths.image(path));
            }
        }
    }
    camGame.scroll.set(850 - (FlxG.width / 2), 250 - (FlxG.height / 2));
    
    boyfriend.y = dad.y;
    dad.x += 200;

    camChar = new FlxCamera();
    camChar.bgColor = 0;

    if (Options.gameplayShaders) {
        rays = new CustomShader("heatlight");
        rays.threshold = 0.9;

        vignette = new CustomShader("coloredVignette_clip");
        vignette.color = [1.0, 0.44, 0.2];
        vignette.amount = 0.7;
        vignette.strength = 1.0;

        camGame.setFilters([new ShaderFilter(vignette)]);
        camChar.setFilters([new ShaderFilter(vignette)]);
    }

    FlxG.cameras.remove(camHUD, false);
    FlxG.cameras.add(camChar, false);
    FlxG.cameras.add(camHUD, false);

    boyfriend.scale.set(0.9, 0.9);
    boyfriend.x -= 100;
    boyfriend.y += 32.5;
    dad.scale.set(0.475, 0.475);
    dad.x -= 332.5;
    dad.y -= 492.5;

    trace(donaldChar.getPosition());

    for (i in [gf, boyfriend, dad, donaldChar, bfChar]) {
        if (Options.gameplayShaders) {
            var dropShadow = getDropShadow(i);
            dropShadow.setAdjustColor(-15, 5, 15, 10);
            dropShadow.color = 0xFFeb7134;
            dropShadow.angle = 90;
            dropShadow.distance = 15;
            dropShadow.set_strength(1.1);
        }

        if (i != gf) {
            i.cameras = [camChar];
            i.antialiasing = Options.antialiasing;
            add(i);
        }
    }

    if (FlxG.save.data.stickers && !Options.lowMemoryMode) {
        sticker = new FunkinSprite();
        sticker.loadGraphic(Paths.image('transitionSwag/bfSticker1'));
        sticker.cameras = [camHUD];
        sticker.alpha = 0;
        add(sticker);
    }
    //camGame.setFilters([new ShaderFilter(rays)]); camChar.setFilters([new ShaderFilter(rays)]);

    camGame.followLerp = 0.05;
    camHUD.alpha = 0;

    remove(donaldChar);
    insert(members.indexOf(gf)+1,donaldChar);
    remove(bfChar);
    insert(members.indexOf(gf)+1,bfChar);
    for (i in [donaldChar, bfChar]){
        i.cameras = [camGame]; //remove(gf);
        i.scale.set(0.65,0.65);
        i.scrollFactor = gf.scrollFactor;
    }
    donaldChar.scale.set(0.45,0.45);
    donaldChar.setPosition(520,200);
    bfChar.setPosition(820,50);
    donaldChar.useRenderTexture = true;

    // boyfriend.alpha = 0;
    // dad.alpha = 0;

    cpuStrums.forEach(function(spr) {
        spr.visible = false;
        spr.alpha = 0;
    });
    for (cpuNote in cpu.notes) cpuNote.alpha = 0;
}

function onCameraMove(camMoveEvent) {
    if (camFollowChars) {
        var char = camMoveEvent.strumLine?.characters[0];
        
        switch (char.animation.name) {
            case "singLEFT" | "singLEFT-alt": movement.set(-camMoveOffset, 0);
            case "singDOWN" | "singDOWN-alt": movement.set(0, camMoveOffset);
            case "singUP" | "singUP-alt": movement.set(0, -camMoveOffset);
            case "singRIGHT" | "singRIGHT-alt": movement.set(camMoveOffset, 0);
            default: movement.set(0, 0);
        };

        var targetX = 0;
        var targetY = 375;

        if (curBeat < 308) {
            targetX = (curCameraTarget == 0) ? 725 : 1000;
            targetY = 375;
        } else {
            targetX = (curCameraTarget == 0) ? 750 : 1000;
            targetY = 350;
        }
        
        camMoveEvent.position.x = targetX + movement.x;
        camMoveEvent.position.y = targetY + movement.y;

        camChar.scroll.set(camGame.scroll.x, camGame.scroll.y);
    } else {
        camMoveEvent.cancel();
    }
}

var stickerScale:Float = 1;

function update(elapsed:Float) {
    if (FlxG.save.data.stickers && sticker != null) {
        sticker.scale.x = FlxMath.lerp(sticker.scale.x, stickerScale, 0.02);
        sticker.scale.y = FlxMath.lerp(sticker.scale.y, stickerScale, 0.02);
    }
}

function spawnSticker() {
    if (!FlxG.save.data.stickers || Options.lowMemoryMode || sticker == null) return;

    var char = FlxG.random.getObject(stickerChars);
    var num = FlxG.random.int(1, 3);

    sticker.loadGraphic(Paths.image('transitionSwag/' + char + 'Sticker' + num));
    sticker.x = FlxG.random.float(0, 750);
    sticker.y = FlxG.random.float(-150, 400);
    sticker.angle = FlxG.random.float(-15, 15);

    sticker.scale.set(0.75, 0.75);
    sticker.alpha = 0.5;
    sticker.flipX = FlxG.random.bool();

    stickerScale = 1;

    FlxTween.cancelTweensOf(sticker);
    FlxTween.tween(sticker, {alpha: 0}, 2, {ease: FlxEase.quadOut});
    FlxTween.num(1, 0.8, 2, {ease: FlxEase.quadOut}, function(v:Float) {
        stickerScale = v;
    });
}

function measureHit(curMeasure:Int) if (stickerActive) spawnSticker();
function beatHit(curBeat:Int) {
    //strumLines.members[0].characters[0].visible = false;
    switch(curBeat) {
        case 96:
            FlxTween.tween(camHUD, {alpha: 1}, 4, {ease: FlxEase.quadOut});
        case 304:
            for (i in [iconBF, iconDad]) {
                FlxTween.color(i, 1, 0xFFFFFFFF, 0xFF000000, {ease: FlxEase.quadOut});
                FlxTween.tween(i, {angle: 360}, 1, {ease: FlxEase.quadIn});
            }
            for (i in [leftHealth, rightHealth]) FlxTween.color(i, 1, i.color, 0xFF000000, {ease: FlxEase.quadOut});
            FlxTween.tween(dad, {x: dad.x - 1600, y:dad.y + 200, alpha:0}, 1, {ease: FlxEase.quadInOut});
            FlxTween.tween(dad.scale, {x: dad.scale.x + 2, y: dad.scale.y + 2}, 1, {ease: FlxEase.quadInOut});
            FlxTween.tween(boyfriend, {x: boyfriend.x + 1600, y:boyfriend.y + 200, alpha:0}, 1, {ease: FlxEase.quadInOut});
            FlxTween.tween(boyfriend.scale, {x: boyfriend.scale.x +2, y: boyfriend.scale.y + 2}, 1, {ease: FlxEase.quadInOut});

            for (i in [donaldChar, bfChar]){
                i.camera = camChar;
            }
            FlxTween.tween(camGame, {zoom:1.8}, 1, {ease: FlxEase.quadInOut, onComplete: () -> {defaultCamZoom = 0.6;}});
            //FlxTween.tween(camGame.scroll, {y:camGame.scroll.y + 50}, 1, {ease: FlxEase.quadInOut, onComplete: () -> {defaultCamZoom = 1.2;}});
            bfChar.scale.set(0.335,0.335);
            donaldChar.scale.set(0.22,0.22);
            bfChar.setPosition(622,145);
            donaldChar.setPosition(-20,-110);
            FlxTween.tween(donaldChar.scale, {x:0.65, y:0.65},1, {ease:FlxEase.quadInOut});
            FlxTween.tween(bfChar.scale, {x:0.95, y:0.95},1, {ease:FlxEase.quadInOut});
            FlxTween.tween(bfChar, {x:895, y:280},1, {ease:FlxEase.quadInOut});
            FlxTween.tween(donaldChar, {x:10, y:-70},1, {ease:FlxEase.quadInOut});
            //donaldChar.y -= 50;
            bgFade(true);
        case 308:
            strumLines.members[0].characters[0].visible = false;
            strumLines.members[1].characters[0].visible = false;

            for (i in [iconBF, iconDad]) {
                FlxTween.color(i, 2, 0xFF000000, 0xFFFFFFFF, {ease: FlxEase.quadOut});
                i.angle = 0;
            }
            //donaldChar.x -= 250; donaldChar.y -= 250;
            //bfChar.x -= 125; bfChar.y += 150;

            iconBF.setIcon(bfChar.getIcon());
            iconDad.setIcon(donaldChar.getIcon());

            leftHealth.color = donaldChar.iconColor;
            rightHealth.color = bfChar.iconColor;
        case 372: if (FlxG.save.data.stickers && !Options.lowMemoryMode) stickerActive = true;
        case 436: stickerActive = false;
        case 460:
            for (cam in FlxG.cameras.list) {
                cam.fade(0xFF000000, 0.001, false);
            }
    }
}

var scrollMult:Float = 0.2;

function postUpdate() {
    camChar.zoom = camGame.zoom + 0.475;
    
    var offX = camGame.scroll.x * scrollMult;
    var offY = camGame.scroll.y * scrollMult;
    
    for (i in [boyfriend, dad, donaldChar, bfChar]) {
        if ((i == donaldChar || i == bfChar) && curBeat < 304) continue; 
        if (i != null && i.visible) i.offset.set(offX, offY);
    }
}

function onCountdown(event:CountdownEvent) event.cancel();
function onDadHit(e) {
    health = Math.max(health - 0.02, 0.003);
}
function onNoteHit(e){ //to make donald and bruno not sing until its their turn to!
    if (curBeat < 308){
        e.cancelAnim();
        if(e.character.curCharacter == "mickey-c1") boyfriend.playSingAnim(e.direction, e.animSuffix);
        if(e.character.curCharacter == "marko") dad.playSingAnim(e.direction, e.animSuffix);
    }
}
function onPlayerMiss(e){
    if (curBeat < 308){
        e.cancelAnim();
        if(e.character.curCharacter == "mickey-c1") boyfriend.playSingAnim(e.direction, e.animSuffix, "MISS", e.forceAnim);
    }
}
function bgFade(fade:Bool) for (sprite in mainSprites) FlxTween.color(sprite, 1, sprite.color, fade ? 0xFFADADAD : 0xFFFFFFFF, {ease: FlxEase.quadOut});
function destroy() {
    camFollowChars = true; 
    camMoveOffset = 15;
}