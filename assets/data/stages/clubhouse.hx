importScript('data/scripts/dropshadow-effect');

import StringTools;
public var isWUAS:Bool = false;
public var forceBeat:Bool = false;

var crotchBox:FlxSprite;

function postCreate() {
    var fish = stage.stageSprites.get("fish");
    fish.origin.set(fish.frameWidth / 2, fish.frameHeight / 2);
    if (PlayState.SONG.meta.name == "Welcome" && !PlayState.isStoryMode){
        crotchBox = new FlxSprite().makeSolid(50,50,FlxColor.RED);
        crotchBox.setPosition(donald.x + 260,donald.y + 600);
        crotchBox.alpha = 0;
        add(crotchBox);
    }
}

function update(elapsed:Float) {
    var fish = stage.stageSprites.get("fish");
    var time = Conductor.songPosition / 5000;
    
    fish.x = -400 + Math.cos(time) * 10;
    fish.y = -840 + Math.sin(time * 2) * 3; 
    fish.angle = Math.sin(time * 1.5) * 3;

    if(crotchBox != null && FlxG.mouse.overlaps(crotchBox) && FlxG.mouse.justPressed && donald.visible){
        PlayState.loadSong("Dussy","Normal");
        FlxG.switchState(new PlayState());
    }
}

function stepHit(){
    if((curStep % 8 == 7 || (curStep < 0 && curStep % 8 == -1))){
        if (PlayState.SONG.meta.name == "Welcome" && (curStep == 447 || curStep == 959 || curStep >= 1102)) return;
        for(i in ['donald','goofy']){
            //trace(PlayState.SONG.meta.name);
            if(i == 'donald' && PlayState.SONG.meta.name == "Vehement"){
                //trace('nuh-uh');
            } 
            else stage.stageSprites[i].playAnim('idle' + (isWUAS ? "-alt" : ""), (curStep > 0 ? true : false));
        }
    }
}

function applyShadow(brightness, hue, contrast, saturation, hexColor, strength) {
    if (!FlxG.save.data.overlay) return;
    for (a in [boyfriend, gf, dad]) {
        var dropShadow = getDropShadow(a);
        dropShadow.setAdjustColor(brightness, hue, contrast, saturation);
        dropShadow.color = hexColor;
        dropShadow.angle = 90;
        dropShadow.distance = 15;
        dropShadow.set_strength(strength);
    }
}

function beatHit() {
    if (curBeat % 2 == 0 && PlayState.SONG.meta.name == "Vehement") {
        stage.stageSprites['donald'].playAnim("idle-veh", (curStep > 0 ? true : false));
    }

    if (PlayState.SONG.meta.name == "Welcome") {
        switch(curBeat) {
            case 112, 176: 
                applyShadow(-20, -15, 5, 0, 0xFF30396E, 1.1);
            case 144: 
                applyShadow(-20, 0, 0, -20, 0xFF363433, 1);
            case 208: 
                if (FlxG.save.data.overlay)
                    for (a in [boyfriend, gf, dad]) getDropShadow(a).set_strength(0);
        }
    }
}

function onStageNodeParsed(e) {
    //trace(e.node);
    var spriteName:String = Std.string(e.sprite.name);
    var songName = PlayState.SONG.meta.name;
    //trace(e.name);
    if(e.node.get("song") != null && e.node.get("song") != songName){
        if((e.name != 'char'))
            e.stage.state.remove(e.sprite);
        else {
            e.sprite.scale.x = 1;
            e.sprite.scale.y = 1;
        } 
    }
}