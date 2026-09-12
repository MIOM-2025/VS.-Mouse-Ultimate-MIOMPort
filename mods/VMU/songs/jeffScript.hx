var jeff:FunkinSprite;
var jeffComboGroup:FlxSpriteGroup;
var speechBubble:FunkinSprite;

var lastScoreThreshold:Int = 0;
var jumpCount:Int = 0;

function create() {
    if (!FlxG.save.data.jeff) {
        disableScript();
        return;
    }
}

function postCreate() {
    jeff = new FunkinSprite(dad.x - 600, dad.y + 150);
    jeff.loadSprite(Paths.image('game/secret/jeff'));
    jeff.antialiasing = Options.antialiasing;
    jeff.flipX = true;
    add(jeff);

    speechBubble = new FunkinSprite(0, 100); 
    speechBubble.loadGraphic(Paths.image('game/secret/speechBubble'));
    speechBubble.scale.set(0.7, 0.7);
    speechBubble.updateHitbox();
    speechBubble.alpha = 1;
    add(speechBubble);

    jeffComboGroup = new FlxSpriteGroup();
    jeffComboGroup.cameras = [camGame];
    add(jeffComboGroup);

    remove(comboGroup);
}

function onPlayerHit(e) {
    if (e == null || e.note.isSustainNote) return;

    if (songScore >= lastScoreThreshold + 10000) {
        lastScoreThreshold += 10000;
        jumpCount++;
        jeffJumpSpin();
        
        scoreTxt.color = 0xFFFFFF00;
        FlxTween.color(scoreTxt, 1, 0xFFFFFF00, 0xFFFFFFFF, {ease: FlxEase.quadOut});
    }

    e.showRating = false;

    var rating:FlxSprite = jeffComboGroup.recycle(FlxSprite);
    rating.cameras = [camGame];
    
    var spawnY:Float = 212.5; 
    CoolUtil.resetSprite(rating, 0, spawnY);
    CoolUtil.loadAnimatedGraphic(rating, Paths.image(e.ratingPrefix + e.rating + e.ratingSuffix));
    
    rating.x += 62.5; 
    rating.acceleration.y = 350; 
    rating.velocity.y = -FlxG.random.int(140, 175);
    
    rating.scale.set(e.ratingScale * 0.6, e.ratingScale * 0.6);
    rating.updateHitbox();

    FlxTween.tween(rating, {alpha: 0}, 0.2, {
        startDelay: Conductor.crochet * 0.0004,
        onComplete: function(t) { rating.kill(); }
    });
}

function jeffJumpSpin() {
    FlxG.sound.play(Paths.sound('jeffSpin'), 1);

    jeff.angle = 0;
    FlxTween.tween(jeff, {angle: 360}, 0.6, {ease: FlxEase.cubeOut});

    var jumpHeight:Float = 150 + (50 * (jumpCount - 1));
    var originalY:Float = jeff.y;

    FlxTween.tween(jeff, {y: originalY - jumpHeight}, 0.3, {
        ease: FlxEase.cubeOut, 
        onComplete: function(t) {
            FlxTween.tween(jeff, {y: originalY}, 0.3, {ease: FlxEase.cubeIn});
        }
    });
}