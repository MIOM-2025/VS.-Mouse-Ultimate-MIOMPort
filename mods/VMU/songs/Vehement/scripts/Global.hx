// Renamed: vehEvents.hx also declares donaldChar/goofyChar (as arrays) and the names collided.
public var globalDonald = strumLines.members[2].characters[0];
public var globalGoofy = strumLines.members[3].characters[0];

function postCreate() {
    //turning off later phase sprites
    for (s in stage.stageSprites){
        var spriteName:String = Std.string(s.name);
        if (StringTools.contains(spriteName, "V-")) s.visible = false;
    }
    globalGoofy.visible = false;
    //donaldChar.visible = false;
    stage.stageSprites['donald'].visible = false;
}