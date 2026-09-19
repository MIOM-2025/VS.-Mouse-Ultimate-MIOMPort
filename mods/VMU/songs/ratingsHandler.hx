function onPlayerHit(e) {
    if (e == null || e.note == null || e.note.isSustainNote) return;

    e.showRating = false; // 关掉内置

    // --- 修正 1：prefix/suffix 可能为 null ---
    var pre:String = e.ratingPrefix != null ? e.ratingPrefix : "game/score/";
    var suf:String = e.ratingSuffix != null ? e.ratingSuffix : "";

    // --- 修正 2：scale 可能为 null ---
    var rScale:Float = e.ratingScale != null ? e.ratingScale : 1;
    var nScale:Float = e.numScale    != null ? e.numScale    : 1;

    // ===== 判定文字 =====
    var rating:FlxSprite = comboGroup.recycleLoop(FlxSprite);

    var spawnY:Float = Options.downscroll ? 550 : 25;
    CoolUtil.resetSprite(rating, comboGroup.x + 190, comboGroup.y + spawnY);
    CoolUtil.loadAnimatedGraphic(rating, Paths.image(pre + e.rating + suf));

    rating.acceleration.y = Options.downscroll ? -550 : 550;
    rating.velocity.y += Options.downscroll ? FlxG.random.int(140, 175) : -FlxG.random.int(140, 175);
    rating.velocity.x -= FlxG.random.int(0, 10);

    rating.scale.set(rScale * 0.8, rScale * 0.8);
    rating.antialiasing = e.ratingAntialiasing == true;
    rating.updateHitbox();

    rating.x -= rating.width  / 2;
    rating.y -= rating.height / 2;

    FlxTween.tween(rating, {'scale.x': rScale * 0.65, 'scale.y': rScale * 0.65},
        Conductor.crochet * 0.001, {ease: FlxEase.cubeOut});

    FlxTween.tween(rating, {alpha: 0}, 0.2, {
        startDelay: Conductor.crochet * 0.0004,
        onComplete: function(_) rating.kill()
    });

    // ===== 连击数字 =====
    var separatedScore:String = Std.string(combo + 1);
    for (i in 0...separatedScore.length) {
        var numScore:FlxSprite = comboGroup.recycleLoop(FlxSprite);

        CoolUtil.loadAnimatedGraphic(numScore, Paths.image(pre + 'num' + separatedScore.charAt(i) + suf));

        var numSpawnY:Float = Options.downscroll ? 450 : 80;
        CoolUtil.resetSprite(numScore, comboGroup.x + (43 * i) + 190, comboGroup.y + numSpawnY);

        numScore.antialiasing = e.numAntialiasing == true;
        numScore.scale.set(nScale * 1.15, nScale * 1.15);
        numScore.updateHitbox();

        numScore.acceleration.y = Options.downscroll ? -FlxG.random.int(200, 300) : FlxG.random.int(200, 300);
        numScore.velocity.y += Options.downscroll ? FlxG.random.int(140, 160) : -FlxG.random.int(140, 160);
        numScore.velocity.x = FlxG.random.float(-5, 5);

        FlxTween.tween(numScore, {'scale.x': nScale * 0.85, 'scale.y': nScale * 0.85},
            Conductor.crochet * 0.001, {ease: FlxEase.cubeOut});

        FlxTween.tween(numScore, {alpha: 0}, 0.2, {
            startDelay: Conductor.crochet * 0.0009,
            onComplete: function(_) numScore.kill()
        });
    }
}