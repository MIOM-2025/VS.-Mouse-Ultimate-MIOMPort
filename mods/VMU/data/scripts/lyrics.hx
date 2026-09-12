import haxe.Json;
import flixel.text.FlxTextAlign;
import flixel.text.FlxTextBorderStyle;

var songName = PlayState.SONG.meta.name;
var jsonPath = Paths.getPath('songs/$songName/lyrics.json');
json = Json.parse(Assets.getText(jsonPath));

trace(json.difficulty == PlayState.difficulty);

var data = [];
function create() {
    if (!FlxG.save.data.subtitles) {
        disableScript();
        return;
    }
}
function postCreate() {
	camOther = new FlxCamera();
	camOther.bgColor = 0;
	FlxG.cameras.add(camOther, false);
	
	if(PlayState.variation == null) //1 single use case but whatever
		data = json.stuff;
	else data = json.legacy;

	for (j in data) j.triggered = false;

	subtitlemark = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
	subtitlemark.visible = false;
	subtitlemark.alpha = 0.5;
	subtitlemark.camera = camOther;
	add(subtitlemark);

	poop = new FlxText();
	poop.setFormat(Paths.font('WickedMouse.ttf'), 28, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	poop.borderSize = 2.5;
	poop.text = "";
	poop.screenCenter(FlxAxes.X);
	poop.y = healthBar.y + (Options.downScroll ? 65 : -65);
	poop.antialiasing = Options.antialiasing;
	poop.camera = camOther;
	add(poop);
}

function update(elapsed) {
	for (j in data) {
		if (!j.triggered && curStep >= j.timestamp) {
			j.triggered = true;
			showLyric(j);
		}
	}
}

function showLyric(j) {
	poop.text = StringTools.replace(j.lyric, "'", "");
	poop.color = FlxColor.fromString(j.color);
	poop.antialiasing = Options.antialiasing;
	poop.screenCenter(FlxAxes.X);

	subtitlemark.scale.set(poop.width + 20, poop.size + 8);
	subtitlemark.updateHitbox();
	subtitlemark.x = (FlxG.width / 2) - subtitlemark.width / 2;
	subtitlemark.y = poop.y + 2;
	subtitlemark.visible = poop.text != "";
}