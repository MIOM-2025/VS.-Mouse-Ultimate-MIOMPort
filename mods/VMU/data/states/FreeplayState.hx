import funkin.backend.utils.DiscordUtil;
import funkin.savedata.FunkinSave;
import funkin.backend.chart.Chart;
import funkin.backend.utils.CoolUtil;
import flixel.text.FlxTextBorderStyle;

var scrollSpeed:Float = 50; 
var singleWidth:Float = 0;

// 鼠标拖拽相关变量
var isDragging:Bool = false;
var dragStartY:Float = 0;
var dragStartSelected:Int = 0;
var dragThreshold:Float = 5;
var dragSensitivity:Float = 0.018;
var mousePressPos:FlxPoint = FlxPoint.get();
var clickedOnOption:Bool = false;
var clickedOptionIndex:Int = -1;

// Back 按钮相关
var backButton:FlxText;
var backCam:FlxCamera;
var pendingBack:Bool = false;
var mouseOverBack:Bool = false;

function create() {
    #if mobile	
    try { removeTouchPad(); } catch (e:Dynamic) { try { removeMobilePad(); } catch (e:Dynamic) { try { removeButton(); removeDPad();} catch (e:Dynamic) { } } }
    #end

    if(FunkinSave.getSongHighscore("Dussy", "Normal").score > 0){
        songList.songs.push(Chart.loadChartMeta("Dussy"));
        songs = songList.songs;
    }
}

var startingChar:Int = 0;
var questions:FlxGroup<Alphabet>;
function postCreate() {
    questions = new FlxGroup();
    add(questions);

    for(i in 0... songs.length) {
        var question = new Alphabet(0, 0, '?', 'bold');
        questions.add(question);
        questions.members[i].visible = false;
        if(FunkinSave.getSongHighscore(songs[i].name, "Normal").score <= 0)
        {
            trace(songs[i].name);
            iconArray[i].color = FlxColor.BLACK;
            var question = new Alphabet(0, 0, '?', 'bold');
            grpSongs.members[i].color = FlxColor.GRAY;
            new FlxTimer().start(0.3, () -> {
                grpSongs.members[i].text = shuffleName(grpSongs.members[i].text);
            },0);
        }
    }

    bottomBar = new FlxSprite(0, FlxG.height - 30).makeGraphic(FlxG.width, 50, 0xFF000000);
    bottomBar.scrollFactor.set();
    bottomBar.alpha = 0.5;
    add(bottomBar);

    // 英文滚动提示
    var displayString:String = "Click the top-right corner to cycle difficulties and play Legacy versions!     ";

    testText = new FlxText(0, bottomBar.y, 0, displayString + displayString + displayString, 24);
    testText.setFormat(Paths.font("CreatoDisplay-ExtraBold.otf"), 24, 0xFFFFFFFF, "left");
    testText.scrollFactor.set();
    testText.alpha = 0.5;
    add(testText);

    singleWidth = testText.width / 3;

    // 创建 Back 按钮（左下角）
    backButton = new FlxText(15, FlxG.height - 100, 0, "Back", 48);
    backButton.setFormat(Paths.font("WickedMouse.ttf"), 48, FlxColor.WHITE, "left");
    backButton.antialiasing = Options.antialiasing;
    backButton.borderStyle = FlxTextBorderStyle.OUTLINE;
    backButton.borderColor = FlxColor.BLACK;
    backButton.borderSize = 3;

    // 创建独立摄像机，不缩放、不滚动
    backCam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
    backCam.bgColor = FlxColor.TRANSPARENT;
    backCam.zoom = 1;
    backCam.scroll.set(0, 0);
    FlxG.cameras.add(backCam);

    backButton.cameras = [backCam];
    add(backButton);

    timeUntilAutoplay = 5;
    DiscordUtil.changePresence("Freeplay Menu");
    CoolUtil.playMusic(Paths.music('freeplay'), false, 0.5, true, 80);
}

function shuffleName(text:String){
    nameChars = text.split("");
    for(i in 0...nameChars.length){
        var j = FlxG.random.int(0,nameChars.length-1);
        var temp = nameChars[i];
        nameChars[i] = nameChars[j];
        nameChars[j] = temp;
    }
    return nameChars.join("");
}

function onChangeDiff(e){
    if (hasSelected) e.cancel();
}

function onChangeSelection(event) {
    if (hasSelected) {
        event.cancel();
        return;
    }
    if (songInstPlaying) {
        CoolUtil.playMusic(Paths.music('freeplay'), false, 0, true, 80);
        FlxG.sound.music.fadeIn(0.5, 0, 0.5);
        songInstPlaying = false;
    }
    autoplayElapsed = 0;
}

function update(elapsed:Float) {
    #if mobile	
    try { removeTouchPad(); } catch (e:Dynamic) { try { removeMobilePad(); } catch (e:Dynamic) { try { removeButton(); removeDPad();} catch (e:Dynamic) { } } }
    #end

    FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, 0.025);
    testText.x -= scrollSpeed * elapsed;
    if (testText.x <= -singleWidth) testText.x = 0;

    if (hasSelected) return;
    autoplayElapsed += elapsed; 
    if (!songInstPlaying && !disableAutoPlay && autoplayElapsed > (timeUntilAutoplay - 0.5)) {
        if (FlxG.sound.music != null && FlxG.sound.music.volume > 0) {
            FlxG.sound.music.fadeOut(0.5, 0);
        }
    }

    // 更新 Back 按钮颜色（悬停变蓝，否则白色黑边）
    var backMousePos = FlxG.mouse.getWorldPosition(backCam);
    mouseOverBack = backButton.overlapsPoint(backMousePos);
    backButton.color = mouseOverBack ? FlxColor.BLUE : FlxColor.WHITE;

    // ========== 鼠标交互逻辑 ==========
    var wheel = FlxG.mouse.wheel;
    if (wheel != 0 && !hasSelected) {
        var shift = -wheel;
        var ns = FlxMath.bound(curSelected + shift, 0, songs.length - 1);
        if (ns != curSelected) {
            changeSelection(ns - curSelected);  // 修复：调用完整切换
        }
    }

    if (FlxG.mouse.justPressed && !hasSelected) {
        if (mouseOverBack) {
            pendingBack = true;
        }
        else if (FlxG.mouse.screenX >= FlxG.width - 300 && FlxG.mouse.screenY <= 50) {
            changeDiff(1);
        }
        else {
            mousePressPos.set(FlxG.mouse.screenX, FlxG.mouse.screenY);
            isDragging = true;
            dragStartY = FlxG.mouse.screenY;
            dragStartSelected = curSelected;

            clickedOnOption = false;
            clickedOptionIndex = -1;
            for (i in 0...grpSongs.members.length) {
                if (FlxG.mouse.overlaps(grpSongs.members[i])) {
                    clickedOnOption = true;
                    clickedOptionIndex = i;
                    break;
                }
            }
            if (clickedOnOption && clickedOptionIndex != curSelected) {
                changeSelection(clickedOptionIndex - curSelected);  // 修复：调用完整切换
            }
        }
    }

    if (isDragging && FlxG.mouse.pressed && !hasSelected) {
        var delta = FlxG.mouse.screenY - dragStartY;
        var ns = FlxMath.bound(dragStartSelected - Math.round(delta * dragSensitivity), 0, songs.length - 1);
        if (ns != curSelected) {
            changeSelection(ns - curSelected);  // 修复：调用完整切换
        }
    }

    if (FlxG.mouse.justReleased && !hasSelected) {
        if (pendingBack) {
            if (mouseOverBack) goBack();
            pendingBack = false;
        }

        if (isDragging) {
            var delta = FlxG.mouse.screenY - dragStartY;
            var isClick = Math.abs(delta) <= dragThreshold;
            if (isClick) {
                if (clickedOnOption) {
                    if (clickedOptionIndex == curSelected) {
                        select();
                    } else {
                        if (curSelected != clickedOptionIndex) {
                            changeSelection(clickedOptionIndex - curSelected);  // 修复：调用完整切换
                        }
                    }
                }
            }
            isDragging = false;
            clickedOnOption = false;
            clickedOptionIndex = -1;
        }
    }

    // 更新问号标记位置
    for(i in 0...songs.length) {
        if(FunkinSave.getSongHighscore(songs[i].name, "Normal").score <= 0){
            questions.members[i].visible = true;
            questions.members[i].setPosition(iconArray[i].x + 50, iconArray[i].y + 50);
            questions.members[i].alpha = grpSongs.members[i].alpha;
        }
    }
}

function goBack() {
    if (hasSelected) return;
    CoolUtil.playMenuSFX(2);
    FlxG.switchState(new MainMenuState());
}

function beatHit() {
    if (curBeat % 2 == 0) FlxG.camera.zoom += 0.015;
    if(curBeat == 20 && curSelected == 1) {
        var prevBPM = Conductor.curChange.bpm;
        var time = 11428.5714285714;
        Conductor.curChange = Conductor.mapBPMChange(Conductor.curChange, time, 120);
        Conductor.curChange.endSongTime = time + 64 / (Conductor.curChange.bpm - prevBPM) * Math.log(Conductor.curChange.bpm / prevBPM) * 15000;
        Conductor.curChange.endStepTime = Conductor.curChange.stepTime + 64;
        Conductor.curChange.continuous = true;
    }
}

var timerGone = false;
var hasSelected = false;
function onSelect(e){
    if(!timerGone) e.cancel();
    if(hasSelected) return;
    hasSelected = true;
    if(!timerGone) {
        if(iconArray[curSelected].animation.exists("selected"))
            iconArray[curSelected].animation.play("selected", true, "LOCK");
        else {
            timerGone = true;
            select();
            return;
        }
    }
    FlxG.sound.music.fadeOut(1.5, 0);
    if(!timerGone) CoolUtil.playMenuSFX(1);
    new FlxTimer().start(1.5, () -> {
        timerGone = true;
        select();
    });
}