import flixel.text.FlxText.FlxTextBorderStyle as Border;
import flixel.text.FlxText.FlxTextAlign as Align;
import flixel.addons.display.FlxBackdrop;
import funkin.backend.Conductor;
import funkin.menus.PauseSubState;
import funkin.game.PlayState;
import flixel.text.FlxTextBorderStyle;
import openfl.display.BlendMode;

var grey = new CustomShader('greyscale');
var songName = PlayState.SONG.meta.name;
var isVehement:Bool = false;

var dadRender:FunkinSprite = null;
var boyfriendRender:FunkinSprite = null;
var infoTexts:Array<FunkinText> = [];
var boardTargetScale:Float = 1;
var infoData;

// 鼠标交互变量（与第二段代码一致）
var selectedIndex:Int = 0;          // 当前选中的选项索引
var mousePressIndex:Int = -1;       // 按下时悬停的选项索引
var hasSwitchedDuringPress:Bool = false; // 按住期间是否切换过选中项

var textCam:FlxCamera;
var board:FlxSprite;
var grpText:FlxGroup;

function create(e) {
    #if mobile	
    try { removeTouchPad(); } catch (e:Dynamic) { try { removeMobilePad(); } catch (e:Dynamic) { try { removeButton(); removeDPad();} catch (e:Dynamic) { } } }
    #end
    grey.strength = 0;
    for (poo in FlxG.cameras.list) poo.addShader(grey);
    isVehement = (songName.toLowerCase() == 'vehement'); 

    grpText = new FlxGroup();
    textCam = new FlxCamera();
    textCam.bgColor = 0;
    e.music = "breakfast";

    add(checker = new FlxBackdrop(Paths.image('pause/altChecker'))).alpha = 0;
    checker.velocity.set(-40, -40);
    checker.screenCenter(FlxAxes.X);

    for (char in ["dad", "boyfriend"]) {
        var path = "pause/" + songName + "/" + char;
        if (!Assets.exists(Paths.image(path))) continue;

        var render = new FunkinSprite().loadGraphic(Paths.image(path));
        render.antialiasing = Options.antialiasing;
        render.setGraphicSize(FlxG.width);
        render.updateHitbox();
        render.screenCenter();
        
        render.y += 500; 
        render.alpha = 0;
        if (char == "dad") render.x += 25;

        render.cameras = [textCam];
        add(render);

        if (char == "dad") dadRender = render; else boyfriendRender = render;
    }

    var boardH = (menuItems.length * 56) + 40; 
    board = new FunkinSprite(isVehement ? 50 : 0, 210).makeSolid(400, boardH, FlxColor.WHITE);
    board.camera = textCam;
    
    board.alpha = 0;
    boardTargetScale = board.scale.y; 
    board.scale.y = 0;

    if (!isVehement) board.screenCenter(0x01);
    add(board);

    var i:Float = 2;
    for(e in menuItems) {
        var text = new FlxText(0, 120 + (i * 56), 0, e, 8);
        text.setFormat(Paths.font("WickedMouse.ttf"), 32, FlxColor.WHITE, "center", FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        text.borderSize = 2;
        text.camera = textCam;
        if (isVehement) 
            text.x = board.x + (board.width / 2) - (text.width / 2);
        else 
            text.screenCenter(0x01);
        grpText.add(text);
        i++;
    }

    infoData = [
        {t: songName + (PlayState.difficulty == "LEGACY" ? " (Legacy)" : ""), y: 15, a: Align.LEFT, targetX: 20},
        {t: PlayState.SONG.meta.customValues?.composer, y: 55, a: Align.LEFT, targetX: 20},
        {t: "Blueballed: " + PlayState.deathCounter, y: 15, a: Align.RIGHT, targetX: -20}
    ];

    for (d in infoData) {
        var txt = new FunkinText(d.targetX > 0 ? -100 : 100, d.y, FlxG.width, d.t, 32);
        txt.setFormat(Paths.font("WickedMouse.ttf"), 24, FlxColor.WHITE, d.a, Border.OUTLINE, 0xFF000000);
        txt.borderSize = 2;
        txt.alpha = 0;
        txt.cameras = [textCam];
        add(txt);
        txt.wordWrap = false; 
        infoTexts.push(txt);
    }

    add(grpText);

    // 初始化选中项
    selectedIndex = 0;
    updateSelectionVisuals();
}

function update(elapsed:Float) {
    #if mobile	
    try { removeTouchPad(); } catch (e:Dynamic) { try { removeMobilePad(); } catch (e:Dynamic) { try { removeButton(); removeDPad();} catch (e:Dynamic) { } } }
    #end
    grey.strength = lerp(grey.strength, 1, 0.05);
    checker.alpha = lerp(checker.alpha, 0.5, 0.04);

    if (dadRender != null) {
        dadRender.y = lerp(dadRender.y, 62.5, 0.12);
        dadRender.alpha = lerp(dadRender.alpha, 1, 0.08);
        dadRender.x = lerp(dadRender.x, (FlxG.width / 2) - (dadRender.width / 2) - 100, 0.12);
    }
    if (boyfriendRender != null) {
        boyfriendRender.y = lerp(boyfriendRender.y, 62.5, 0.12);
        boyfriendRender.alpha = lerp(boyfriendRender.alpha, 1, 0.08);
        boyfriendRender.x = lerp(boyfriendRender.x, (FlxG.width / 2) - (boyfriendRender.width / 2) + 100, 0.12);
    }

    board.alpha = lerp(board.alpha, 0.5, 0.08);
    board.scale.y = lerp(board.scale.y, boardTargetScale, 0.08);

    for (i => txt in infoTexts) {
        txt.x = lerp(txt.x, infoData[i].targetX, 0.1);
        txt.alpha = lerp(txt.alpha, (i == 2 ? 0.7 : 1), 0.08);
    }

    pauseMusic.volume = lerp(pauseMusic.volume, 0.5, 0.02);

    // ========== 鼠标交互（修复后，与第二段代码逻辑一致） ==========
    var mousePoint = FlxG.mouse.getWorldPosition(textCam);
    var mouseOverIndex = -1;

    // 检测鼠标悬停的选项
    for (i in 0...grpText.members.length) {
        var item = grpText.members[i];
        if (item.visible &&
            mousePoint.x >= item.x && mousePoint.x <= item.x + item.width &&
            mousePoint.y >= item.y && mousePoint.y <= item.y + item.height) {
            mouseOverIndex = i;
            break;
        }
    }

    // 鼠标按下时记录
    if (FlxG.mouse.justPressed) {
        mousePressIndex = mouseOverIndex;
        hasSwitchedDuringPress = false;
    }

    // 按住期间允许拖动切换选中项
    if (FlxG.mouse.pressed) {
        if (mouseOverIndex != -1 && mouseOverIndex != selectedIndex) {
            selectedIndex = mouseOverIndex;
            updateSelectionVisuals();
            FlxG.sound.play(Paths.sound("menu/pauseScroll"), 0.5);
            hasSwitchedDuringPress = true;
        }
    }

    // 鼠标释放：只有未切换过且按下时有悬停项才触发选择
    if (FlxG.mouse.justReleased) {
        if (!hasSwitchedDuringPress && mousePressIndex != -1) {
            // ★ 关键修复：设置当前选中项，并调用原版选择逻辑
            curSelected = mousePressIndex;
            selectOption();  // 原版暂停菜单的选择处理，能正确处理所有选项
        }
        mousePressIndex = -1;
        hasSwitchedDuringPress = false;
    }
}

function updateSelectionVisuals() {
    for (i in 0...grpText.members.length) {
        var item = grpText.members[i];
        if (i == selectedIndex) {
            item.color = 0xFFFFE066; // 淡黄色高亮
        } else {
            item.color = FlxColor.WHITE;
        }
    }
}

// 注意：我们不再需要自定义 selectItem 函数，因为原版 selectOption 已处理所有选项

function destroy() {
    for (poo in FlxG.cameras.list) poo.removeShader(grey);
    FlxG.cameras.remove(textCam, false);
}

function postCreate() {
    FlxG.cameras.add(textCam, false);
    grpMenuShit.visible = false;
    for (label in [levelInfo, levelDifficulty, deathCounter, multiplayerText]) {
        if (label != null) label.visible = false;
    }
}