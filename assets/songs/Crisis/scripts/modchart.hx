if(PlayState.variation != null){
    disableScript();
    return;
}

import modchart.Manager;
import modchart.engine.PlayField;
import flixel.tweens.FlxTweenType;

function create() {
    if (!FlxG.save.data.modcharts) {
        disableScript();
        return;
    }
}

function numericForInterval(start, end, interval, func){
    var index = start;
    while(index < end){
        func(index);
        index += interval;
    }
}

var originalPositions:Array<Float> = [];

function postCreate() {
    manager = new Manager();
    state.add(manager);

    p = manager.playfields[0];

    for (strum in cpuStrums) originalPositions.push(strum.x);
    for (strum in playerStrums) originalPositions.push(strum.x);

    loadModchart();

    var poop = 1;

    var counter = -1;
    numericForInterval(212, 244, 1, (s)->{
        counter *= -1;

        p.set("TipsyY", s, 0.75 * counter);
        p.ease("TipsyY", s, 1, 0, FlxEase.quartOut);
        p.set("DrunkX", s, 1.25 * counter);
        p.ease("DrunkX", s, 1, 0, FlxEase.quartOut);
    });

    p.ease("Beat", 212, 1, 0.25, FlxEase.backInOut);
    p.ease("OpponentSwap", 212, 1, 0.5, FlxEase.backInOut);

    p.ease("localrotateY", 212, 1.3, 720, FlxEase.quartOut);

    p.ease("OpponentSwap", 212, 5, 0, FlxEase.cubeOut);
}

var cpuAlpha:Float = 0;

function beatHit(curBeat:Int) {
    if (curBeat == 252) {
        cpuAlpha = 0.5;
        cpuStrums.forEach(function(spr) {
            spr.visible = true;
            FlxTween.tween(spr, {alpha: cpuAlpha}, 0.5, {ease: FlxEase.quartOut});
        });
    }

    if (curBeat == 260) {
        cpuAlpha = 0;
        cpuStrums.forEach(function(spr) {
            FlxTween.tween(spr, {alpha: 0}, 0.5, {ease: FlxEase.quartOut, onComplete: function() {spr.visible = false;}});
        });
    }
}

function loadModchart() {
    p.addModifier("Transform"); // doesn't work
    p.addModifier("OpponentSwap"); // sends the notes in the opponent's place
    p.addModifier("Stealth"); // self-explanatory, notes are invisible in a way; white and ghost-ish
    p.addModifier("Radionic"); // rotates the notes in a circle basically, kind of like a biscuit formular way and their outline bounces too idk
    p.addModifier("Confusion"); // rotates each note infinitely, 360 degrees
    p.addModifier("Drunk"); // moves the notes in a drunk-like way, fun if you want to make the notes feel more real
    p.addModifier("Tipsy"); // moves the notes up and down (each note separately, used in popular fnf mods)
    p.addModifier("Tornado"); // doesn't work
    p.addModifier("LocalRotate"); // doesn't work(?)
    p.addModifier("CenterRotate"); // doesn't work(?)
    p.addModifier("Zoom"); // self-explanatory, zooms in or out the strum of notes
    p.addModifier("Scale"); // similar to zoom, but instead scales the strum of notes
    p.addModifier("ArrowShape"); // works, but don't recommend using since it crashes the game LOL but it moves your whole notes down and makes weird shapes idk
    p.addModifier("Reverse"); // moves the whole strum notes to a place, 1 for downscroll, 0.5 for middlescroll etc. (also used in popular fnf mods)
    p.addModifier("Skew"); // self-explanatory, skews the notes but doesn't work on my end
    p.addModifier("ReceptorScroll"); // moves the notes up and down, 0 > 1 depending how far it is or not (whole strum of notes)
    p.addModifier("Beat"); // moves the notes left and right, beathit type
    p.addModifier("Zigzag"); // self-explanatory, moves the notes that fall in a zigzag-like way
    p.addModifier("Bumpy"); // the notes that fall in have a cool little scale, 3D-ish in a way
    p.addModifier("Bounce"); // self-explanatory, bounces the notes (including the ones that fall in)
    p.addModifier("Drugged"); // drug-like notes, awesome effects for the notes if you want something rave(y) or for a flickering effect
    p.addModifier("Infinite"); // self-explanatory, strum notes are placed in one place and the falling notes create a infinite symbol
    p.addModifier("Square"); // doesn't work on my end, but similar to infinite i think
    p.addModifier("Invert"); // inverts (not color!!!) ONLY the strum notes, thats about it; confusing
    p.addModifier("SchmovinTornado"); // the notes that fall in are in a tornado-like way, nothing much
    p.addModifier("Wiggle"); // self-explanatory, wiggles the notes (WHY IS THIS IN A false_paradise CATEGORY???)
    p.addModifier("EyeShape"); // similarly to the infinite symbol, except you cant see the strum notes this time
    p.addModifier("Spiral"); // similar to the past few ones, love this one; looks like a galaxy of notes!
    p.addModifier("Vibrate"); // this is just radionic 0.5 i think, or 2?
    p.addModifier("CounterClockWise"); // vibrates / shakes the notes like crazy, could be useful for some stuff

    var f = 1;
    numericForInterval(16, 48, 4, (s) -> {
        f *= -1;
        var step = s + 1;

        p.set("Drunk", s, 0.1);
        p.set("Tipsy", s, 0.05);
        p.set("Bumpy", s, 0.5);
    });

    numericForInterval(212, 244, 4, (s) -> {
        f *= -1;
        var step = s + 1;

        p.set("Scale", s, 1.15);
        p.ease("Scale", s, 0.6, 1, FlxEase.quadOut);

        p.set("Drunk", s, -0.5);
        p.ease("Drunk", s, 0.8, 0, FlxEase.sineOut);

        p.set("LocalRotateZ", s, 0.15 * -f, 0);
        p.set("LocalRotateZ", s, 0.15 * f, 1);
        p.ease("LocalRotateZ", s, 0.85, 0, FlxEase.quadOut);

        p.set("Confusion", s, 0.05);
        p.ease("Confusion", s, 0.8, 0, FlxEase.sineOut);

        p.set("TipsyY", step, 0.6 * f);
        p.set("Scale", step, 1.1);
        p.ease("Scale", step, 0.6, 1, FlxEase.quadOut);
        p.ease("TipsyY", step, 0.6, 0, FlxEase.cubeOut);
    });

    numericForInterval(244, 260, 4, (s) -> {
        f *= -1;
        var step = s + 1;

        p.set("Scale", s, 1.15);
        p.ease("Scale", s, 0.6, 1, FlxEase.quadOut);

        p.set("Drunk", s, -0.5);
        p.ease("Drunk", s, 0.8, 0, FlxEase.sineOut);
    });

    numericForInterval(252, 260, 1, (s) -> {
        p.ease("Reverse", s, 4, 1, FlxEase.quartOut, 0);
        p.ease("localrotateY", s, 1.3, 1, FlxEase.quartOut, 0);
    });

    numericForInterval(268, 276, 1, (s) -> {
        p.ease("Bumpy", s, 1, 1, FlxEase.quartOut, 1);
    });
}