import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import funkin.game.PlayState.ComboRating;

var iconScaleP2:FlxPoint = FlxPoint.get(1.0, 1.0);
var iconScaleP1:FlxPoint = FlxPoint.get(1.0, 1.0);
var iconSpeed:Float = 0.15;
var iconBopEnabled:Bool = true;

public static var psychScoreTxt:FunkinText;
var psychScoreTxtTween:FlxTween;
var ratingFC:String = "N/A";
var ratingStuff:Array<Dynamic> = [
    ['You Suck!', 0.2], ['Shit', 0.4], ['Bad', 0.5], ['Bruh', 0.6], 
    ['Meh', 0.69], ['Nice', 0.7], ['Good', 0.8], ['Great', 0.9], 
    ['Sick!', 1], ['Perfect!!', 1]
];

trace("Current variation: " + PlayState.variation);
if (PlayState.variation != "Legacy") {
    disableScript();
    return;
}

function setIconScale(icon:FlxSprite, scalePoint:FlxPoint, x:Float, y:Float) {
    scalePoint.set(x, y);
    icon.scale.set(scalePoint.x, scalePoint.y);
    icon.updateHitbox(); 
}

function getRating(ratingAccuracy:Float):String {
    if (ratingAccuracy < 0) return "N/A"; 
    for (rating in ratingStuff)
        if (ratingAccuracy < rating[1]) return rating[0]; 
    return ratingStuff[ratingStuff.length - 1][0]; 
}

function updateRatingFC(accuracy:Float, misses:Int) {
    if (misses == 0) {
        if (accuracy == 1.0) ratingFC = "SFC"; 
        else if (accuracy >= 0.99) ratingFC = "GFC"; 
        else ratingFC = "FC"; 
    } else {
        if (misses < 10) ratingFC = "SDCB"; 
        else ratingFC = "Clear"; 
    }
}

function postCreate() {
    for (i in [scoreTxt, missesTxt, accuracyTxt]) if (i != null) remove(i);
    
    healthBar.scale.set(1.1, 1);
    healthBarBG.scale.set(1.1, 1);

    psychScoreTxt = new FunkinText(0, 685, FlxG.width, "Score: 0 | Misses: 0 | Rating: N/A");
    psychScoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    psychScoreTxt.borderSize = 1.25;
    psychScoreTxt.screenCenter(FlxAxes.X);
    if (downscroll) psychScoreTxt.y = 605;
    psychScoreTxt.cameras = [camHUD];
    add(psychScoreTxt);

    if (iconBopEnabled) doIconBop = false; 
}

function onPlayerHit(e) {
    if (!e.note.isSustainNote) {
        if (psychScoreTxtTween != null) psychScoreTxtTween.cancel();

        psychScoreTxt.scale.set(1.075, 1.075); 
        psychScoreTxtTween = FlxTween.tween(psychScoreTxt.scale, {x: 1, y: 1}, 0.2, {
            onComplete: function(twn:FlxTween) { psychScoreTxtTween = null; }
        });
    }
}

function update(elapsed:Float) {
    var psychAccuracy = FlxMath.roundDecimal(Math.max(accuracy, 0) * 100, 2);
    var rating:String = getRating(accuracy);
    updateRatingFC(accuracy, misses);

    if (songScore > 0 || psychAccuracy > 0 || misses > 0) {
        psychScoreTxt.text = "Score: " + songScore
            + " | Misses: " + misses
            + " | Rating: " + rating + " (" + psychAccuracy + "%) - " + ratingFC;
    }
}

function postUpdate(elapsed:Float) {
    if (iconBopEnabled) {
        var iconLerp:Float = elapsed * 60 * iconSpeed; 
        
        iconScaleP2.set(FlxMath.lerp(iconScaleP2.x, 1.0, iconLerp), FlxMath.lerp(iconScaleP2.y, 1.0, iconLerp)); 
        iconScaleP1.set(FlxMath.lerp(iconScaleP1.x, 1.0, iconLerp), FlxMath.lerp(iconScaleP1.y, 1.0, iconLerp)); 
        
        iconP2.scale.set(iconScaleP2.x, iconScaleP2.y);
        iconP1.scale.set(iconScaleP1.x, iconScaleP1.y);

        iconP1.y = healthBar.y - (iconP1.height / 2) + 5;
        iconP2.y = healthBar.y - (iconP2.height / 2) - 10;
    }
}

function beatHit(beat:Int) {
    if (iconBopEnabled) {
        setIconScale(iconP2, iconScaleP2, 1.2, 1.2); 
        setIconScale(iconP1, iconScaleP1, 1.2, 1.2); 
    }
}

function destroy() {
    iconScaleP2 = FlxDestroyUtil.put(iconScaleP2); 
    iconScaleP1 = FlxDestroyUtil.put(iconScaleP1); 
}