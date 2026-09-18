function onPlayerHit(e) {
    if (e == null || e.note.isSustainNote) return;

    e.showRating = false;

    var pre:String = e.ratingPrefix;
    var suf:String = e.ratingSuffix;

    var rating:FlxSprite = comboGroup.recycleLoop(FlxSprite);
    
    var spawnY:Float = Options.downscroll ? 550 : 25;
    CoolUtil.resetSprite(rating, comboGroup.x + 190, comboGroup.y + spawnY);
    CoolUtil.loadAnimatedGraphic(rating, Paths.image(pre + e.rating + suf));
    
    rating.acceleration.y = Options.downscroll ? -550 : 550;
    rating.velocity.y += Options.downscroll ? FlxG.random.int(140, 175) : -FlxG.random.int(140, 175);
    rating.velocity.x -= FlxG.random.int(0, 10);
    
    rating.scale.set(e.ratingScale * 0.8, e.ratingScale * 0.8);
    rating.antialiasing = e.ratingAntialiasing;
    rating.updateHitbox();
    
    rating.x -= rating.width / 2;
    rating.y -= rating.height / 2;

    FlxTween.tween(rating, {'scale.x': e.ratingScale * 0.65, 'scale.y': e.ratingScale * 0.65}, Conductor.crochet * 0.001, {ease: FlxEase.cubeOut});

    FlxTween.tween(rating, {alpha: 0}, 0.2, {
        startDelay: Conductor.crochet * 0.0004,
        onComplete: function(tween:FlxTween) { rating.kill(); }
    });

    var separatedScore:String = Std.string(combo + 1);
    for(i in 0...separatedScore.length) {
        var numScore:FlxSprite = comboGroup.recycleLoop(FlxSprite);
        
        CoolUtil.loadAnimatedGraphic(numScore, Paths.image(pre + 'num' + separatedScore.charAt(i) + suf));
        
        var numSpawnY:Float = Options.downscroll ? 450 : 80;
        CoolUtil.resetSprite(numScore, comboGroup.x + (43 * i) + 190, comboGroup.y + numSpawnY);
        
        numScore.antialiasing = e.numAntialiasing;
        numScore.scale.set(e.numScale * 1.15, e.numScale * 1.15);
        numScore.updateHitbox();

        numScore.acceleration.y = Options.downscroll ? -FlxG.random.int(200, 300) : FlxG.random.int(200, 300);
        numScore.velocity.y += Options.downscroll ? FlxG.random.int(140, 160) : -FlxG.random.int(140, 160);
        numScore.velocity.x = FlxG.random.float(-5, 5);

        FlxTween.tween(numScore, {'scale.x': e.numScale * 0.85, 'scale.y': e.numScale * 0.85}, Conductor.crochet * 0.001, {ease: FlxEase.cubeOut});

        FlxTween.tween(numScore, {alpha: 0}, 0.2, {
            startDelay: Conductor.crochet * 0.0009,
            onComplete: function(tween:FlxTween) { numScore.kill(); }
        });
    }
}