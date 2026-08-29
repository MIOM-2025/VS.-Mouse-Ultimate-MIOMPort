import openfl.display.BlendMode;

if (Options.lowMemoryMode) disableScript();
if (PlayState.variation != null) {
    disableScript();
    return;
}

var starParticles:FlxTypedGroup;
var timeElapsed:Float = 0;
var starsEnabled:Bool = false;

graphicCache.cache(Paths.image('game/mickeyStar'));

function postCreate() {
    starParticles = new FlxTypedGroup();
    add(starParticles);
}

function beatHit(_:Int) {
    if (starsEnabled) {
        for (i in 0...10) {
            var star = starParticles.recycle(FlxSprite);
            star.loadGraphic(Paths.image('game/mickeyStar'));
            star.reset(FlxG.random.int(-500, 1500), -500);
            
            star.angle = FlxG.random.int(0, 180);
            star.scrollFactor.set(FlxG.random.float(0.3, 1.8), FlxG.random.float(0.3, 1.8));
            star.setGraphicSize(star.width * FlxG.random.float(0.3, 1.53));
            star.blend = BlendMode.ADD;
            star.alpha = 1;
            
            star.velocity.set(FlxG.random.float(-80, 140), 50 + FlxG.random.float(0, 500));
        }
    }
    switch(curBeat) {
        case 112, 176: starsEnabled = true;
        case 144, 208: starsEnabled = false;
    }
}
var elap;

function update(elapsed){
    elap = elapsed;
    starParticles.forEachAlive(function(star) {
        star.angle += FlxG.random.int(40, 80) * elap;
        star.velocity.x += FlxG.random.float(-10, 10) * elap;
        star.alpha -= 0.5 * elap;

        if (star.y > 1000 || star.alpha <= 0) star.kill();
    });
}