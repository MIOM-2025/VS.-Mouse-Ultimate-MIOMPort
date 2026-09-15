import hxvlc.flixel.FlxVideoSprite;

var camVideo:FlxCamera = new FlxCamera();
var introVid:FlxVideoSprite = new FlxVideoSprite();
var video:FlxVideoSprite = new FlxVideoSprite();

if(PlayState.variation != null){
    disableScript();
    return;
}

function create() {
    if (!FlxG.save.data.overlay) {
        disableScript();
        return;
    }
}

function postCreate() {
    introVid.load(Assets.getPath(Paths.file('videos/crisisCutsceneWip.mp4')));
    introVid.play();
    introVid.scrollFactor.set();
    introVid.cameras = [camVideo];
    introVid.antialiasing = Options.antialiasing;
    introVid.x = -300; introVid.y = -180;
    introVid.alpha = 0;
    introVid.scale.set(0.675, 0.675);
    add(introVid);

	video.load(Assets.getPath(Paths.video('loop1')), [':input-repeat=65535']);
	video.antialiasing = Options.antialiasing;
    video.scrollFactor.set();
	video.cameras = [camHUD];
	video.blend = 9;
	video.alpha = 0;
    video.scale.set(2.1, 2.1);
    video.screenCenter();
    video.x -= 350;
    video.y -= 200;
    insert(0, video);

    camVideo.bgColor = 0xFF000000;
    FlxG.cameras.remove(camHUD, false);
    FlxG.cameras.add(camHUD, false);
    FlxG.cameras.add(camVideo, false);
    
    FlxTween.tween(introVid, {alpha: 1}, 0.5, {ease: FlxEase.quartOut});
}

function beatHit(curBeat:Int) {
    switch(curBeat) {
        case 98: FlxTween.tween(camVideo, {alpha: 0}, 2, {ease: FlxEase.quartOut});
        case 100: camVideo.visible = false; remove(introVid);
        case 372:
            FlxTween.tween(video, {alpha: 0.7}, 2, {ease: FlxEase.quartOut});
            camVideo.bgColor = 0;
            camVideo.visible = true;
            video.play();
        case 436:
            FlxTween.tween(video, {alpha: 0}, 2, {ease: FlxEase.quartOut});
        case 444:
            FlxG.cameras.remove(camVideo, false);
            camVideo.visible = false;
            remove(video);
    }
}

function onSubstateOpen() for (i in [introVid, video]) i.pause();
function onSubstateOpen() if (paused) for (i in [introVid, video]) i.pause();
function onSubstateClose() if (paused) for (i in [introVid, video]) i.resume();
function onFocus() if (!paused && FlxG.autoPause) for (i in [introVid, video]) i.resume();
function onFocusLost() if (!paused && FlxG.autoPause) for (i in [introVid, video]) i.pause();
function postUpdate()
    if (Conductor.songPosition < 0) for (i in [introVid, video]) i.bitmap.time = 0;