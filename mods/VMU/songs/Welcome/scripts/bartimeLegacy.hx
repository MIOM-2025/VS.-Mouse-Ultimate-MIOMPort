// 时间条脚本 - 仅在 isWelcomeLegacy 为 true 时生成
// 整体高度提高2像素（背景+2，白色条+2），字体增大2像素，边框保持均匀4像素
import flixel.util.FlxGradient;
import funkin.backend.FunkinText;
import flixel.util.FlxStringUtil;
import flixel.util.FlxAxes;
import flixel.text.FlxTextAlign;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;

public var isWelcomeLegacy:Bool = true;
public var songStarted:Bool = false;
public var time_Txt:FunkinText;
public var timeBarr:FlxSprite;      // 白色进度条
public var timeBarrBG:FlxSprite;    // 黑色背景（边框）
public var timeBarrWidth:Float = 0;
var songLength:Float = 0.0;
var hudFadedIn:Bool = false;

// 可配置参数（已调整：整体高度+2，字体增大）
var barWidth:Float = 404;      // 黑色背景宽度（不变）
var barHeight:Float = 19;      // 黑色背景高度（原17 + 2）
var whiteBarWidth:Float = 396; // 白色条宽度（不变）
var whiteBarHeight:Float = 11; // 白色条高度（原9 + 2）
var barY:Float = 18;           // 整体Y坐标（不变）
var fontSize:Int = 30;         // 字体大小（原24 + 2）

function getFont(key:String = "vcr.ttf") {
    return Paths.font(key);
}
if (PlayState.variation != "Legacy") {
    disableScript();
    return;
}

function create() {
    if (isWelcomeLegacy) {
        // 时间文字（VCR字体，字号26，抗锯齿）
        time_Txt = new FunkinText(0, 0, FlxG.width / 2, "0:00", fontSize, true);
        time_Txt.alignment = FlxTextAlign.CENTER;
        time_Txt.screenCenter(FlxAxes.X);
        time_Txt.camera = camHUD;
        time_Txt.font = getFont("vcr.ttf");
        time_Txt.borderSize = 2;
        time_Txt.color = FlxColor.WHITE;
        time_Txt.antialiasing = true;
        time_Txt.alpha = 0; // 初始隐藏

        // 黑色背景
        timeBarrBG = FlxGradient.createGradientFlxSprite(Std.int(barWidth), Std.int(barHeight), [FlxColor.BLACK, FlxColor.BLACK], 1, -90);
        timeBarrBG.screenCenter(FlxAxes.X);
        timeBarrBG.camera = camHUD;
        timeBarrBG.alpha = 0;

        // 白色进度条
        timeBarr = FlxGradient.createGradientFlxSprite(Std.int(whiteBarWidth), Std.int(whiteBarHeight), [FlxColor.WHITE, FlxColor.WHITE], 1, 90);
        timeBarr.camera = camHUD;
        timeBarrWidth = timeBarr.width;
        timeBarr.alpha = 0;
    }
}

function postCreate() {
    if (isWelcomeLegacy && time_Txt != null) {
        insert(0, time_Txt);
        insert(members.indexOf(time_Txt), timeBarrBG);
        insert(members.indexOf(timeBarrBG) + 1, timeBarr);

        // 水平居中背景
        var centerX:Float = FlxG.width / 2;
        timeBarrBG.x = centerX - timeBarrBG.width / 2;

        // 背景垂直位置
        timeBarrBG.y = barY;

        // 白色条：从左向右延伸，垂直居中
        var leftPadding:Float = (timeBarrBG.width - timeBarr.width) / 2; // 4像素
        timeBarr.x = timeBarrBG.x + leftPadding;
        timeBarr.y = timeBarrBG.y + (timeBarrBG.height - timeBarr.height) / 2;

        // 文字垂直居中于黑色背景
        time_Txt.y = timeBarrBG.y + (timeBarrBG.height - time_Txt.frameHeight) / 2;

        // 确保所有元素抗锯齿
        for (obj in [time_Txt, timeBarrBG, timeBarr]) {
            if (obj != null) obj.antialiasing = true;
        }
    }
}

function onStartSong() {
    songStarted = true;
    if (isWelcomeLegacy) {
        songLength = inst.length;
        fadeInHUD();
    }
}

function fadeInHUD() {
    if (hudFadedIn) return;
    hudFadedIn = true;
    var targets = [time_Txt, timeBarrBG, timeBarr];
    for (obj in targets) {
        if (obj != null) {
            FlxTween.tween(obj, {alpha: 1}, 0.5);
        }
    }
}

function postUpdate() {
    if (isWelcomeLegacy && songStarted && timeBarr != null && songLength > 0 && !paused) {
        var curTime:Float = Math.max(0, Conductor.songPosition);
        var ratio:Float = FlxMath.bound(curTime / songLength, 0, 1);
        timeBarr.scale.x = ratio;
        timeBarr.updateHitbox();
        // 保持左侧起点不动，实现从左向右延伸
    }

    if (isWelcomeLegacy && songStarted && time_Txt != null) {
        var curTime:Float = Math.max(0, Conductor.songPosition);
        var secondsTotal:Int = Math.floor(curTime / 1000);
        time_Txt.text = FlxStringUtil.formatTime(secondsTotal, false);
    }
}

public function setTimeBarVisible(visible:Bool) {
    if (!isWelcomeLegacy) return;
    var alphaTarget:Float = visible ? 1 : 0;
    if (time_Txt != null) time_Txt.alpha = alphaTarget;
    if (timeBarr != null) timeBarr.alpha = alphaTarget;
    if (timeBarrBG != null) timeBarrBG.alpha = alphaTarget;
}