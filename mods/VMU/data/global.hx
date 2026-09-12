import funkin.backend.utils.WindowUtils;
import lime.graphics.Image;
import funkin.backend.system.framerate.Framerate;
import openfl.text.TextFormat;
import openfl.text.TextField;
import funkin.backend.MusicBeatTransition;
import funkin.backend.utils.DiscordUtil;
import openfl.display.Sprite;
import Sys;

import openfl.Lib;
import funkin.backend.utils.NativeAPI;
import flixel.util.FlxColor;

public static var fpsText:TextField;
public static var solidSprite:Sprite;

public static var cursor = Assets.getBitmapData(Paths.image('menus/cursor/cursor'));
public static var click = Assets.getBitmapData(Paths.image('menus/cursor/click'));
public static var nope = Assets.getBitmapData(Paths.image('menus/cursor/nope'));
public static var loading = Assets.getBitmapData(Paths.image('menus/cursor/loading'));

FlxG.mouseControls = FlxG.mouse.enabled = FlxG.mouse.visible = true;
FlxG.mouse.load(cursor, 0.5);
FlxG.mouse.useSystemCursor = false;

function preStateSwitch() {
    FlxG.mouse.visible = true;
    Framerate.instance.visible = false;
}

function new() {
    solidSprite = new Sprite();
    solidSprite.graphics.beginFill(0x000000);
    solidSprite.graphics.drawRect(0, 0, 100, 100);
    solidSprite.graphics.endFill();
    solidSprite.alpha = 0.3;
    solidSprite.x = 0;   // 紧贴游戏画面左边缘
    solidSprite.y = 0;   // 紧贴游戏画面上边缘
    FlxG.game.addChild(solidSprite);  // 添加到游戏内部

    fpsText = new TextField();
    fpsText.defaultTextFormat = new TextFormat(Paths.getFontName(Paths.font('CreatoDisplay-ExtraBold.otf')), 15, 0xFFFFFF);
    fpsText.height = 30;
    fpsText.selectable = false;
    fpsText.x = 0;
    fpsText.y = 0;
    FlxG.game.addChild(fpsText);      // 添加到游戏内部

    window.setIcon(Image.fromBytes(Assets.getBytes(Paths.image('game/monoIcon'))));

    FlxG.save.data.modcharts ??= true;

    FlxG.save.data.overlay ??= true;
    FlxG.save.data.stickers ??= true;
    FlxG.save.data.subtitles ??= true;

    FlxG.save.data.ntsc ??= true;
    FlxG.save.data.lowquality ??= true;
    FlxG.save.data.warp ??= true;
    FlxG.save.data.chromatic ??= true;
    FlxG.save.data.glow ??= true;
    FlxG.save.data.monotone ??= true;

    FlxG.save.data.freeplay ??= false;
    FlxG.save.data.warning ??= true;

    if(!FlxG.save.data.warning)
        Flags.DISABLE_WARNING_SCREEN = true;
}

function update(elapsed:Float) {
    fpsText.text = Framerate.fpsCounter.fpsNum.text + " FPS ~ " + Framerate.memoryCounter.memoryText.text + Framerate.memoryCounter.memoryPeakText.text;
    fpsText.setTextFormat(fpsText.defaultTextFormat);
    fpsText.width = fpsText.textWidth + 10;
    setSize(fpsText.width - 3, fpsText.height - 8);

    if (FlxG.keys.justPressed.F11) FlxG.fullscreen = !FlxG.fullscreen;
    if (FlxG.keys.justPressed.F3) {
        solidSprite.alpha = 0.3 - solidSprite.alpha;
        fpsText.alpha = 1 - fpsText.alpha;
    }

    if (FlxG.mouse.justPressed) FlxG.mouse.load(click, 0.5);
    if (FlxG.mouse.justPressedRight) FlxG.mouse.load(nope, 0.6);
    if (FlxG.mouse.justReleased || FlxG.mouse.justReleasedRight) FlxG.mouse.load(cursor, 0.5);
}

function setSize(width, height) {
    solidSprite.graphics.clear();
    solidSprite.graphics.beginFill(0x000000);
    solidSprite.graphics.drawRect(0, 0, width, height);
    solidSprite.graphics.endFill();
}

function destroy() {
    WindowUtils.winTitle = "Friday Night Funkin' - Codename Engine";
    Framerate.instance.visible = true;
    FlxG.game.removeChild(solidSprite);
    FlxG.game.removeChild(fpsText);
}

public static function changeMouse(mouse:String) FlxG.mouse.load(mouse, 0.9);