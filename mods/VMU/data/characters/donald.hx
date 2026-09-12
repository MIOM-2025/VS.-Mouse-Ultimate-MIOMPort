function create() if(PlayState.SONG.meta.name == "Crisis" && PlayState.variation == "Legacy") idleSuffix = "-mad3";
function onTryDance(e){
    if (PlayState.instance != null && idleSuffix != "-alt"){
        if(StringTools.startsWith(animation.curAnim.name,"idle")){
            playAnim("idle" + idleSuffix,true,"DANCE");
        }        
    }
    //trace(StringTools.startsWith(animation.curAnim.name,"idle"));

}
