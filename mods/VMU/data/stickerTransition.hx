import flixel.util.FlxTimerManager;
import funkin.backend.MusicBeatTransition;
import haxe.io.Path;
import StickerPack;

static var lastStickers:Array<{
    var stickerPath:String;
    var position:FlxPoint;
    var scale:FlxPoint;
    var angle:Float;
    var timing:Float;
    var showedInRegen:Bool;
}> = [];

var stickerPack:StickerPack = null;
var soundSelections:Array<String> = [];
var soundSelection:String = "";
var sounds:Array<String> = [];
var grpStickers:FlxGroup;
var timerManager:FlxTimerManager;

function create(event) {
    stickerPack = new StickerPack('default'); 

    grpStickers = new FlxGroup();
    add(grpStickers);

    timerManager = new FlxTimerManager();
    add(timerManager);

    soundSelections = Paths.getFolderDirectories('sounds/stickersounds/', true);
    if (soundSelections.length > 0) {
        soundSelection = getRandomString(soundSelections);
        for (file in Paths.getFolderContent(soundSelection, true)) {
            sounds.push(Path.withoutExtension(file.substring('sounds/'.length)));
        }
    }

    if(event.transOut)
        regenStickers();
    else
        degenStickers();

    event.cancel();
}

function regenStickers() {
    lastStickers = [];
    var xPos:Float = -100;
    var yPos:Float = -100;
    
    while(xPos <= FlxG.width) {
        var stickerPath:String;
        if (FlxG.random.int(1, 300) == 1)
            stickerPath = "transitionSwag/costumeSticker" + FlxG.random.int(1,4);
        else 
            stickerPath = stickerPack.getRandomStickerPath(false);
        
        //trace(FlxG.random.int(1, 100) == 1);
        //trace(stickerPath);
        var sticky:FlxSprite = new FlxSprite(xPos, yPos);
        CoolUtil.loadAnimatedGraphic(sticky, Paths.image(stickerPath));
        
        sticky.scale.set(1, 1);
        sticky.updateHitbox();
        sticky.visible = false;
        sticky.angle = FlxG.random.int(-60, 70);
        
        grpStickers.add(sticky);

        lastStickers.push({
            stickerPath: stickerPath,
            position: FlxPoint.get(sticky.x, sticky.y),
            scale: FlxPoint.get(1, 1),
            angle: sticky.angle,
            timing: 0.2,
            showedInRegen: false
        });

        xPos += sticky.width * 0.5; 

        if (xPos >= FlxG.width) {
            if(yPos <= FlxG.height){
                xPos = -100;
                yPos += FlxG.random.float(70, 120);                 
            }

        }
    }

    grpStickers.members = shuffleStickers(grpStickers.members);

    var lastStickerPath:String = stickerPack.getRandomStickerPath(true);
    var lastSticker:FlxSprite = new FlxSprite(0, 0);
    CoolUtil.loadAnimatedGraphic(lastSticker, Paths.image(lastStickerPath));
    
    lastSticker.scale.set(1, 1);
    lastSticker.updateHitbox();
    lastSticker.visible = false;
    lastSticker.screenCenter();
    grpStickers.add(lastSticker);

    lastStickers.push({
        stickerPath: lastStickerPath,
        position: FlxPoint.get(lastSticker.x, lastSticker.y),
        scale: FlxPoint.get(1, 1),
        angle: 0,
        timing: 0,
        showedInRegen: false
    });

    for (ind => sticker in grpStickers.members) {
        lastStickers[ind].timing = FlxMath.remapToRange(ind, 0, grpStickers.members.length, 0, 0.8);

        new FlxTimer(timerManager).start(lastStickers[ind].timing, function(_) {
            sticker.visible = true;
            if (sounds.length > 0) FlxG.sound.play(Paths.sound(getRandomString(sounds)), 0.25);

            lastStickers[ind].showedInRegen = true;

            var frameTimer:Int = FlxG.random.int(20,100);
            if (ind == grpStickers.members.length - 1) frameTimer = 2;

            new FlxTimer(timerManager).start((1 / 10) * frameTimer, function(_) {
                var baseScale = lastStickers[ind].scale.x;
                sticker.scale.x = sticker.scale.y = baseScale * FlxG.random.float(0.97, 1.05);
                if (ind == grpStickers.members.length - 1) finish();
            });
        });
    }
}

function degenStickers() {
    for(ind => prop in lastStickers) {
        var sticky:FlxSprite = new FlxSprite(prop.position.x, prop.position.y);
        CoolUtil.loadAnimatedGraphic(sticky, Paths.image(prop.stickerPath));
        sticky.scale.set(prop.scale.x, prop.scale.y);
        sticky.updateHitbox();
        sticky.angle = prop.angle;
        grpStickers.add(sticky);
    }

    for (ind => sticker in grpStickers.members) {
        new FlxTimer(timerManager).start(lastStickers[ind].timing, _ -> {
            sticker.visible = false;
            if (sounds.length > 0) FlxG.sound.play(Paths.sound(getRandomString(sounds)), 0.25);
            if (ind == grpStickers.members.length - 1) finish();
        });
    }
}

function onSkip(event) {
    timerManager.clear();
}

function shuffleStickers(array:Array<FlxSprite>) {
    var maxValidIndex = array.length - 1;
    for (i in 0...maxValidIndex) {
        var j:Int = FlxG.random.int(i, maxValidIndex);
        var tmp:FlxSprite = array[i];
        array[i] = array[j];
        array[j] = tmp;

        var tmpProp = lastStickers[i];
        lastStickers[i] = lastStickers[j];
        lastStickers[j] = tmpProp;
    }
    return array;
}

function getRandomString(array:Array<String>) {
    return array[FlxG.random.int(0, array.length - 1)];
}