function create() if(PlayState.SONG.meta.name == "Crisis" && PlayState.variation == "Legacy") idleSuffix = "-worried";
function onTryDance(e){
    if (PlayState.instance != null && idleSuffix == "-scared"){
            playAnim("idle" + idleSuffix,true,"DANCE");      
    }

}