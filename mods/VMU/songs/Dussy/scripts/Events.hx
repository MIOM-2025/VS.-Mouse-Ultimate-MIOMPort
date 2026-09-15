import hxvlc.flixel.FlxVideoSprite;

function postCreate() {
    for (i in [boyfriend, dad]) remove(i);

    stage.stageSprites['donald'].visible = false;
    stage.stageSprites['goofy'].visible = false;
    
    strumLines.members[0].characters[0].x += 500;
    strumLines.members[0].characters[0].y += 100;

    dad.scale.set(0.7, 0.7);
    //strumLines.members[0].characters[0].animation.play("idle-mad1");

    video = new FlxVideoSprite(687.5, 450);
	video.load(Assets.getPath(Paths.video('dussy-loop')), [':input-repeat=65535', ':no-audio']);
	video.play();
    video.scale.set(1.5, 1.5);
    add(video);

    for (i in [boyfriend, dad]) add(i);
}
function update() {
    strumLines.members[0].characters[0].idleSuffix = "-mad1";
}