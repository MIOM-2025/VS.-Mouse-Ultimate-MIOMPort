import openfl.filters.ShaderFilter;
import funkin.menus.MainMenuState;

public var rays:CustomShader;
public var bloom:CustomShader;
public var evaCam:FlxCamera;
var isStopping:Bool = false;

function create() {
    if (!FlxG.save.data.godrays) {
        disableScript();
        return;
    }
}

function postCreate() {
    rays = new CustomShader("godRays");
    bloom = new CustomShader("bloom");
    
    rays.lightPos = [0.5, 0.2];
    rays.weight = 0;
    rays.decay = 0;
    rays.density = 0;
    rays.exposure = 0;

    evaCam = new FlxCamera();
    evaCam.bgColor = 0x00;
    FlxG.cameras.add(evaCam, false);
}

function update(elapsed:Float) {
    if (FlxG.keys.justPressed.TWO && !isStopping) {
        isStopping = true;

        var bomb = FlxG.sound.play(Paths.sound('nukeBomb'));

        if (inst != null) inst.stop();
        if (vocals != null) vocals.stop();
        for (s in strumLines.members) if (s != null && s.vocals != null) s.vocals.stop();

        new FlxTimer().start(1.5, function(tmr:FlxTimer) {
            var filterList = [new ShaderFilter(bloom), new ShaderFilter(rays)];
            camHUD.setFilters(filterList);
            camGame.setFilters(filterList);

            var duration = 2;

            FlxTween.num(0, 2, duration, {ease: FlxEase.quadOut}, function(v) {
                rays.weight = v;
                camGame.shake(v * 0.083, 0.1); 
                camHUD.shake(v * 0.041, 0.1);
            });

            FlxTween.num(0, 0.98, duration, {ease: FlxEase.quadOut}, function(v) rays.decay = v);
            FlxTween.num(0, 1.5, duration, {ease: FlxEase.quadOut}, function(v) rays.density = v);
            FlxTween.num(0, 5.0, duration, {ease: FlxEase.quadOut}, function(v) rays.exposure = v);

            new FlxTimer().start(3, function(tmr2:FlxTimer) {

                var eva:FlxSprite = new FlxSprite().loadGraphic(Paths.image('game/secret/eva'));
                eva.antialiasing = Options.antialiasing;
                eva.scrollFactor.set(0, 0);
                eva.screenCenter();
                eva.cameras = [evaCam]; 
                add(eva);

                for (cam in FlxG.cameras.list) {
                    if (cam != null && cam != evaCam) {
                        cam.setFilters([]);
                        cam.visible = false;
                    }
                }
                
                FlxG.timeScale = 1;

                new FlxTimer().start(1.9, function(tmr2:FlxTimer) {
                    FlxG.switchState(new MainMenuState());
                });
            
            });
        });
    }
}