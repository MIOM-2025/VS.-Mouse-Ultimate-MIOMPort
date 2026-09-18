import funkin.backend.utils.DiscordUtil;
import funkin.savedata.FunkinSave;
import funkin.backend.chart.Chart;
import funkin.backend.utils.CoolUtil;

var scrollSpeed:Float = 50; 
var singleWidth:Float = 0;

function create() {
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
        //trace(songs[i].name);
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

    var displayString:String = "Change the difficulty to play the Legacy Versions of the respective songs!     ";

    testText = new FlxText(0, bottomBar.y, 0, displayString + displayString + displayString, 24);
    testText.setFormat(Paths.font("CreatoDisplay-ExtraBold.otf"), 24, 0xFFFFFFFF, "left");
    testText.scrollFactor.set();
    testText.alpha = 0.5;
    add(testText);

    singleWidth = testText.width / 3;

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
    //if (hasSelected) return;
    if (songInstPlaying) {
        CoolUtil.playMusic(Paths.music('freeplay'), false, 0, true, 80);
        FlxG.sound.music.fadeIn(0.5, 0, 0.5);
        songInstPlaying = false;
    }
    autoplayElapsed = 0;
}

function update(elapsed:Float) {
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
    for(i in 0...songs.length) {
        if(FunkinSave.getSongHighscore(songs[i].name, "Normal").score <= 0){
            questions.members[i].visible = true;
            questions.members[i].setPosition(iconArray[i].x + 50,iconArray[i].y + 50);
            questions.members[i].alpha = grpSongs.members[i].alpha;
        }
        iconArray[i].scale.set(lerp(iconArray[i].scale.x, (i == 1 ? 0.6 : 1), 0.1),lerp(iconArray[i].scale.y, (i == 1 ? 0.6 : 1), 0.1));
    }
    if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(grpSongs.members[curSelected])) {
        select();
    }

}

function beatHit() {
    if (curBeat % 2 == 0) FlxG.camera.zoom += 0.015;
    for(i in 0... songs.length) {
        iconArray[i].scale.set(1.05 * (i == 1 ? 0.6 : 1),1.05 * (i == 1 ? 0.6 : 1));
    }
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