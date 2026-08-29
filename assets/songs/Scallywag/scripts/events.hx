function create() introLength = 1;
function postCreate()  FlxG.camera.fade(FlxColor.BLACK, 0.001, false);
function onCountdown(event) event.cancel();
function beatHit(curBeat:Int) {
    if (curBeat == 1) FlxG.camera.fade(0xFF000000, (Conductor.stepCrochet / 1000) * 4, true);
    if (curBeat == 3) FlxG.camera.fade(0xFF000000, 0.001, true);
}