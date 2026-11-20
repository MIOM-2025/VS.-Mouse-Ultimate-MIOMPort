if (PlayState.variation != null) {
	trace('Old Version of Song! Removing Special Events...');
	disableScript();
	return;
}
import hxvlc.flixel.FlxVideoSprite;
import openfl.display.BlendMode;

var hue = new CustomShader('hsv');
var overlayShader = new CustomShader("overlay");
var vivid = new CustomShader("vividlight");
var linear = new CustomShader("lineardodge");
public var camVideos:FlxCamera;

function create() {
    if (!FlxG.save.data.overlay || Options.lowMemoryMode) {
        disableScript();
        return;
    }

	camVideos = new FlxCamera();
	camVideos.bgColor = 0x00000000;
	camVideos.alpha = 0;
	FlxG.cameras.remove(camHUD, false);
	FlxG.cameras.add(camVideos, false);
	FlxG.cameras.add(camHUD, false);

	video = new FlxVideoSprite(0, 0);
	video.load(Assets.getPath(Paths.video('loop1')), [':input-repeat=65535']);
	video.antialiasing = Options.antialiasing;
	video.play();
	video.cameras = [camVideos];
	video.blend = 9; // 0, 2, 8, 9, 12, 14
	video.alpha = 0.7;
	// video.x -=300;
	// video.y -= 100;

	insert(1, video);

	video3 = new FlxVideoSprite(0, 0);
	video3.load(Assets.getPath(Paths.video('loop3')), [':input-repeat=65535']);
	video3.antialiasing = Options.antialiasing;
	video3.play();
	video3.cameras = [camVideos];
	video3.blend = 9;
	video3.alpha = 0;
	// video3.x -=300;
	// video3.y -= 100;
	insert(2, video3);

	video2 = new FlxVideoSprite(0, 0);
	video2.load(Assets.getPath(Paths.video('loop2')), [':input-repeat=65535']);
	video2.antialiasing = Options.antialiasing;
	video2.play();
	if(Options.gameplayShaders) video2.shader = linear;
	video2.cameras = [camVideos];
	video2.blend = 12;
	video2.alpha = 1;
	// video2.x -=100;
	// video2.y -= 100;
	insert(3, video2);

    for (vid in [video, video3, video2]){
        // Fit as soon as the decoder reports the real frame size, then keep it
        // fitted every frame (see update()) so a late format change can't leave gaps.
        fitVideo(vid);
        if (vid.bitmap != null) vid.bitmap.onFormatSetup.add(function() fitVideo(vid));
    }


	var prevAutoPause:Bool = FlxG.autoPause;
	FlxG.autoPause = false;

	FlxG.autoPause = prevAutoPause;
	if (FlxG.autoPause) {
		for (video in [video, video2, video3])
			if (!FlxG.signals.focusLost.has(video.pause))
				FlxG.signals.focusLost.add(video.pause);

		if (!FlxG.signals.focusGained.has(focusGained))
			FlxG.signals.focusGained.add(focusGained);
	}
}

function beatHit() {
	switch (curBeat) {
		case 112:
			FlxTween.tween(camVideos, {alpha: 1}, 0.5, {ease: FlxEase.quartOut});
		case 144:
			FlxTween.tween(video, {alpha: 0}, 0.5, {ease: FlxEase.quartOut});
		case 176:
			FlxTween.tween(video3, {alpha: 0.6}, 0.5, {ease: FlxEase.quartOut});
		case 206:
			FlxTween.tween(video3, {alpha: 0},(Conductor.crochet/1000) * 1.5);
		case 240:
			FlxTween.tween(video2, {alpha: 0}, 0.00001, {ease: FlxEase.quartOut});
	}

	// trace("test");
}

function fitVideo(vid) {
	if (vid == null || vid.bitmap == null) return;
	var vw:Float = vid.bitmap.width;
	var vh:Float = vid.bitmap.height;
	if (vw <= 0 || vh <= 0) return;
	var s:Float = Math.max(FlxG.width / vw, FlxG.height / vh);
	vid.scale.set(s, s);
	vid.updateHitbox();
	vid.screenCenter();
}

function update() {
	// Real-time fullscreen: keep every video layer covering the screen.
	for (v in [video, video2, video3]) fitVideo(v);
	if (!Options.gameplayShaders) return;
	var on:Bool = camVideos.alpha == 1;
	for (v in [video, video2, video3]) {
		if (v != null) v.shader = on ? linear : null;
	}
}

function onSubstateOpen(event) {
	for (video in [video, video2, video3])
		if (paused) {
			video.pause();
			//camVideos.alpha = 0;
		}
}

function onSubstateClose(event) {
	for (video in [video, video2, video3]) {
		if (paused) {
			video.resume();
			//camVideos.alpha = 1;
		}
	}
}

function focusGained() {
	for (video in [video, video2, video3]) {
		if (!paused) {
			video.resume();
		} else {
			video.pause();
		}
	}
}
