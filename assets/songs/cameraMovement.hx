public var camNoteOffset:Float = 25;
public var camLerpSetting:Float = 0.04;
function postCreate() FlxG.camera.followLerp = camLerpSetting; 
function onCameraMove(e) {
    if (e.strumLine == null || e.strumLine.characters == null || e.strumLine.characters[0] == null) return;
    var char = e.strumLine.characters[0];
    if(char.curCharacter == 'gf') return;

    if (char.animation == null || char.animation.curAnim == null) return;
    var anim = char.animation.curAnim.name.toUpperCase();

    if (anim.indexOf("LEFT") != -1)  e.position.x -= camNoteOffset;
    if (anim.indexOf("DOWN") != -1)  e.position.y += camNoteOffset;
    if (anim.indexOf("UP") != -1)    e.position.y -= camNoteOffset;
    if (anim.indexOf("RIGHT") != -1) e.position.x += camNoteOffset;
}