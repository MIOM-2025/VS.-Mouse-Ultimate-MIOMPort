import funkin.backend.utils.CoolUtil;
var bg:FlxSprite;
function postCreate(){
    CoolUtil.playMusic(Paths.music('options'), false, 1, true, 80);
    add(bg = new FlxSprite().loadGraphic(Paths.image("menus/menuDesat")));
    bg.scrollFactor.set();
    bg.color = 0xFF9271FD;
    bg.screenCenter();
}