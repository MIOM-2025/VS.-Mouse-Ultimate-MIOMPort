import flixel.util.FlxStringUtil;
import flixel.text.FlxTextBorderStyle;
import funkin.backend.MusicBeatState;
import flixel.ui.FlxBar.FlxBarFillDirection;
import flixel.ui.FlxBar;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxRect;
import flixel.text.FlxTextAlign;

public var vmuCam:HudCamera = new HudCamera();
public var vmuBar:FunkinSprite;
public var leftHealth:FunkinSprite;
public var rightHealth:FunkinSprite;
public var timeBar:FlxBar;
public var timeBarBG:FlxBar;
public var timeTxt:FlxText;

public var iconBF:HealthIcon;
public var iconDad:HealthIcon;
var goofyIcon, donaldIcon:HealthIcon;
var allIcons:Array<HealthIcon> = [];
var isCrisis:Bool = false;
var isVehement:Bool = false;
public var healthPercent:Float = 1;
var isWelcomeLegacy = (PlayState.SONG.meta.name == "Welcome" && PlayState.variation == "Legacy");

if (isWelcomeLegacy) {
    disableScript();
    return;
}

function create() {
    if(!isWelcomeLegacy){
        PauseSubState.script = 'data/scripts/menus/VMU Pause';
        var songName:String = PlayState.SONG.meta.name.toLowerCase();
        var charName:String = strumLines.members[1].characters[0].curCharacter.toLowerCase();

        GameOverSubstate.script = 'data/scripts/gameovers/' + (songName == "dussy" ? "dussy-gameOver" : (charName == "mickey" ? "mickey" : "gameOver"));
    }
    else {
        PauseSubState.script = null;
        GameOverSubstate.script = null;
    }
}

var wasCutscening = false;

function postCreate() {
    FlxG.cameras.remove(camHUD, false);
    camCombo = new FlxCamera();
    camCombo.bgColor = 0;
    camCombo.zoom = 0.5;
    camCombo.y = Options.downscroll ? 100 : -100;
    FlxG.cameras.add(camCombo, false);
    FlxG.cameras.add(camHUD, false);

    var songName = PlayState.SONG.meta.name.toLowerCase();
    isCrisis = (songName == "crisis" && PlayState.variation == null);
    isVehement = (songName == "vehement");

    if(isCrisis){
        camCombo.x -= 400;
        camCombo.y += 300;
    }
    for (i in [healthBarBG, healthBar, accuracyTxt, iconP1, iconP2]) i.visible = false;
    FlxG.cameras.add(vmuCam, false).bgColor = 0;

    var prefix = isCrisis ? 'crisis' : 'vmu';
    vmuBar = new FlxSprite().loadGraphic(Paths.image('game/healthBars/' + prefix + 'HealthBar'));
    vmuBar.camera = vmuCam;
    vmuBar.antialiasing = Options.antialiasing;
    vmuBar.screenCenter(FlxAxes.X);
    
    vmuBar.y = isCrisis ? (FlxG.height - 695) : (Options.downscroll ? FlxG.height - 737.5 : FlxG.height - 162.5);
    if (isCrisis) { vmuBar.scale.set(1, 0.925); vmuBar.x -= 550; }

    leftHealth = new FlxSprite().loadGraphic(Paths.image('game/healthBars/' + prefix + 'HealthBarBG'));
    rightHealth = new FlxSprite().loadGraphic(Paths.image('game/healthBars/' + prefix + 'HealthBarBG'));
    leftHealth.color = dad.iconColor;
    rightHealth.color = boyfriend.iconColor;

    for (a in [leftHealth, rightHealth]) {
        a.camera = vmuCam;
        a.screenCenter(FlxAxes.X);
        a.y = vmuBar.y + 2;
        if (isCrisis) { a.scale.set(1, 0.925); a.x -= 550; }
        add(a);
    }
    add(vmuBar);
    rightHealth.clipRect = new FlxRect(0, 0, rightHealth.frameWidth, rightHealth.frameHeight);

    timeBar = new FlxBar(0, 0, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width, 10, Conductor, 'songPosition', 0, inst.length);
    timeBar.numDivisions = Std.int(timeBar.width);
    timeBarBG = new FlxBar(0, 0, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width, 15);
    for(i in [timeBarBG, timeBar]){
        i.createFilledBar(0xFF000000, 0xFFFFFFFF, true, FlxColor.BLACK);
        i.camera = vmuCam;
        i.screenCenter(FlxAxes.Y);
        i.y = Options.downscroll ? 707.5 : 0;
        i.alpha = 0;
        add(i);
    }

    timeTxt = new FunkinText(0, 0, FlxG.width, "0:00 / 0:00", 24);
    timeTxt.setFormat(Paths.font("WickedMouse.ttf"), 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    timeTxt.y = Options.downscroll ? 662.5 : 16.25;
    timeTxt.camera = vmuCam;
    timeTxt.borderSize = 2;
    timeTxt.alpha = 0;
    timeTxt.antialiasing = Options.antialiasing;
    add(timeTxt);

    // ========== 修改：将 missesTxt 和 scoreTxt 的 Y 坐标固定为 150 ==========
    missesTxt.y = scoreTxt.y = 150;   // 原来为条件表达式
    // =====================================================================

    missesTxt.x += 75;
    scoreTxt.x = missesTxt.x + 225;

    for(i in [missesTxt, scoreTxt]){
        i.setFormat(Paths.font("WickedMouse.ttf"), 21, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        i.borderSize = 2;
        i.letterSpacing = 2;
        i.antialiasing = Options.antialiasing;
        i.camera = vmuCam;
    }

    goofyIcon = new HealthIcon('goofy', false);
    donaldIcon = new HealthIcon('donald', false);
    iconBF = new HealthIcon(boyfriend.icon, true);
    iconDad = new HealthIcon(dad.icon, false);
    allIcons = [iconBF, goofyIcon, iconDad, donaldIcon];

    iconBF.setPosition(isCrisis ? 25 : 950, isCrisis ? 575 : vmuBar.y + 17.5);
    iconDad.setPosition(isCrisis ? 12.5 : 175, isCrisis ? 0 : vmuBar.y + 7.5);
    goofyIcon.setPosition(iconDad.x - 45, iconDad.y - 60);
    donaldIcon.setPosition(iconDad.x - 62.5, iconDad.y + 25);

    for (a in allIcons) {
        var s:Float = (a == goofyIcon || a == donaldIcon) ? 0.8 : 0.9;
        a.scale.set(s, s);
        a.camera = vmuCam;
        add(a);
    }
    goofyIcon.alpha = donaldIcon.alpha = 0;

    if (isCrisis || PlayState.instance.inCutscene) {
        camHUD.alpha = 0;
        vmuCam.alpha = 0;
    }
    if(PlayState.instance.inCutscene) wasCutscening = true;
}

function beatHit(curBeat:Int) {
    for (i in allIcons) i.scale.set(1.1, 1.1);
    if (isVehement) {
        if(PlayState.variation == null) {
            if(curBeat == 238){
                iconBF.setIcon('bf2'); iconDad.setIcon('mickey3'); goofyIcon.setIcon('goofy2'); donaldIcon.setIcon('donald2'); 
                for (i in [iconDad, goofyIcon, donaldIcon]) {
                    if(i.health >= 0.8) i.animation.curAnim.curFrame = 2;
                    else if(i.health <= 0.2) i.animation.curAnim.curFrame = 1;
                }                  
            }
            if(curBeat == 104){
                iconDad.setIcon('mickey2');
                for (i in [iconDad]) {
                    if(i.health >= 0.8) i.animation.curAnim.curFrame = 2;
                    else if(i.health <= 0.2) i.animation.curAnim.curFrame = 1;
                }    
            }
        } else {
            if(curBeat == 202){
                iconBF.setIcon('bf2'); iconDad.setIcon('mickey3'); goofyIcon.setIcon('goofy2'); donaldIcon.setIcon('donald2'); 
                for (i in [iconDad, goofyIcon, donaldIcon]) {
                    if(i.health >= 0.8) i.animation.curAnim.curFrame = 2;
                    else if(i.health <= 0.2) i.animation.curAnim.curFrame = 1;
                }                  
            }
            if(curBeat == 104){
                iconDad.setIcon('mickey2');
                for (i in [iconDad]) {
                    if(i.health >= 0.8) i.animation.curAnim.curFrame = 2;
                    else if(i.health <= 0.2) i.animation.curAnim.curFrame = 1;
                }    
            }
        }

    }
    if (isCrisis && curBeat == 98) FlxTween.tween(vmuCam, {alpha: 1}, 2, {ease: FlxEase.quadOut});
    if (curBeat == 474) FlxTween.tween(vmuCam, {alpha: 0}, 1, {ease: FlxEase.quadOut});
}

function stepHit() {
    if (!isVehement) return;
    if (curStep == 446) FlxTween.tween(donaldIcon, {alpha: 1}, 0.5, {ease: FlxEase.quartOut});
    if (curStep == 462) FlxTween.tween(goofyIcon, {alpha: 1}, 0.5, {ease: FlxEase.quartOut});
}

function postUpdate(elapsed:Float) {
    for (i in allIcons) {
        var target = (i == goofyIcon || i == donaldIcon) ? 0.8 : 0.9;
        i.scale.set(FlxMath.lerp(i.scale.x, target, 0.05), FlxMath.lerp(i.scale.y, target, 0.05));
    }

    healthPercent = FlxMath.lerp(healthPercent, health / maxHealth, 0.15);

    for (i in [iconDad, goofyIcon, donaldIcon])
        i.health = iconP2.health;
    iconBF.health = iconP1.health;

    var w = rightHealth.frameWidth;
    var h = rightHealth.frameHeight;
    rightHealth.clipRect.set(isCrisis ? 0 : w * (1 - healthPercent), isCrisis ? h * (1 - healthPercent) : 0, isCrisis ? w : w * healthPercent, isCrisis ? h * healthPercent : h);
    rightHealth.clipRect = rightHealth.clipRect;

    scoreTxt.text = "SCORE: " + FlxStringUtil.formatMoney(Math.floor(songScore), true).split(".")[0];
    missesTxt.text = "MISSES: " + misses;

    if (inst != null && timeBar.max != inst.length)
        timeBar.setRange(0, Math.max(1, inst.length));

    if (inst != null && inst.playing) {
        var curr:String = FlxStringUtil.formatTime(inst.time / 1000);
        var total:String = FlxStringUtil.formatTime(inst.length / 1000);
        timeTxt.text = curr + " / " + total;
    }

    for(spr in comboGroup.members) { spr.camera = camCombo; spr.velocity.x = 0; }
}
function onCountdown(e){
    if(wasCutscening){
        for (i in [camHUD, vmuCam]) i.alpha = 1;
    }
}

function onSongStart() {
    for (i in [timeBarBG, timeBar, timeTxt]) FlxTween.tween(i, {alpha: 1}, 0.3);
}
function onPostNoteCreation(e) if(e.note.gapFix != null) e.note.gapFix = 4;