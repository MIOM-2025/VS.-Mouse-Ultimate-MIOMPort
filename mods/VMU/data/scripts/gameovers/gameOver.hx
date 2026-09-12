import funkin.backend.MusicBeatState;
import flixel.text.FlxTextAlign;
import flixel.text.FlxTextBorderStyle;
import funkin.options.OptionsMenu;
import flixel.addons.display.FlxBackdrop;
import openfl.display.BlendMode;
import openfl.filters.ShaderFilter;
import funkin.options.TreeMenu;
import funkin.editors.charter.Charter;
import funkin.options.keybinds.KeybindsOptions;
import flixel.ui.FlxBar;
import flixel.util.FlxStringUtil;

// ------------------- 变量声明 -------------------
var overlay = new CustomShader('overlayShader');
var dir:String = "menus/gameOver/";
var camDeath:FlxCamera;
var soundIndex:Int = 1;
var flickerTimer:FlxTimer;

var subTxt:FunkinText;
var subData:Array<{time:Float, text:String}> = [];
var subIndex:Int = 0;

var menuItems:Array<String> = ['RETRY', 'OPTIONS', 'EXIT'];
var textArray:Array<FunkinText> = [];

var curSelected:Int = 0;
var ending:Bool = false;
var canInteract:Bool = false;

// ---- 鼠标交互专用变量 ----
var canChangeWithMouse:Bool = true;
var oldMousePos:FlxPoint = FlxPoint.get();
var curMousePos:FlxPoint = FlxPoint.get();

// ---- 鼠标点击待执行状态 ----
var actionPending:Bool = false;
var pendingItemId:Int = -1;

var timeBar:FlxBar;
var timeBarBG:FlxSprite;
var timeTxt:FunkinText;
var deathPoint:FlxSprite;
var currentChar;

var folder:String = "welcome";
var songName:String = PlayState.SONG.meta.name.toLowerCase();
if (songName == "vehement" || songName == "crisis") folder = songName;

// ------------------- 创建函数 -------------------
function create(e) {
    // 读取字幕配置
    var path:String = "data/scripts/gameovers/" + folder + ".txt";
    var content:String = Assets.getText(path);
    if (content != null && content.length > 0) {
        for (line in content.split('\n')) {
            var split = line.split('|');
            if (split.length == 3 && Std.parseInt(StringTools.trim(split[0])) == PlayState.deathCounter) {
                subData.push({
                    time: Std.parseFloat(StringTools.trim(split[1])),
                    text: StringTools.trim(split[2])
                });
            }
        }
    }

    e.cancel();

    // 创建独立摄像机
    camDeath = new FlxCamera();
    camDeath.bgColor = FlxColor.TRANSPARENT;
    camDeath.zoom = 1;          // 强制缩放为1，确保视口坐标与像素对应
    camDeath.scroll.set(0, 0);  // 无滚动
    FlxG.cameras.add(camDeath, false);

    overlay.merge = 0.5;

    var curTime:Float = Conductor.songPosition;
    var totalTime:Float = PlayState.instance.inst.length;
    var songPercent:Float = (curTime / totalTime) * 100;

    // 加载死亡音效
    sound = FlxG.sound.load(Paths.sound('gameovers/' + folder + '/' + PlayState.deathCounter));
    sound.onComplete = () -> {
        if (ending) return;
        FlxG.sound.music.fadeIn(2, 0.2, 0.5);
        FlxTween.tween(subTxt, {alpha: 0}, 0.5);
    };

    // ---------- 背景与装饰 ----------
    bg = new FunkinSprite(0, 0).loadGraphic(Paths.image(dir + 'bg'));
    mistFront = new FlxBackdrop(Paths.image(dir + 'mistFront'), 0x11);
    mistFront.velocity.set(40, 0);
    mistFront.alpha = 0;
    mistFront.shader = overlay;

    currentChar = switch(PlayState.instance.boyfriend.curCharacter) {
        case "mickey-c1": "mickey";
        default: "bf";
    }
    var charOffset = switch(PlayState.instance.boyfriend.curCharacter) {
        case "mickey-c1": -50;
        default: 0;
    }

    playGameOverSound(0);

    spotlight = new FunkinSprite(0, 0).loadGraphic(Paths.image(dir + 'spotlight'));
    var colorShader:CustomShader = new CustomShader("adjustColor");
    spotlight.shader = colorShader;
    switch(currentChar){
        case "mickey": 
            colorShader.hue = 180; 
            colorShader.saturation = 30;
        default:
            colorShader.hue = 0; 
            colorShader.saturation = 0;
    }
    deadBF = new FunkinSprite(0, 0).loadGraphic(Paths.image(dir + currentChar));
    gameOverText = new FunkinSprite(0, 0).loadGraphic(Paths.image(dir + 'gameOverText'));

    bg.scale.set(0.75, 0.75); 
    spotlight.scale.set(0.75, 0.75); 
    deadBF.scale.set(0.75, 0.75); 
    gameOverText.scale.set(0.675, 0.675);

    // ---------- 进度条 ----------
    timeBarBG = new FlxSprite(0, 620).makeGraphic(600, 15, FlxColor.BLACK);
    timeBarBG.screenCenter(FlxAxes.X);
    timeBarBG.alpha = 0;

    startFlag = new FunkinSprite(timeBarBG.x - 75, timeBarBG.y - 87.5).loadGraphic(Paths.image(dir + 'startFlag'));
    flagFinish = new FunkinSprite(timeBarBG.x - 25, timeBarBG.y - 637.5);
    flagFinish.frames = Paths.getSparrowAtlas(dir + 'flagFinish');
    flagFinish.animation.addByPrefix('idle', 'flagLoop', 6, true);
    flagFinish.animation.play('idle');
    flagFinish.scale.set(0.75, 0.75);
    for (i in [startFlag, flagFinish]) {
        i.scale.set(0.75, 0.75);
        i.alpha = 0;
    }

    timeBar = new FlxBar(timeBarBG.x + 5, timeBarBG.y + 5, null, 590, 5);
    timeBar.createFilledBar(0xFF222222, 0xFFFFFFFF);
    timeBar.percent = 0;
    timeBar.alpha = 0;

    deathPoint = new FlxSprite(timeBarBG.x, timeBarBG.y - 5).makeGraphic(5, 25, FlxColor.YELLOW);
    deathPoint.alpha = 0;

    timeTxt = new FunkinText(timeBarBG.x, timeBarBG.y + 25, 600, "DIED AT: " + FlxStringUtil.formatTime(curTime / 1000) + " / " + FlxStringUtil.formatTime(totalTime / 1000) + "\n" + PlayState.SONG.meta.name.toUpperCase() + " ~ " + PlayState.instance.songScore, 20);
    timeTxt.setFormat(Paths.font("WickedMouse.ttf"), 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    timeTxt.borderSize = 2;
    timeTxt.alpha = 0;

    subTxt = new FunkinText(0, 550, FlxG.width, "", 20);
    subTxt.setFormat(Paths.font("CreatoDisplay-ExtraBold.otf"), 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    subTxt.borderSize = 2;
    subTxt.alpha = 0;
    
    // 添加所有对象到状态
    for (i in [bg, mistFront, spotlight, deadBF, gameOverText, startFlag, timeBarBG, timeBar, timeTxt, deathPoint, subTxt, flagFinish]) {
        i.antialiasing = Options.antialiasing;
        i.cameras = [camDeath];
        if (i != startFlag && i != timeBar && i != timeBarBG && i != timeTxt && i != deathPoint && i != flagFinish) i.screenCenter();
        add(i);
    }

    for (fuck in [startFlag, timeBarBG, timeBar, timeTxt, deathPoint]) fuck.y -= 500;

    // ---------- 菜单项 ----------
    for (i in 0...menuItems.length) {
        var item = new FunkinText(0, 277.5 + (i * 60), FlxG.width, menuItems[i], 16);
        item.setFormat(Paths.font("WickedMouse.ttf"), 28, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        item.cameras = [camDeath];
        item.antialiasing = Options.antialiasing;
        item.borderSize = 3;
        item.ID = i;
        item.alpha = 0;
        add(item);
        textArray.push(item);
        FlxTween.tween(item, {alpha: 1}, 0.2, {ease: FlxEase.quadOut, startDelay: 2 + (i * 0.1)});
    }

    // ---------- 初始位置与动画 ----------
    spotlight.y -= 52.5;
    deadBF.y -= 500 - charOffset;
    gameOverText.y -= 32.5;
    subTxt.y += 300;
    spotlight.alpha = 0;
    gameOverText.alpha = 0;
    bg.alpha = 1;
    
    FlxTween.tween(bg, {alpha: 0.5}, 2, {ease: FlxEase.quadInOut, type: 4});
    FlxTween.tween(mistFront, {alpha: 0.25}, 8, {ease: FlxEase.quadOut});

    FlxTween.tween(spotlight, {alpha: 1}, 4, {
        ease: FlxEase.quadOut,
        onComplete: function(twn:FlxTween) {
            flickerTimer = new FlxTimer().start(0.1, function(tmr:FlxTimer) {
                spotlight.alpha = FlxG.random.float(0.6, 1);
            }, 0);
        }
    });

    FlxTween.tween(deadBF, {y: 450 + charOffset}, 2, {
        ease: FlxEase.bounceOut, 
        startDelay:0.8,
        onComplete: function(twn:FlxTween) {
            playGameOverSound(1);
            sound.play();
            canInteract = true;
            FlxTween.tween(deadBF.scale, {x: 0.75, y: 0.75}, 1.5, {ease: FlxEase.quadInOut, type: 4});

            for (i in [startFlag, timeBarBG, timeBar, timeTxt, deathPoint, subTxt, flagFinish]) FlxTween.tween(i, {alpha: 1}, 0.5);
            var targetX:Float = timeBarBG.x + (590 * (songPercent / 100));
            var count:Int = 0;
            var maxTicks:Int = Math.floor(songPercent / 5);
            new FlxTimer().start(1.2 / maxTicks, function(tmr:FlxTimer) {
                var pips:FlxSound = FlxG.sound.play(Paths.sound('instantClick'), 0.25);
                pips.pitch = 1 + (count * 0.05);
                count++;
            }, maxTicks);
            FlxTween.tween(timeBar, {percent: songPercent}, 1.2, {ease: FlxEase.quadOut});
            FlxTween.tween(deathPoint, {x: targetX}, 1.2, {ease: FlxEase.quadOut});
        }
    });

    new FlxTimer().start(1.5, function(tmr:FlxTimer) {
        deadBF.scale.set(1.2, 0.6);
        FlxTween.tween(deadBF.scale, {x: 0.75, y: 0.75}, 2, {ease: FlxEase.elasticOut});
    });

    changeSelection();
}

// ------------------- 更新循环 -------------------
var subDelay:Float = 0.01;
function update(elapsed:Float) {
    // ---- 更新鼠标屏幕位置（用于判断是否移动） ----
    FlxG.mouse.getScreenPosition(FlxG.camera, curMousePos);
    if (curMousePos.x != oldMousePos.x || curMousePos.y != oldMousePos.y) {
        oldMousePos.set(curMousePos.x, curMousePos.y);
        canChangeWithMouse = true;
    } else canChangeWithMouse = false;

    // ---- 获取鼠标在死亡摄像机视口内的绝对像素坐标（自动适配缩放） ----
    var mouseViewPos:FlxPoint = FlxPoint.get();
    FlxG.mouse.getPositionInCameraView(camDeath, mouseViewPos);

    // ---- 字幕更新 ----
    if (sound.playing && subIndex < subData.length) {
        var sTime:Float = (sound.time / 1000) - subDelay;
        if (sTime >= subData[subIndex].time) {
            subTxt.text = subData[subIndex].text;
            subTxt.alpha = (subTxt.text == "") ? 0 : 1;
            if (subTxt.alpha > 0) {
                var origX = subTxt.x;
                new FlxTimer().start(0.01, (t) -> {
                    subTxt.x = origX + FlxG.random.int(-3, 3);
                }, 15, (t) -> subTxt.x = origX);
            }
            subIndex++;
        }
    } else if (!sound.playing && subTxt.alpha > 0 && !ending) {
        subTxt.alpha -= 5 * elapsed;
    }

    // ---- 鼠标交互（使用视口坐标） ----
    if (!ending && canInteract) {
        // 悬停切换高亮（只有当鼠标移动到不同选项时）
        for (item in textArray) {
            if (item.getHitbox().containsPoint(mouseViewPos) && item.ID != curSelected && canChangeWithMouse) {
                changeSelection(item.ID - curSelected);
            }
        }

        // 鼠标按下
        if (FlxG.mouse.justPressed) {
            var clickedItemId:Int = -1;
            for (item in textArray) {
                if (item.getHitbox().containsPoint(mouseViewPos)) {
                    clickedItemId = item.ID;
                    break;
                }
            }
            if (clickedItemId != -1) {
                if (clickedItemId == curSelected) {
                    // 点击高亮项 → 待执行
                    actionPending = true;
                    pendingItemId = clickedItemId;
                } else {
                    // 点击非高亮项 → 切换高亮，取消待执行
                    changeSelection(clickedItemId - curSelected);
                    actionPending = false;
                    pendingItemId = -1;
                }
            } else {
                // 点击空白区域
                actionPending = false;
                pendingItemId = -1;
            }
        }

        // 鼠标释放
        if (FlxG.mouse.justReleased) {
            if (actionPending && pendingItemId == curSelected) {
                // 检查鼠标是否仍停留在同一选项上
                var stillOnItem = false;
                for (item in textArray) {
                    if (item.ID == pendingItemId && item.getHitbox().containsPoint(mouseViewPos)) {
                        stillOnItem = true;
                        break;
                    }
                }
                if (stillOnItem) {
                    executeSelected();
                }
            }
            // 重置状态
            actionPending = false;
            pendingItemId = -1;
        }

        // 键盘控制（按下即执行）
        if (controls.UP_P) changeSelection(-1);
        if (controls.DOWN_P) changeSelection(1);
        if (controls.ACCEPT) {
            executeSelected();
        }
    }

    // ---- 菜单项缩放与颜色平滑动画 ----
    var targetScale:Float;
    for (item in textArray) {
        targetScale = (item.ID == curSelected) ? 1.0 : 0.9;
        item.scale.set(
            lerp(item.scale.x, targetScale, 0.2),
            lerp(item.scale.y, targetScale, 0.2)
        );
        item.color = (item.ID == curSelected) ? FlxColor.YELLOW : FlxColor.WHITE;
    }

    // 释放临时点（可选，Flixel会自动回收）
    mouseViewPos.put();
}

// ------------------- 执行选中的菜单项 -------------------
function executeSelected() {
    if (ending) return;
    switch(curSelected) {
        case 0: // RETRY
            ending = true;
            playGameOverSound(2);
            FlxG.sound.music.stop();
            for (i in [timeBar, timeBarBG, timeTxt, deathPoint, subTxt, startFlag, flagFinish]) FlxTween.tween(i, {alpha: 0}, 1);
            for (i in 0...textArray.length) FlxTween.tween(textArray[i], {alpha: 0}, 1);
            camDeath.fade(FlxColor.BLACK, (curSound.length/2000) + 1, false, () -> FlxG.switchState(new PlayState()));
        case 1: // OPTIONS
            FlxG.switchState(new OptionsMenu((_) -> FlxG.switchState(new PlayState())));
        case 2: // EXIT
            ending = true;
            sound.stop();
            FlxG.sound.music.stop();
            if(PlayState.isStoryMode) FlxG.switchState(new MainMenuState());
            else FlxG.switchState(new FreeplayState());
    }
}

// ------------------- 音效控制 -------------------
var curSound;
function playGameOverSound(?cur:Int = 0){
    curSound = switch(cur){
        case 0:
            switch(currentChar){
                case "mickey": FlxG.sound.play(Paths.sound('mickeyFall'));
                default: FlxG.sound.play(Paths.sound('bfFall'));
            }
        case 2:
            switch(currentChar){
                case "mickey": FlxG.sound.play(Paths.sound('gameOverEnd_M'));
                default: FlxG.sound.play(Paths.sound('gameOverEnd'));
            }
        default:
            switch(currentChar){
                case "mickey": FlxG.sound.playMusic(Paths.music('gameOver_M'), 0.2, true);
                default: FlxG.sound.playMusic(Paths.music('gameOver'), 0.2, true);
            }
    }
}

// ------------------- 切换选项 -------------------
function changeSelection(change:Int = 0) {
    curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
    if (change != 0) FlxG.sound.play(Paths.sound('quickClick'), 0.5);
}