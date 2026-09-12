import funkin.game.cutscenes.dialogue.DialogueCharacter;
import flixel.text.FlxTextBorderStyle;
import flixel.text.FlxTextAlign;
import funkin.backend.MusicBeatTransition;
var loopedTimer:FlxTimer;
var bgFade:FlxSprite;
var charName:FunkinText;

function postCreate() {
    bgFade = new FlxSprite().makeSolid(FlxG.width + 100, FlxG.height + 100, 0xFFB3DFd8);
    bgFade.screenCenter();
    bgFade.scrollFactor.set();
    bgFade.alpha = 0;
    cutscene.insert(0, bgFade);

    FlxTween.tween(bgFade,{alpha:0.7},1);
    
    text.alignment = 'center';

    charName = new FunkinText(350,485,FlxG.width);
    cutscene.add(charName);
    charName.text = "test";
    charName.setFormat(Paths.font('WickedMouse.ttf'), 28, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    charName.alignment = 'center';
    charName.borderSize = 2.5;

    //trace(cutscene.dialogueBox);
    MusicBeatTransition.script = null;
}   

var finished:Bool = false;
function close(event) {
    if(finished) return;
    else event.cancelled = true;
    cutscene.canProceed = false;

    cutscene.curMusic?.fadeOut(1, 0);
    for(c in cutscene.charMap) c.visible = false;

    FlxTween.cancelTweensOf(bgFade);
    for(i in [cutscene.dialogueBox, cutscene.dialogueBox.text,charName])FlxTween.tween(i,{alpha:0},1);
    FlxTween.tween(bgFade,{alpha:0},1,{onComplete: () -> {
        finished = true;
        cutscene.close();
    }});
}

function postPlayBubbleAnim() {
    cutscene.remove(charName);
    if(active && visible){      
        cutscene.add(charName); 
    }

}
function popupChar(e){
    charName.text = cutscene.curLine.char;
}

function destroy(){
    MusicBeatTransition.script = "data/stickerTransition";
}