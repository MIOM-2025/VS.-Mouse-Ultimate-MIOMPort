function onPlayerHit(e) {
    if (e == null || e.note.isSustainNote) return;
    e.showRating = false;

    var pre:String = e.ratingPrefix;
    var suf:String = e.ratingSuffix;

    // 判断是否为 Scallywag 歌曲
    var isScallywag:Bool = (PlayState.SONG.meta.name == "Scallywag");
    // 判断是否为 Legacy 版本的 Welcome
    var isLegacyWelcome:Bool = (PlayState.variation == "Legacy" && PlayState.SONG.meta.name == "Welcome");

    // 评级基准 X：Scallywag 时屏幕中心，否则原 comboGroup 偏移
    var centerX:Float = isScallywag ? FlxG.width / 2 : comboGroup.x + 190;
    // Y 轴额外偏移：Scallywag 时向上 250 像素
    var yAdjust:Float = isScallywag ? -280 : 0;

    // ---------- 计算垂直偏移量 ----------
    var yOffset:Float = 0;
    if (isLegacyWelcome) {
        // Legacy Welcome：强制使用向下滚动的偏移量（-190），且不受 middleScroll 影响
        yOffset = -190;
    } else {
        // 常规逻辑：仅当中间滚动开启时应用偏移
        if (FlxG.save.data.middleScroll) {
            yOffset = Options.downscroll ? -190 : 180;
        }
    }

    // ---------- 额外偏移（仅 Legacy Welcome） ----------
    var xOffsetExtra:Float = 0;
    var yOffsetExtra:Float = 0;
    if (isLegacyWelcome) {
        xOffsetExtra = 400;   // 向右额外 200 像素
        yOffsetExtra = 550;   // 向下额外 400 像素
    }

    // ---------- 评级图标 ----------
    var rating:FlxSprite = comboGroup.recycleLoop(FlxSprite);
    var spawnY:Float = Options.downscroll ? 640 : 45;
    // 应用额外 X 偏移
    var finalRatingX:Float = centerX + xOffsetExtra;
    var finalRatingY:Float = comboGroup.y + spawnY + yOffset + yAdjust + yOffsetExtra;
    CoolUtil.resetSprite(rating, finalRatingX, finalRatingY);
    CoolUtil.loadAnimatedGraphic(rating, Paths.image(pre + e.rating + suf));

    rating.acceleration.y = Options.downscroll ? -550 : 550;
    rating.velocity.y += Options.downscroll ? FlxG.random.int(140, 175) : -FlxG.random.int(140, 175);
    rating.velocity.x -= FlxG.random.int(0, 10);

    rating.scale.set(e.ratingScale * 0.8, e.ratingScale * 0.8);
    rating.antialiasing = e.ratingAntialiasing;
    rating.updateHitbox();

    rating.x -= rating.width / 2;   // 水平居中
    rating.y -= rating.height / 2;

    FlxTween.tween(rating, {'scale.x': e.ratingScale * 0.65, 'scale.y': e.ratingScale * 0.65}, Conductor.crochet * 0.001, {ease: FlxEase.cubeOut});
    FlxTween.tween(rating, {alpha: 0}, 0.2, {
        startDelay: Conductor.crochet * 0.0005,
        onComplete: function(tween:FlxTween) { rating.kill(); }
    });

    // ---------- 连击数字 ----------
    var separatedScore:String = Std.string(combo + 1);
    var numBaseX:Float;
    if (isScallywag) {
        var totalWidth:Float = (separatedScore.length - 1) * 43;
        numBaseX = FlxG.width / 2 - totalWidth / 2;
    } else {
        numBaseX = comboGroup.x + 190;
    }
    // 应用额外 X 偏移
    numBaseX += xOffsetExtra;

    for (i in 0...separatedScore.length) {
        var numScore:FlxSprite = comboGroup.recycleLoop(FlxSprite);
        CoolUtil.loadAnimatedGraphic(numScore, Paths.image(pre + 'num' + separatedScore.charAt(i) + suf));

        var numSpawnY:Float = Options.downscroll ? 540 : 80;
        var finalNumX:Float = numBaseX + (43 * i);
        var finalNumY:Float = comboGroup.y + numSpawnY + yOffset + yAdjust + yOffsetExtra;
        CoolUtil.resetSprite(numScore, finalNumX, finalNumY);

        numScore.antialiasing = e.numAntialiasing;
        numScore.scale.set(e.numScale * 1.15, e.numScale * 1.15);
        numScore.updateHitbox();

        numScore.acceleration.y = Options.downscroll ? -520 : 550;
        numScore.velocity.y += Options.downscroll ? FlxG.random.int(140, 175) : -FlxG.random.int(140, 175);
        numScore.velocity.x -= FlxG.random.int(0, 10);

        FlxTween.tween(numScore, {'scale.x': e.numScale * 0.85, 'scale.y': e.numScale * 0.85}, Conductor.crochet * 0.001, {ease: FlxEase.cubeOut});
        FlxTween.tween(numScore, {alpha: 0}, 0.2, {
            startDelay: Conductor.crochet * 0.0005,
            onComplete: function(tween:FlxTween) { numScore.kill(); }
        });
    }
}