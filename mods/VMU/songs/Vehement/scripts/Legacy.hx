if(PlayState.variation != "Legacy"){
    trace('New Version of Song! Removing Special Events meant for Old Version...');
    disableScript();
    return;
}

var mainSprites:Array<FunkinSprite> = [];
var vSprites:Array<FunkinSprite> = [];

function postCreate(){
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
    setUpChars();
}

public var legacyMickey = strumLines.members[0].characters;
public var legacyDonald = strumLines.members[2].characters;
public var legacyGoofy = strumLines.members[3].characters;

function beatHit(){
    if(curBeat >= 104){
        stage.stageSprites['goofy'].visible = false;
    }
    switch (curBeat){
        case 34:
            defaultCamZoom = 0.7;
        case 36:
            defaultCamZoom = 0.5;
        case 96:
            FlxTween.tween(FlxG.camera, {zoom: 0.7}, 3, {ease: FlxEase.quartInOut, onComplete:
                function (twn:FlxTween)
                {
                    defaultCamZoom = 0.7;
                }});
        case 104:
            defaultCamZoom = 0.5;
        case 168:
            FlxTween.tween(FlxG.camera, {zoom: 0.7}, 1, {ease: FlxEase.quartOut, onComplete:
                function (twn:FlxTween)
                {
                    defaultCamZoom = 0.7;
                }});
            for (i in 0...playerStrums.length) FlxTween.tween(playerStrums.members[i], {alpha:0}, 1, {ease: FlxEase.quartOut});
            for (i in 0...cpuStrums.length) FlxTween.tween(cpuStrums.members[i], {alpha:0}, 1, {ease: FlxEase.quartOut});
        case 181:
            FlxTween.tween(FlxG.camera, {zoom: 0.5}, 2, {ease: FlxEase.quartInOut, onComplete:
                function (twn:FlxTween)
                {
                    defaultCamZoom = 0.5;
                }});
        case 184:
            for (i in 0...playerStrums.length) FlxTween.tween(playerStrums.members[i], {alpha:1}, 1, {ease: FlxEase.quartOut});
            for (i in 0...cpuStrums.length) FlxTween.tween(cpuStrums.members[i], {alpha:1}, 1, {ease: FlxEase.quartOut});
        case 198:
            FlxTween.tween(FlxG.camera, {zoom: 0.9}, 2, {ease: FlxEase.quartInOut, onComplete:
                function (twn:FlxTween)
                {
                    defaultCamZoom = 0.9;
                }});
        case 204:
            defaultCamZoom = 0.5;
        case 268:
            defaultCamZoom = 0.5;
    }
}

function stepHit() { 
    switch (curStep){
        case 670:
            swapChars(0,2); 
            legacyMickey[2].playAnim("nerves", true, "LOCK");
        case 808:
            for (s in vSprites) {
                if (s.name == "V-fgA" || s.name == "V-lightBulb") s.visible = false;
                else s.visible = true; 
                s.alpha = 1; s.color = FlxColor.WHITE;
            } 
            for (y in mainSprites) { y.kill(); remove(y); }
            mainSprites = [];
            FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
        case 1057: legacyMickey[3].playAnim("laugh", true, "LOCK");
        case 1212:
            FlxG.camera.fade(0xFF000000, 1, true);
            stage.stageSprites.get("V-fg").visible = false;
            stage.stageSprites.get("V-fgA").visible = true;
            var bulb = stage.stageSprites.get("V-lightBulb");
            bulb.origin.set(bulb.frameWidth / 2, 0);
            bulb.offset.set(0, 0);
            bulb.visible = true;
        
    }
}

function onNoteHit(e){
    if(e.noteType == "nerves"){
        dad.playAnim("nerves",false,"LOCK");
    }
}

function setUpChars(){
    var shader = new CustomShader('adjustColor');
    shader.brightness = -30;
    shader.hue = -15;
    shader.saturation = -20; 
    //goofy
    legacyGoofy[0].scale.set(0.8, 0.8); //preferal
    legacyGoofy[1].scale.set(0.75, 0.75); //feral
    legacyGoofy[2].scale.set(0.75, 0.75); //calm

    for(i in 1...3){
        legacyGoofy[i].setPosition(legacyGoofy[0].x,legacyGoofy[0].y);
        legacyGoofy[i].x = 1100;
        legacyGoofy[i].y -= 150; 
         if(Options.gameplayShaders) legacyGoofy[i].shader = shader;
    }
    
    legacyDonald[1].setPosition(legacyDonald[0].x,legacyDonald[0].y);
    legacyDonald[1].x = 200;
    legacyDonald[1].y -= 100;

    remove(legacyDonald[1]);
    insert(members.indexOf(strumLines.members[0].characters[0]) - 1, legacyDonald[1]);

    if(Options.gameplayShaders){
        legacyGoofy[0].shader = shader;
        legacyDonald[1].shader = shader;
        strumLines.members[4].characters[0].shader = shader;
    }

    remove(legacyMickey[2]);
    insert(members.indexOf(strumLines.members[1].characters[0]) + 1, legacyMickey[2]);
    legacyMickey[2].x -= 40;
    legacyMickey[2].y += 2;

    swapChars(0,0);
    swapChars(1,0);
    swapChars(2,0);
    swapChars(3);
}

function swapChars(m:Int = 0, c:Int = 0){
    chosenStrum = strumLines.members[m].characters;
    for(i in 0...chosenStrum.length){
        chosenStrum[i].visible = false;
    }
    if(c != null) chosenStrum[c].visible = true;
    //trace(chosenStrum[c].visible);
}

var bulb = stage.stageSprites.get("V-lightBulb");
function update(elapsed:Float) {
    if (bulb != null && bulb.visible) 
        bulb.angle = Math.sin(Conductor.songPosition / 1500) * 12;
}