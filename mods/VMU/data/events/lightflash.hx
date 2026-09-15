import openfl.display.BlendMode;

var white:FlxSprite;
var whitecam:FlxCamera;

function onEvent(_){
    if (_.event.name == 'lightflash'){

        FlxG.cameras.add(whitecam = new FlxCamera(), false);
        whitecam.bgColor = 0x00000000;

        white = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
        white.cameras = [whitecam];
        white.blend = BlendMode.ADD;
        white.screenCenter(FlxAxes.XY);
        add(white);
        white.alpha = _.event.params[0];
        FlxTween.tween(white, {alpha: 0}, (_.event.params[1]), {ease:FlxEase.linear});	
    }
}