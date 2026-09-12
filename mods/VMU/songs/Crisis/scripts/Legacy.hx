import openfl.display.BlendMode;

if(PlayState.variation != "Legacy"){
    //trace('New Version of Song! Removing Special Events meant for Old Version...');
    disableScript();
    return;
}

var trippy_shader = new CustomShader('trippy');
var high_timer:Float = 0;

function postCreate() {
    for (s in stage.stageSprites) {
        var spriteName:String = Std.string(s.name);
        s.color = 0xFFFFFFFF;
        
        if (spriteName == "donald" || spriteName == "goofy") continue;
        //if (spriteName == "V-fgA" || spriteName == "V-lightBulb") s.visible = false;
        
        if (StringTools.contains(spriteName, "V-")) {
            s.visible = true;
        } else {
            s.visible = false;
        }
    }

    stage.stageSprites.get("V-fg").visible = false;
    stage.stageSprites.get("V-fgA").visible = true;
    var bulb = stage.stageSprites.get("V-lightBulb");
    bulb.origin.set(bulb.frameWidth / 2, 0);
    bulb.offset.set(0, 0);
    bulb.visible = true;

    stage.stageSprites['donald'].visible = false;
    stage.stageSprites['goofy'].visible = false;

    vehementScary = new FunkinSprite(-325, -177.5, Paths.image('stages/clubhouse/vehVignette'));
    vehementScary.antialiasing = Options.antialiasing;
    vehementScary.cameras = [camHUD];
    vehementScary.scale.set(0.675, 0.675);
    vehementScary.alpha = 0.5;
    vehementScary.addAnim('i', 'sorry', 24, true);
    vehementScary.playAnim('i');
    insert(0, vehementScary);

    mainVig = new FunkinSprite(0, 0, Paths.image('stages/clubhouse/altVig'));
    mainVig.antialiasing = Options.antialiasing;
    mainVig.blend = BlendMode.ADD;
    mainVig.cameras = [camHUD];
    mainVig.alpha = 0.1;
    insert(0, mainVig);

    feralVig = new FunkinSprite(0, 0, Paths.image('stages/clubhouse/feralVig2'));
    feralVig.antialiasing = Options.antialiasing;
    feralVig.cameras = [camHUD];
    feralVig.alpha = 0.1;
    feralVig.blend = BlendMode.ADD;
    insert(0, feralVig);

    camHUD.addShader(trippy_shader);

	trippy_shader.darkness = 0.55;
}
var bulb = stage.stageSprites.get("V-lightBulb");
function update(elapsed) {
    high_timer += elapsed;

	trippy_shader.iTime = high_timer;

    if (bulb != null && bulb.visible) 
        bulb.angle = Math.sin(Conductor.songPosition / 1500) * 12;
}