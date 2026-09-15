import funkin.backend.utils.CoolUtil;
var stringCode = "DANCEOFF";
function create(){
    //trace(stringCode.length);
    for(i in 0...stringCode.length){
        //trace(stringCode.charAt(i));
    }
    //trace(String.fromCharCode(65));
}
var codeIndex = 0;
function update(){
    var key = FlxG.keys.firstJustPressed();
    if(codeIndex == stringCode.length && !canDance){
        canDance = true;
        idleSuffix="-dance";
        playAnim("idle" + idleSuffix,true,"DANCE");
    }
    if(CoolUtil.keyToString(key) == stringCode.charAt(codeIndex) && key != -1){
        //trace(codeIndex);
        //trace(CoolUtil.keyToString(key));
        codeIndex += 1;
    }
    else if (key != -1) codeIndex = 0;
    //if (FlxG.keys.justPressed)
}
var canDance = false;
function onTryDance(e){
    if (PlayState.instance != null && idleSuffix != "-alt"){
        if(StringTools.startsWith(animation.curAnim.name,"idle")){
            playAnim("idle" + idleSuffix,true,"DANCE");
        }
    }
    //trace(StringTools.startsWith(animation.curAnim.name,"idle"));

}