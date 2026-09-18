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

// 鼠标交互变量
var hoveredIndex:Int = -1;          // 当前悬停的选项索引，-1 表示无悬停
var textCam:FlxCamera;              // 已在 create 中定义
var board:FlxSprite;
var grpText:FlxGroup;

function create(e) {
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
        text = new FlxText(0, 120 + (i * 56), 0, e, 8);
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
}

function update(elapsed:Float) {
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

    // ========== 鼠标交互（替代键盘选择） ==========
    var mousePos = FlxG.mouse.getScreenPosition(textCam);
    var newHover:Int = -1;

    // 遍历所有菜单项，检测鼠标悬停
    for (i in 0...grpText.members.length) {
        var item = grpText.members[i];
        if (item.visible && item.overlapsPoint(mousePos, false, textCam)) {
            newHover = i;
            break;
        }
    }

    // 更新悬停状态（高亮）
    if (newHover != hoveredIndex) {
        // 恢复旧悬停项颜色（如果有）
        if (hoveredIndex != -1 && hoveredIndex < grpText.members.length) {
            grpText.members[hoveredIndex].color = FlxColor.WHITE;
        }
        // 设置新悬停项颜色（淡黄色）
        if (newHover != -1) {
            grpText.members[newHover].color = 0xFFFFE066; // 淡黄
            // 播放悬停音效（可选）
            FlxG.sound.play(Paths.sound("menu/pauseScroll"), 0.5);
        }
        hoveredIndex = newHover;
    }

    // 鼠标松开时触发选择
    if (FlxG.mouse.justReleased && hoveredIndex != -1) {
        selectItem(hoveredIndex);
    }
}

// ========== 选项选择逻辑（根据选项文本执行动作） ==========
function selectItem(index:Int) {
    var optionText = menuItems[index];
    // 播放选择音效
    FlxG.sound.play(Paths.sound("menu/select"), 1);

    // 根据选项文本执行对应操作（可自行修改）
    switch (optionText.toLowerCase()) {
        case "resume", "continue":
            // 恢复游戏（关闭暂停子状态）
            close();
        case "restart", "retry":
            // 重新开始当前歌曲
            FlxG.resetState();
        case "options", "settings":
            // 打开选项菜单（示例，需根据实际实现调整）
            // 这里可以调用 FlxG.switchState(new OptionsMenuState()) 或打开子状态
            trace("Options selected");
        case "exit", "quit", "back":
            // 退出到自由选歌界面（或主菜单）
            FlxG.switchState(new FreeplayState());
        default:
            // 如果未匹配，则关闭（默认行为）
            close();
    }
}

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

// 注意：原 onChangeItem 函数已移除，因为键盘选择不再使用。
// 如需保留键盘支持，可自行添加，但会与“全白”要求冲突。