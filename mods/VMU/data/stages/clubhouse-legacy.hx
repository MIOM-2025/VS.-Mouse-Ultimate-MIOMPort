function postCreate(){
    if (!Options.gameplayShaders) return;
    var shader = new CustomShader('adjustColor');
    gf.shader = shader;
    shader.brightness = -30;
    shader.hue = -15;
    shader.saturation = -20; 
}

function beatHit(){
    if(curBeat % 2 == 0){
        for(i in ['donald','goofy']){
           stage.stageSprites[i].playAnim('idle', true);
           
        }
    }
}

function onStageNodeParsed(e) {
    //trace(e.node);
    var spriteName:String = Std.string(e.sprite.name);
    var songName = PlayState.SONG.meta.name;
    //trace(e.name);
    if(e.node.get("song") != null && e.node.get("song") != songName){
        if(songName == "Crisis") return;
        if((e.name != 'char'))
            e.stage.state.remove(e.sprite);
        else {
            e.sprite.scale.x = 1;
            e.sprite.scale.y = 1;
        } 
    }
}