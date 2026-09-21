import hxvlc.flixel.FlxVideoSprite;
import openfl.display.BlendMode;
import flixel.addons.display.shapes.FlxShapeCircle;

var hudBF:Character;
var mickeyText:FunkinSprite;

var dadCamPos;
var hue = new CustomShader('hsv');
var bloom = new CustomShader("bloom");
var blur = new CustomShader("blur");

var defaultCpuPos:Array = [];
var defaultPlayerPos:Array = [];
var centerCpuPos:Array = [];
var centerPlayerPos:Array = [];

if (PlayState.variation != null) {
    disableScript();
    return;
}

function create() {
    camParticles = new FlxCamera();
	camParticles.bgColor = 0x00000000;
	camParticles.alpha = 0;

	FlxG.cameras.remove(camHUD, false);
	FlxG.cameras.add(camParticles, false);
	FlxG.cameras.add(camHUD, false);
}

function postCreate(){
    // 记录当前实际位置
    for (i in 0...cpuStrums.length){
        defaultCpuPos.push(cpuStrums.members[i].x);
    }
    for (i in 0...playerStrums.length){
        defaultPlayerPos.push(playerStrums.members[i].x);
    }

    // 居中滚动布局位置：CPU（0号组）使用左右各两列公式，玩家（1号组）使用居中一排公式
    var width = FlxG.width;
    for (i in 0...cpuStrums.length) {
        if (i < 2) centerCpuPos[i] = 82 + i * 112;
        else centerCpuPos[i] = width - 309 + (i - 2) * 112;
    }
    for (i in 0...playerStrums.length) {
        centerPlayerPos[i] = -228 + 112 * i + width / 2;
    }

    gf.animation.finishCallback = function(name){
        switch(name){
            case "danceRight":
                if (curBeat > 112) new FlxTimer().start((Conductor.stepCrochet/1000) * 3, () -> {gf.playAnim("cuteanim",true,"LOCK");});
            case "cuteanim":
                gf.idleSuffix = "-alt";
                gf.playAnim("danceLeft-alt",true,"DANCE");
        }
    }

    black = new FlxSprite(-80, 0).makeGraphic(FlxG.width * 3,FlxG.height * 3, FlxColor.BLACK);
    black.screenCenter();
    black.alpha = 0;
    insert(members.indexOf(stage.stageSprites['goofy']) + 1, black);

    spotlights = new FlxTypedGroup();
    insert(members.indexOf(dad)+1,spotlights);

    bloom.dim = 1.6;
    bloom.Size = 16;
    blur.blurSize = 15;

    for(i in 0...2){
        spotlight = new FlxSprite(50,-120).loadGraphic(Paths.image('stages/clubhouse/spotlight'));
        spotlight.scale.set(2, 2.5);
        spotlight.alpha = 0;
        spotlight.blend = 0;
        if(Options.gameplayShaders) spotlight.shader = bloom;
        spotlights.add(spotlight);

        switch(i){
            case 1:
                spotlight.flipX = true;
                spotlight.x += 800;
        }
    }

    circle = new FlxShapeCircle(150,570,300,{thickness:0},FlxColor.WHITE);
    circle.scale.y = 0.15;
    circle.blend = 0;
    if(Options.gameplayShaders) circle.shader = blur;
    circle.alpha = 0;
    insert(members.indexOf(dad)-1,circle);

    hudBF = new Character(boyfriend.x, boyfriend.y - 80, boyfriend.curCharacter, true);
    hudBF.scale.set(1.2,1.2);
    hudBF.camera = camHUD;
    hudBF.alpha = 0;
    insert(4, hudBF);

    mickTextX = 130;
    mickTextY = 70;

    mickeyText = new FunkinSprite(mickTextX,mickTextY);
    mickeyText.loadSprite(Paths.image("game/mickeyText"));
    mickeyText.addAnim("anim","TextPop",24,false);
    add(mickeyText);
    mickeyText.visible = false;
}

function onNoteHit(e){
    if (e.character == boyfriend) {
        var anim = null;
        switch(e.direction){
            case 0: anim = 'singLEFT'; 
            case 1: anim = 'singDOWN';
            case 2: anim = 'singUP';
            case 3: anim = 'singRIGHT';
        }
        hudBF.playAnim(anim + e.animSuffix, true, 'SING');
        hudBF.idleSuffix = boyfriend.idleSuffix;
    }
}
function onPlayerMiss(e){
    var anim = null;
    switch(e.direction){
        case 0: anim = 'singLEFTmiss'; 
        case 1: anim = 'singDOWNmiss';
        case 2: anim = 'singUPmiss';
        case 3: anim = 'singRIGHTmiss';
    }
    hudBF.playAnim(anim, true, 'MISS');
    hudBF.idleSuffix = boyfriend.idleSuffix;
}
var nextBeatPlayAnim:Bool = false;

function beatHit(){
    switch(curBeat){
        case 30:
        case 96:
            FlxTween.tween(black,{alpha:0.75},0.5);
            for(i in 0...spotlights.length) FlxTween.tween(spotlights.members[i], {alpha: 1}, 0.5, {ease: FlxEase.quartOut});
            stage.stageSprites['fg2'].color = 0xFF222222;
        case 112:   
            stage.stageSprites['donald'].playAnim("idle-alt");
            stage.stageSprites['goofy'].playAnim("idle-alt");

            isWUAS = true;
            if(gf.animation.curAnim.name == "danceRight") gf.playAnim("danceRight",true,"LOCK");
            else nextBeatPlayAnim = true;
        case 113: if(nextBeatPlayAnim) gf.playAnim("danceRight",true,"LOCK");
        case 206:
            var baseCpu = centerCpuPos;
            var basePlayer = centerPlayerPos;
            if (FlxG.save.data.middleScroll == true) {
                // ★ 敌方（CPU）大偏移 ±600，我方（玩家）小偏移 ±35 ★
                for (i in 0...cpuStrums.length) {
                    var offset = (i < 2) ? -600 : 600;
                    FlxTween.tween(cpuStrums.members[i], {x: baseCpu[i] + offset}, 1.45, {ease: FlxEase.quartInOut});
                }
                for (i in 0...playerStrums.length) {
                    var offset = (i < 2) ? -35 : 35;
                    FlxTween.tween(playerStrums.members[i], {x: basePlayer[i] + offset}, 1.45, {ease: FlxEase.quartInOut});
                }
            } else {
                // 基础滚动模式：玩家全部+70，CPU全部-600（基于居中布局）
                for (i in 0...playerStrums.length) {
                    FlxTween.tween(playerStrums.members[i], {x: basePlayer[i] + 70}, 1.45, {ease: FlxEase.quartInOut});
                }
                for (i in 0...cpuStrums.length) {
                    FlxTween.tween(cpuStrums.members[i], {x: baseCpu[i] - 600}, 1.45, {ease: FlxEase.quartInOut});
                }
            }

            camGame.fade(FlxColor.BLACK,(Conductor.crochet/1000) * 1.5,false);
        case 208:
            for(i in stage.stageSprites){
                i.visible = false;
            }
            gf.visible = false;
            boyfriend.visible = false;
            spotlights.members[1].alpha = 0;
            spotlights.members[0].alpha = 1;
            camGame.fade(FlxColor.BLACK,1,true);
            circle.alpha = 0.15;
            playText();
        case 212:
            hudBF.useRenderTexture = true;
            FlxTween.tween(hudBF,{alpha:0.5},1);
            FlxTween.tween(hudBF,{x: hudBF.x - 200},(Conductor.crochet/1000) * 28);
        case 239:
            gf.idleSuffix = "";
        case 240:
            stage.stageSprites['donald'].playAnim("idle");
            stage.stageSprites['goofy'].playAnim("idle");
            isWUAS = false;
            FlxG.camera.flash(FlxColor.WHITE,1);
            FlxTween.tween(mickeyText,{alpha:0},1);
            for(i in stage.stageSprites){
                i.visible = true;
            }
            gf.visible = true;
            boyfriend.visible = true;
            for(i in 0...2) spotlights.members[i].alpha = 0;
            circle.alpha = 0;
            stage.stageSprites['fg2'].color = FlxColor.WHITE;
            black.alpha = 0;
            hudBF.alpha = 0;

            // 恢复：根据模式分别恢复到居中或普通布局
            if (FlxG.save.data.middleScroll == true) {
                for (i in 0...playerStrums.length) {
                    FlxTween.tween(playerStrums.members[i], {x: centerPlayerPos[i]}, 1.45, {ease: FlxEase.quartOut});
                }
                for (i in 0...cpuStrums.length) {
                    FlxTween.tween(cpuStrums.members[i], {x: centerCpuPos[i]}, 1.45, {ease: FlxEase.quartOut});
                }
            } else {
                for (i in 0...playerStrums.length) {FlxTween.tween(playerStrums.members[i], {x: defaultPlayerPos[i]}, 1.45, {ease: FlxEase.quartOut});}
                for (i in 0...cpuStrums.length) {FlxTween.tween(cpuStrums.members[i], {x: defaultCpuPos[i]}, 1.45, {ease: FlxEase.quartOut});}
            }
        case 271:
            for (i in 0...playerStrums.length) {FlxTween.tween(playerStrums.members[i], {alpha: 0}, (Conductor.crochet/1000) * 4);}
            for (i in 0...cpuStrums.length)    {FlxTween.tween(cpuStrums.members[i], {alpha: 0}, (Conductor.crochet/1000) * 4);}
            for(i in [iconBF, iconDad, vmuBar,leftHealth,rightHealth,missesTxt,scoreTxt]) {FlxTween.tween(i, {alpha: 0}, (Conductor.crochet/1000) * 4);}
        case 274:
            stage.stageSprites['donald'].playAnim("idle-veh",true);
    }
}
function playText(){
    mickeyText.visible = true;
    mickeyText.playAnim("anim");
}

function doMickeyAnim(){
    dad.playAnim('haha',true,"LOCK");
}

function doBrunoAnim(){
    boyfriend.playAnim('hey',true,"LOCK");
    gf.playAnim('cheer',true,"LOCK");

    stage.stageSprites['donald'].playAnim("yay",true,"LOCK");
    stage.stageSprites['donald'].offset.set(0,-10);

    stage.stageSprites['goofy'].playAnim("yay",true,"LOCK");
    stage.stageSprites['goofy'].offset.set(0,-10);
}