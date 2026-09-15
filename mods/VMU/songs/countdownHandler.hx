function onCountdown(e){
    if(e.cancelled) return;
    e.spritePath = null;
    switch(e.swagCounter){
        case 0:
            spr3 = new FlxSprite().loadGraphic(Paths.image("game/three"));
            spr3.scrollFactor.set();
            spr3.scale.set(e.scale, e.scale);
            spr3.updateHitbox();
            spr3.screenCenter();
            spr3.x -= 200;
            spr3.y += 100;
            spr3.alpha = 0;
            spr3.angle = FlxG.random.int(-15,15);
            spr3.antialiasing = e.antialiasing;
            spr3.camera = camHUD;
            add(spr3);
            tween = FlxTween.tween(spr3, {y: spr3.y - 100, alpha:1}, Conductor.crochet / 1000, {
                ease: FlxEase.cubeOut,
                onComplete: function(twn:FlxTween)
                {
                    new FlxTimer().start((Conductor.crochet / 1000) * 1.5, () -> {
                        FlxTween.tween(spr3.scale, {x:0.5, y:0.5}, Conductor.crochet / 1000, {
                            ease: FlxEase.expoIn,
                        });
                        FlxTween.tween(spr3, {x:581.5, y: spr3.y + 100, alpha:0}, (Conductor.crochet / 1000) * 0.5, {
                            ease: FlxEase.cubeIn,
                            onComplete: () -> {
                                spr3.destroy();
                                remove(spr3, true);
                            }
                        });
                    });

                }
            });
        case 1:
            spr2 = new FlxSprite().loadGraphic(Paths.image("game/two"));
            spr2.scrollFactor.set();
            spr2.scale.set(e.scale, e.scale);
            spr2.updateHitbox();
            spr2.screenCenter();
            spr2.y += 50;
            spr2.alpha = 0;
            spr2.angle = FlxG.random.int(-15,15);
            spr2.antialiasing = e.antialiasing;
            spr2.camera = camHUD;
            add(spr2);
            tween = FlxTween.tween(spr2, {y: spr2.y - 100, alpha:1}, Conductor.crochet / 1000, {
                ease: FlxEase.cubeOut,
                onComplete: function(twn:FlxTween)
                {
                    new FlxTimer().start((Conductor.crochet / 1000) * 0.5, () -> {
                        FlxTween.tween(spr2.scale, {x:0.5, y:0.5}, Conductor.crochet / 1000, {
                            ease: FlxEase.expoIn,
                        });
                        FlxTween.tween(spr2, {x:581.5, y: spr2.y + 100, alpha:0}, (Conductor.crochet / 1000) * 0.5, {
                            ease: FlxEase.cubeIn,
                            onComplete: () -> {
                                spr2.destroy();
                                remove(spr2, true);
                            }
                        });
                    });
                }
            });
        case 2:
            spr1 = new FlxSprite().loadGraphic(Paths.image("game/one"));
            spr1.scrollFactor.set();
            spr1.scale.set(e.scale, e.scale);
            spr1.updateHitbox();
            spr1.screenCenter();
            spr1.x += 200;
            spr1.y += 100;
            spr1.alpha = 0;
            spr1.angle = FlxG.random.int(-15,15);
            spr1.antialiasing = e.antialiasing;
            spr1.camera = camHUD;
            add(spr1);
            tween = FlxTween.tween(spr1, {y: spr1.y - 100, alpha:1}, Conductor.crochet / 1000, {
                ease: FlxEase.cubeOut,
            });
            new FlxTimer().start((Conductor.crochet / 1000) * 0.5, () -> {
                FlxTween.tween(spr1.scale, {x:0.5, y:0.5}, Conductor.crochet / 1000, {
                    ease: FlxEase.expoIn,
                });
                FlxTween.tween(spr1, {x:581.5, y: spr1.y + 100, alpha:0}, (Conductor.crochet / 1000) * 0.5, {
                    ease: FlxEase.cubeIn,
                    onComplete: () -> {
                    spr1.destroy();
                    remove(spr1, true);
                    }
                });
            });
        case 3:
            sprgo = new FlxSprite();
            sprgo.frames = Paths.getSparrowAtlas('game/go');
            sprgo.animation.addByPrefix("go","GoAni",24,false);
            sprgo.scrollFactor.set();
            sprgo.scale.set(0.7, 0.7);
            sprgo.updateHitbox();
            sprgo.screenCenter();
            sprgo.x += 20;
            sprgo.y += 100;
            sprgo.alpha = 1;
            sprgo.antialiasing = e.antialiasing;
            sprgo.camera = camHUD;
            sprgo.animation.play("go",true);
            add(sprgo);
            tween = FlxTween.tween(sprgo.scale, {x:1,y:1}, Conductor.crochet / 1000, {ease: FlxEase.backOut});
            tween = FlxTween.tween(sprgo, {y:sprgo.y-100,alpha:1}, Conductor.crochet / 1000, {ease: FlxEase.cubeOut});
            new FlxTimer().start((Conductor.crochet / 1000), () -> {
                FlxTween.tween(sprgo, {alpha:0}, (Conductor.crochet / 1000), {
                    ease: FlxEase.cubeIn,
                    onComplete: () -> {
                        sprgo.destroy();
                        remove(sprgo, true);
                    }
                });
            });
    }
}