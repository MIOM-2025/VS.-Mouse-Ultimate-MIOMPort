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
    introVid.cameras = [camGame];
    introVid.antialiasing = Options.antialiasing;
    introVid.alpha = 0;
    // Draw the intro movie behind the characters instead of on top of them.
    insert(0, introVid);

	video.load(Assets.getPath(Paths.video('loop1')), [':input-repeat=65535']);
	video.antialiasing = Options.antialiasing;
    video.scrollFactor.set();
	video.cameras = [camHUD];
	video.blend = 9;
	video.alpha = 0;
    insert(0, video);

    FlxTween.tween(introVid, {alpha: 1}, 0.5, {ease: FlxEase.quartOut});
}

function beatHit(curBeat:Int) {
    switch(curBeat) {
        case 98: FlxTween.tween(introVid, {alpha: 0}, 2, {ease: FlxEase.quartOut});
        case 100: remove(introVid);
        case 372:
            FlxTween.tween(video, {alpha: 0.7}, 2, {ease: FlxEase.quartOut});
            video.play();
        case 436:
            FlxTween.tween(video, {alpha: 0}, 2, {ease: FlxEase.quartOut});
        case 444:
            remove(video);
    }
}

function onSubstateOpen() for (i in [introVid, video]) i.pause();
function onSubstateOpen() if (paused) for (i in [introVid, video]) i.pause();
function onSubstateClose() if (paused) for (i in [introVid, video]) i.resume();
function onFocus() if (!paused && FlxG.autoPause) for (i in [introVid, video]) i.resume();
function onFocusLost() if (!paused && FlxG.autoPause) for (i in [introVid, video]) i.pause();
function fitVideo(vid) {
    if (vid == null || vid.bitmap == null) return;
    var vw:Float = vid.bitmap.width, vh:Float = vid.bitmap.height;
    if (vw <= 0 || vh <= 0) return;
    var s:Float = Math.max(FlxG.width / vw, FlxG.height / vh);
    vid.scale.set(s, s);
    vid.updateHitbox();
    vid.screenCenter();
}

function postUpdate() {
    fitVideo(introVid);
    fitVideo(video);
    if (Conductor.songPosition < 0) for (i in [introVid, video]) i.bitmap.time = 0;
}