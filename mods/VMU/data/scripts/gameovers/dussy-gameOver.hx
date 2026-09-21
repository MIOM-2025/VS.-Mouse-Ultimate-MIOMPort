import hxvlc.flixel.FlxVideoSprite;
import openfl.system.Capabilities;

var video:FlxVideoSprite = new FlxVideoSprite();

function create(e) {
    e.cancel();

    camDeath = new FlxCamera();
    camDeath.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(camDeath, false);
    
    video.load(Assets.getPath(Paths.file('videos/dussy.mp4')));
    video.antialiasing = Options.antialiasing;
    video.scale.set(1.25, 1.25);
    video.cameras = [camDeath];
    video.screenCenter();
    video.x -= 500;
    video.y -= 200;
    video.play();
    add(video);

    video.bitmap.onEndReached.add(() -> Sys.exit(0)); 
    setGameResolution(615, 830);
}

function update(elapsed:Float) if (controls.ACCEPT) FlxG.switchState(new PlayState());
function setGameResolution(newWidth, newHeight) {
	FlxG.resizeWindow(newWidth, newHeight);
	try{
	        FlxG.scaleMode.width = FlxG.initialWidth = FlxG.width = newWidth;
	        FlxG.scaleMode.height = FlxG.initialHeight = FlxG.height = newHeight;
        } catch (e:Dynamic) { }
	window.x = Std.int(Capabilities.screenResolutionX / 2 - window.width / 2);
	window.y = Std.int(Capabilities.screenResolutionY / 2 - window.height / 2);
}
function destroy() setGameResolution(1280, 720);
