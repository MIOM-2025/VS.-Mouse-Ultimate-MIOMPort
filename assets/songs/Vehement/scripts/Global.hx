public var donaldChar = strumLines.members[2].characters[0];
public var goofyChar = strumLines.members[3].characters[0];

function postCreate() {
    //turning off later phase sprites
    for (s in stage.stageSprites){
        var spriteName:String = Std.string(s.name);
        if (StringTools.contains(spriteName, "V-")) s.visible = false;
    }
    goofyChar.visible = false;
    //donaldChar.visible = false;
    stage.stageSprites['donald'].visible = false;
}