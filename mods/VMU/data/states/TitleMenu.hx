import flixel.text.FlxText.FlxTextBorderStyle;
import funkin.menus.ModSwitchMenu;
import funkin.options.OptionsMenu;
import funkin.menus.credits.CreditsMain;
import funkin.editors.EditorPicker;
import funkin.backend.MusicBeatState;
import funkin.backend.MusicBeatTransition;
import funkin.backend.week.Week;
import flixel.effects.FlxFlicker;
import funkin.savedata.FunkinSave;

static var initialized:Bool = false;
var pressedEnter:Bool = false;
var transitioning:Bool = false;

var dir:String = "menus/titlescreen/";
var clubhouse, logo, disneySpr, lock:FunkinSprite;
var beginText:FlxText;

var introAnimationComplete:Bool = false; // 标记 logo 下降动画是否完成

// 统一动画参数：两个过程使用相同的时长和缓动函数
var logoTransitionDuration:Float = 0.8;               // 动画时长（秒）
var logoTransitionEase:FlxEaseFunction = FlxEase.cubeOut; // 改为 cubeOut，更自然

function create() {
    if(!initialized) MusicBeatState.skipTransIn = true;
    MusicBeatTransition.script = 'data/stickerTransition';
    FlxG.mouse.visible = true;  // 显示鼠标/触控点
    textGroup = new FlxGroup();
    curWacky = FlxG.random.getObject(getIntroTextShit());

    CoolUtil.playMenuSong();

    clubhouse = new FunkinSprite();
    clubhouse.loadGraphic(Paths.image(dir + 'clubhouse'));
    clubhouse.screenCenter();
    clubhouse.scale.set(0.75, 0.75);

    logo = new FunkinSprite();
    logo.loadGraphic(Paths.image(dir + 'logo'));
    logo.screenCenter();

    beginText = new FlxText(0, 650, 0, "TOUCH SCREEN TO BEGIN", 32);
    beginText.setFormat(Paths.font("WickedMouse.ttf"), 32, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
    beginText.screenCenter(FlxAxes.X);
    beginText.borderSize = 2;

    disneySpr = new FunkinSprite();
    disneySpr.loadGraphic(Paths.image(dir + 'disney_logo'));
    disneySpr.screenCenter();
    disneySpr.scale.set(0.8,0.8);
    disneySpr.y += 120;
    add(disneySpr);
    disneySpr.visible = false;

    for (i in [clubhouse, logo, beginText]) {
        i.antialiasing = Options.antialiasing;
        i.alpha = 0;
        add(i);
    }

    add(textGroup);
    createCoolText(['Drunk Rat Studios']);

    if (initialized) moveToMainMenu();
	else initialized = true;
    MusicBeatTransition.script = "data/stickerTransition";

    FlxG.mouse.getScreenPosition(FlxG.camera, oldMousePos);
}

var episode1 = Week.loadWeek("episode1");
var episode1Score = FunkinSave.getWeekHighscore(episode1.id, episode1.difficulties[1]).score;
if(episode1Score > 0 ) FlxG.save.data.freeplay = true;
var freeplayUnlocked = (FlxG.save.data.freeplay);
var defaultScale = 1;

var elapsedTime:Float = 0.0;
function postUpdate(elapsed:Float) {
    elapsedTime += elapsed;
    if (elapsedTime >= 0.5) {
        elapsedTime = 0.0;
        clubhouse.skew.set(FlxG.random.float(-0.2, 0.2), FlxG.random.float(-0.2, 0.2));
    }
}

public var oldMousePos:FlxPoint = FlxPoint.get();
public var curMousePos:FlxPoint = FlxPoint.get();

function update(elapsed:Float) {
    // 文字阶段（intro 尚未跳过）允许键盘/鼠标跳过，直接进入 logo 下降动画
    if ((FlxG.mouse.justPressed || controls.ACCEPT) && !skippedIntro && !transitioning) {
        skipIntro();
    }

    // 进入主菜单的条件：动画完成 + 玩家确认
    if ((FlxG.mouse.justPressed || controls.ACCEPT) && skippedIntro && introAnimationComplete && !transitioning) {
        pressedEnter = transitioning = true;
        CoolUtil.playMenuSFX(1);
        // ---- 过渡动画（与下降动画使用相同参数） ----
        FlxTween.color(clubhouse, 0.5, 0xFFFFFFFF, 0xFF4A4E7A, {ease: FlxEase.quadInOut});
        FlxTween.cancelTweensOf(logo);
        FlxTween.tween(logo, {x: -650, y: -550, "scale.x": 0.325*0.7, "scale.y": 0.325*0.7}, logoTransitionDuration, {ease: logoTransitionEase});
        FlxTween.num(1, 0.7, 0.3, {ease:FlxEase.expoOut}, (num) -> {defaultScale = num;});
        // 等待动画完成即进入主菜单（时长与动画一致）
        new FlxTimer().start(logoTransitionDuration, () -> {
            if (!isInMainMenu) moveToMainMenu();
        });

        FlxFlicker.flicker(beginText, 0.6, 0.1, false);
        FlxTween.cancelTweensOf(beginText);
        beginText.alpha = 1;
        FlxTween.tween(beginText, {alpha:0}, 0.8);
    }
    logo.scale.set(lerp(logo.scale.x, 0.325*defaultScale, 0.15), lerp(logo.scale.y, 0.325*defaultScale, 0.15));

    if(!isInMainMenu) return;

    if (Options.devMode){
        if (controls.SWITCHMOD) {
            persistentUpdate = false;
            persistentDraw = true;
            openSubState(new ModSwitchMenu());
        }
        if (controls.DEV_ACCESS) {
            persistentUpdate = false;
            persistentDraw = true;
            openSubState(new EditorPicker());
        }        
    }

    if (FlxG.keys.justPressed.DELETE) {
        FlxG.save.data.freeplay = false;
        lock.visible = true;
    }

    FlxG.mouse.getScreenPosition(FlxG.camera, curMousePos);
	if (curMousePos.x != oldMousePos.x || curMousePos.y != oldMousePos.y) {
		oldMousePos.set(curMousePos.x, curMousePos.y);
		canChangeWithMouse = true;
	} else canChangeWithMouse = false;

    freeplayUnlocked = (FlxG.save.data.freeplay);

    var upP = controls.UP_P;
    var downP = controls.DOWN_P;
    var scroll = FlxG.mouse.wheel;

    lock.setPosition(menuItems.members[1].x + 240,menuItems.members[1].y - 30);
    lock.origin.set(-140,50);

    explosion.setPosition(lock.x - 85,lock.y + 5);
    menuItems.forEach(function(spr:FlxText)
    {
        if (spr.ID == curSelected)
        {
            spr.scale.set(lerp(spr.scale.x,1,0.2),lerp(spr.scale.y,1,0.2));
            if(curSelected == 1){
                if(freeplayUnlocked) spr.color = 0xFFFFFFFF;
                else spr.color = 0xFF666666;
                lock.scale.set(spr.scale.x * 0.5,spr.scale.y * 0.5);
            } else spr.color = 0xFFFFFFFF;
        } else {
            if(spr.ID == 1) lock.scale.set(spr.scale.x * 0.5,spr.scale.y * 0.5);
            spr.scale.set(lerp(spr.scale.x,0.9,0.2),lerp(spr.scale.y,0.9,0.2));
            if(spr.ID == 1 && !freeplayUnlocked) spr.color = 0xFF666666;
            else spr.color = 0xFFAAAAAA;
        }
        if(FlxG.mouse.overlaps(spr) && spr.ID != curSelected && canChangeWithMouse){
            changeItem(spr.ID,false,true);
        };
        if(FlxG.mouse.overlaps(spr) && spr.ID == curSelected && FlxG.mouse.justPressed && !transitioningFromMainMenu)
            selectItem();
    });

    if ((upP || downP || scroll != 0) && canSelect)
        changeItem((upP ? -1 : 0) + (downP ? 1 : 0) - scroll);

    if (controls.ACCEPT && isInMainMenu && !transitioningFromMainMenu){
        selectItem();
    }
}

var canChangeWithMouse = true;

var curSelected:Int = 0;
var transitioningFromMainMenu:Bool = false;

var exploding = false;

function selectItem(){
    switch(curSelected){
        case 0:
            goToStoryMode();
        case 1:
            if(FlxG.save.data.freeplay) new FlxTimer().start(1.2, () -> {FlxG.switchState(new FreeplayState());});
            else {
                if(lockSpammed >= 100 && !exploding) doExplosion();
                lockSpammed += 1;
                FlxTween.shake(lock, 0.05,0.05);
                FlxTween.shake(menuItems.members[1], 0.05,0.05);
                FlxG.sound.play(Paths.sound('keyboard1'));
            }
        case 2:
            new FlxTimer().start(1.2, () -> {FlxG.switchState(new OptionsMenu());});
        case 3:
            new FlxTimer().start(1.2, () -> {FlxG.switchState(new CreditsMain());});
    }
    if(curSelected == 1 && !FlxG.save.data.freeplay) return;
    if(curSelected != 0) CoolUtil.playMenuSFX(1);
    menuItems.forEach(function(spr:FlxText)
    {
        if (spr.ID == curSelected)
        {
            FlxFlicker.flicker(spr, 1.1, 0.1, true);
        }
        if(curSelected == 0){
            FlxTween.tween(spr, {alpha:0}, 1.5, {ease: FlxEase.expoOut});
            FlxTween.tween(selection, {alpha:0}, 1.5, {ease: FlxEase.expoOut});
        }
    });
    transitioningFromMainMenu = true;
}

var lockSpammed = 0;
var explosion:FunkinSprite;
function doExplosion(){
    explosion.visible = true;
    explosion.playAnim("anim",true);
    FlxG.sound.play(Paths.sound('explosion'));
    exploding = true;
}


function changeItem(huh:Int = 0,?mute:Bool = false,?mouse:Bool = false)
{
    lockSpammed = 0;
    if(transitioningFromMainMenu) return;
    if(!mouse) curSelected += huh;
    else curSelected = huh;
    if (curSelected < 0)
		curSelected = menuItems.length - 1;
	if (curSelected >= menuItems.length)
		curSelected = 0;

    if (!mute)
        CoolUtil.playMenuSFX(0, 0.7);

    menuItems.forEach(function(spr:FlxText)
    {
        if (spr.ID == curSelected)
        {
            selection.y = spr.y;
        }
    });
}

function createCoolText(textArray:Array<String>) {
    deleteCoolText();
	for (i => text in textArray) {
		if (text == "" || text == null)
			continue;
		var money:Alphabet = new Alphabet(0, (i * 60) + 200, text, true, false);
		money.screenCenter(FlxAxes.X);
		textGroup.add(money);
	}
}

function addMoreText(text:String) {
	var coolText:Alphabet = new Alphabet(0, (textGroup.length * 60) + 200, text, true, false);
	coolText.screenCenter(FlxAxes.X);
	textGroup.add(coolText);
}

function deleteCoolText() {
	while (textGroup.members.length > 0) {
		textGroup.members[0].destroy();
		textGroup.remove(textGroup.members[0], true);
	}
}

// ---- 节拍缩放无条件执行，文字动画只在 intro 阶段执行 ----
function beatHit(curBeat:Int) {
    // 无论什么阶段，都执行节拍缩放
    if (curBeat % 2 == 1)
        logo.scale.set(0.35*defaultScale, 0.35*defaultScale);

    // 如果已经跳过 intro，则不再执行下面的文字动画
    if (skippedIntro) return;
	switch (curBeat) {
		case 1:
			createCoolText(['Drunk Rat Studios']);
		case 2:
			addMoreText('presents');
		case 4:
			createCoolText(['Not associated']);
            addMoreText('with');
		case 6:
            disneySpr.visible = true;
		case 8:
			createCoolText([curWacky[0]]);
            disneySpr.visible = false;
		case 10:
			addMoreText(curWacky[1]);
		case 12:
            deleteCoolText();
			skipIntro();
			FlxTween.tween(FlxG.camera, {zoom: 1.1}, 2, {ease: FlxEase.expoOut, type: FlxTween.BACKWARD});
	}
}

var skippedIntro:Bool = false;
function skipIntro() {
	if (!skippedIntro) {
        for (i in [clubhouse, logo, beginText]) {
            FlxTween.tween(i, {alpha:1}, 1, {ease: FlxEase.quadInOut});
        }

        var targetY = logo.y;
        logo.y -= 700;
        logo.scale.set(0.25 * defaultScale, 0.25* defaultScale);

        // 使用统一的动画参数（时长和缓动）
        FlxTween.tween(logo, {y: targetY, "scale.x": 0.325*defaultScale, "scale.y": 0.325*defaultScale}, logoTransitionDuration, {
            ease: logoTransitionEase,
            onComplete: () -> {
                introAnimationComplete = true;  // 标记动画完成
                FlxTween.tween(beginText, {alpha: 0.5}, 1, {ease: FlxEase.quadInOut, type: FlxTween.PINGPONG});
            }
        });

		remove(textGroup);
		skippedIntro = true;
	}
}

public function getIntroTextShit():Array<Array<String>>
{
    var fullText:String = Assets.getText(Paths.txt('titlescreen/introText'));

    var firstArray:Array<String> = fullText.split('\n');
    var swagGoodArray:Array<Array<String>> = [];

    for (i in firstArray)
    {
        swagGoodArray.push(i.split('--'));
    }

    return swagGoodArray;
}
var isInMainMenu = false;

public function goToStoryMode(){
    pressedEnter = transitioning = true;
    FlxTween.tween(lock, {alpha: 0}, 1, {ease: FlxEase.quadOut});

    for(i in 0...trophyGroup.length){
        FlxTween.tween(trophyGroup.members[i], {alpha: 0}, 1, {ease: FlxEase.quadOut});
    }
    FlxTween.tween(versionText, {alpha: 0}, 1, {ease: FlxEase.quadOut});
    
    FlxG.sound.play(Paths.sound('gameOverEnd_M'));
    if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(2, 0);
    
    FlxG.camera.fade(0xFF000000, 4, false);

    FlxTween.tween(logo, {alpha: 0, "scale.x": 0.5 * defaultScale, "scale.y": 0.5 * defaultScale}, 1, {ease: FlxEase.expoIn});
    FlxTween.color(clubhouse, 4, 0xFF4A4E7A, 0xFFFFFFFF, {ease: FlxEase.quadInOut});
    
    FlxTween.tween(FlxG.camera, {zoom: 5}, 4, {ease: FlxEase.expoIn});

    new FlxTimer().start(4.5, function(tmr:FlxTimer) {
        PlayState.loadWeek(episode1, "Normal");
        FlxG.switchState(new PlayState());
    });
}

var optionShit:Array<String> = ["Play Episode","Freeplay","Options","Credits"];
var selection:FlxText;
static var firstTimeIn:Bool = true;
var canSelect = true;

importScript("data/scripts/mainmenushit");

public function moveToMainMenu(){
    createMainMenu();
    FlxG.mouse.visible = true;
    isInMainMenu = transitioning = skippedIntro = true;
    defaultScale = 0.7;
    FlxTween.cancelTweensOf(beginText);
    beginText.alpha = 0;
    for (i in [clubhouse, logo]) i.alpha = 1;
    remove(textGroup);
    clubhouse.color = 0xFF4A4E7A;
    logo.setPosition(-650,-550);

    menuItems = new FlxTypedGroup<FlxText>();
    add(menuItems);

    for (i=>option in optionShit)
    {
        var menuItem = new FlxText(100, 300 + (i * 60));
        menuItem.text = option;
        menuItem.setFormat(Paths.font("WickedMouse.ttf"), 28, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
        menuItem.borderSize = 2;
        menuItem.ID = i;
        menuItems.add(menuItem);
        menuItem.scrollFactor.set();
        menuItem.antialiasing = Options.antialiasing;
    }

    lock = new FunkinSprite();
    lock.loadGraphic(Paths.image(dir + 'lock'));
    lock.scale.set(0.5,0.5);
    lock.antialiasing = Options.antialiasing;
    lock.visible = (!FlxG.save.data.freeplay);
    add(lock);

    explosion = new FunkinSprite();
    explosion.loadSprite(Paths.image(dir + 'explosion'));
    explosion.addAnim("anim","explosion",24,false);
    explosion.animation.callback = () -> {
        if(explosion.animation.curAnim.curFrame == 10){
            lock.visible = false;
            FlxG.save.data.freeplay = true;
        }
    }
    add(explosion);
    explosion.scale.set(1.2,1.2);
    explosion.visible = false;

    selection = new FlxText(50, 300, 0, "V", 32);
    selection.setFormat(Paths.font("WickedMouse.ttf"), 28, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
    selection.borderSize = 2;
    selection.angle = -90;
    add(selection);
    FlxTween.tween(selection, {x:40}, 1, {ease: FlxEase.quadInOut, type: FlxTween.PINGPONG});

    if(!firstTimeIn) return;
    canSelect = false;
    selection.alpha = 0;
    for (i in 0...menuItems.length){
        menuItems.members[i].x -= 400;
        new FlxTimer().start(0.1 * i, () -> {
            FlxTween.tween(menuItems.members[i], {x:100}, 0.5, {ease: FlxEase.quartOut, onComplete: () -> {
                if(i == 0){
                    FlxTween.tween(selection, {alpha:1}, 0.5, {ease: FlxEase.quadInOut});
                } else if (i == 3){
                    canSelect = true;
                }
            }});
        });
    }
    firstTimeIn = false;

}