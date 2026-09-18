import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxTextBorderStyle;
import flixel.text.FlxTextAlign;
import flixel.group.FlxSpriteGroup;
import openfl.display.BlendMode;
import funkin.backend.MusicBeatTransition;
import funkin.backend.utils.DiscordUtil;

var headphonesText, flashingLightsText:FunkinText;
var headphonesIcon, flashingLightsIcon:FunkinSprite;
var bg1:FlxBackdrop;

var promptGroup:FlxSpriteGroup;

var step:Int = 0;
var canPress:Bool = false;
var waveTimer:Float = 0;

// 按钮
var yesBtn:FunkinText;
var noBtn:FunkinText;
var buttonsReady:Bool = false;
var choiceMade:Bool = false;

function postCreate() {
    MusicBeatTransition.script = null;
    bg1 = new FlxBackdrop(Paths.image('pause/background-gray-2'));
    bg1.velocity.set(-50, -50);
    bg1.antialiasing = Options.antialiasing;
    bg1.alpha = 0;
    add(bg1);

    var blackBox = new FunkinSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    blackBox.blend = 3;
    blackBox.alpha = 0.5;
    add(blackBox);

    flashingLightsIcon = createIcon('menus/flashingLightsIcon');
    headphonesIcon = createIcon('menus/headPhonesIcon');
    headphonesIcon.x += 37.5;

    // 第一行警告文本（保持不变）
    flashingLightsText = createText("Warning! This mod contains flashing lights!", 28);

    // 第二行提示文本（询问句，yes/no 带波浪）
    promptGroup = new FlxSpriteGroup();
    var fullText:String = "Do you want to enable flashing lights? yes or no?";
    var currentX:Float = 0;

    for (i in 0...fullText.length) {
        var char = fullText.charAt(i);
        var letter = new FunkinText(currentX, 5, 0, char);
        letter.setFormat(Paths.font("WickedMouse.ttf"), 19, 0xFFFBFF00, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        letter.borderSize = 2;
        letter.antialiasing = Options.antialiasing;
        promptGroup.add(letter);
        currentX += letter.width - 2;
    }
    promptGroup.alpha = 0;
    promptGroup.screenCenter(FlxAxes.X);
    add(promptGroup);

    headphonesText = createText("Use headphones for a better experience!", 32);

    // 创建 Yes / No 按钮
    yesBtn = new FunkinText(0, 0, 0, "Yes");
    yesBtn.setFormat(Paths.font("WickedMouse.ttf"), 30, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    yesBtn.borderSize = 2;
    yesBtn.antialiasing = Options.antialiasing;
    yesBtn.alpha = 0;
    add(yesBtn);

    noBtn = new FunkinText(0, 0, 0, "No");
    noBtn.setFormat(Paths.font("WickedMouse.ttf"), 30, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    noBtn.borderSize = 2;
    noBtn.antialiasing = Options.antialiasing;
    noBtn.alpha = 0;
    add(noBtn);

    // 初始显示警告画面
    showScreen(flashingLightsIcon, flashingLightsText, 0xFFAED8EC);
    FlxTween.tween(bg1, {alpha: 0.5}, 1, {startDelay: 0.1});

    FlxG.sound.play(Paths.sound('gameOverEnd'), 1);
    new FlxTimer().start(0.5, function(_) canPress = true);

    DiscordUtil.call("onMenuLoaded", ["Warning"]);
}

function createIcon(path:String):FunkinSprite {
    var icon = new FunkinSprite().loadGraphic(Paths.image(path));
    icon.antialiasing = Options.antialiasing;
    icon.scale.set(0.125, 0.125);
    icon.updateHitbox();
    icon.screenCenter();
    icon.alpha = 0;
    add(icon);
    return icon;
}

function createText(text:String, size:Int):FunkinText {
    var txt = new FunkinText(0, FlxG.height + 100, 800, text);
    txt.setFormat(Paths.font("WickedMouse.ttf"), size - 4, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    txt.wordWrap = true; txt.autoSize = false;
    txt.borderSize = 2;
    txt.antialiasing = Options.antialiasing;
    txt.alpha = 0;
    txt.screenCenter(FlxAxes.X);

    add(txt);
    return txt;
}

function showScreen(icon:FunkinSprite, txt:FunkinText, color:Int) {
    FlxTween.color(bg1, 1, bg1.color, color, {ease: FlxEase.quadInOut});

    icon.y -= 100;

    icon.alpha = 1;
    icon.scale.set(0.125, 0.125);
    FlxTween.tween(icon.scale, {x: 0.3, y: 0.3}, 0.6, {
        ease: FlxEase.bounceOut
    });

    txt.alpha = 0;
    var targetY:Float = 640 - (txt.height / 2) - 100;
    var startY:Float = targetY + 20;
    txt.y = startY;
    FlxTween.tween(txt, {alpha: 1, y: targetY}, 0.5, {
        ease: FlxEase.quartOut,
        startDelay: 0.6
    });

    // 第二行提示文本（询问句）
    if (txt == flashingLightsText) {
        promptGroup.alpha = 0;
        var targetGroupY:Float = 657.5 - 100;
        var startGroupY:Float = targetGroupY + 20;
        promptGroup.y = startGroupY;
        FlxTween.tween(promptGroup, {alpha: 1, y: targetGroupY}, 0.5, {
            ease: FlxEase.quartOut,
            startDelay: 1.1
        });

        // 布置按钮
        buttonsReady = false;
        choiceMade = false;
        var gap = 200.0;
        var totalWidth = yesBtn.width + noBtn.width + gap;
        var startX = (FlxG.width - totalWidth) / 2;
        var btnY = targetGroupY + promptGroup.height + 30;

        yesBtn.setPosition(startX, btnY);
        noBtn.setPosition(startX + yesBtn.width + gap, btnY);

        yesBtn.alpha = 0;
        noBtn.alpha = 0;
        yesBtn.scale.set(1, 1);
        noBtn.scale.set(1, 1);
        yesBtn.color = FlxColor.WHITE;
        noBtn.color = FlxColor.WHITE;

        FlxTween.tween(yesBtn, {alpha: 1}, 0.4, {startDelay: 1.2, ease: FlxEase.quartOut});
        FlxTween.tween(noBtn, {alpha: 1}, 0.4, {
            startDelay: 1.2,
            ease: FlxEase.quartOut,
            onComplete: function(_) {
                buttonsReady = true;
            }
        });
    }
}

function hideScreen(icon:FunkinSprite, txt:FunkinText) {
    FlxTween.tween(icon, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut});
    FlxTween.tween(txt, {alpha: 0, y: FlxG.height}, 0.5, {ease: FlxEase.quintOut});
    FlxTween.tween(icon.scale, {x: 0.1, y: 0.1}, 0.5, {ease: FlxEase.quadIn});

    if (txt == flashingLightsText) {
        FlxTween.tween(promptGroup, {alpha: 0}, 0.5, {ease: FlxEase.quadInOut});
        FlxTween.tween(yesBtn, {alpha: 0}, 0.3);
        FlxTween.tween(noBtn, {alpha: 0}, 0.3);
    }
}

function update(elapsed:Float) {
    // 波浪效果仅作用于 yes 和 no（索引 39-41, 46-47）
    if (step == 0 && promptGroup.alpha > 0) {
        waveTimer += elapsed * 4;
        for (i in 0...promptGroup.members.length) {
            var isKey = (i >= 39 && i <= 41) || (i >= 46 && i <= 47);
            if (isKey) {
                promptGroup.members[i].offset.y = Math.sin(waveTimer + (i * 0.6)) * 3;
            } else {
                promptGroup.members[i].offset.y = 0;
            }
        }
    }

    // 第一页：按钮悬浮和点击
    if (step == 0 && !choiceMade && buttonsReady) {
        var mouse = FlxG.mouse;

        // 悬浮变色
        if (mouse.overlaps(yesBtn)) {
            yesBtn.color = 0xFFFBFF00;
        } else {
            yesBtn.color = FlxColor.WHITE;
        }
        if (mouse.overlaps(noBtn)) {
            noBtn.color = 0xFFFBFF00;
        } else {
            noBtn.color = FlxColor.WHITE;
        }

        // 鼠标点击（松开时触发）
        if (mouse.justPressed) {
            if (mouse.overlaps(yesBtn)) {
                onChoiceMade(true);
            } else if (mouse.overlaps(noBtn)) {
                onChoiceMade(false);
            }
        }
    }

    // 第二页：鼠标点击任意位置继续
    if (canPress && step == 1 && FlxG.mouse.justPressed) {
        canPress = false;
        hideScreen(headphonesIcon, headphonesText);
        FlxTween.tween(bg1, {alpha: 0}, 0.8);
        FlxG.sound.play(Paths.sound('stickersounds/mouse/4'), 0.5);
        new FlxTimer().start(1.5, ()->{
            FlxG.switchState(new TitleState());
        });
    }
}

function onChoiceMade(isYes:Bool) {
    choiceMade = true;
    buttonsReady = false;

    // 根据选择播放音效
    if (!isYes) {
        Options.flashingLights = false;
        FlxG.sound.play(Paths.sound('settingTurnOff'));
    } else {
        FlxG.sound.play(Paths.sound('stickersounds/mouse/4'), 0.5);
    }

    var chosen = isYes ? yesBtn : noBtn;
    var other = isYes ? noBtn : yesBtn;

    // 另一个按钮原地淡出
    FlxTween.tween(other, {alpha: 0}, 0.5, {ease: FlxEase.quadOut});

    // 被点击的按钮水平移动到屏幕中央（Y 不变），并放大
    var targetX = (FlxG.width - chosen.width) / 2;
    FlxTween.tween(chosen, {x: targetX}, 0.5, {ease: FlxEase.quadInOut});
    FlxTween.tween(chosen.scale, {x: 1.2, y: 1.2}, 0.5, {
        ease: FlxEase.quadInOut,
        onComplete: function(_) {
            // 移动到中央后，等待 0.5 秒再进入下一步
            new FlxTimer().start(0.5, function(_) {
                hideScreen(flashingLightsIcon, flashingLightsText);
                FlxTween.tween(chosen, {alpha: 0}, 0.3); // 隐藏按钮
                showScreen(headphonesIcon, headphonesText, 0xFF965549);
                new FlxTimer().start(0.6, function(_) {
                    step = 1;
                    new FlxTimer().start(0.3, function(_) canPress = true);
                });
            });
        }
    });
}