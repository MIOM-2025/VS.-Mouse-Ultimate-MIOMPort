import flixel.text.FlxTextBorderStyle;
import flixel.text.FlxTextFormat;
import flixel.text.FlxTextFormatMarkerPair;

if (PlayState.variation != "Legacy") disableScript();
if (!Options.gameplayShaders) disableScript();

var started:Bool = false;
var finished:Bool = false;
var bg:FunkinSprite;
var titleAlphabet:Alphabet;
var warningTxt:FunkinText;
var yesTxt:FunkinText;
var noTxt:FunkinText;

// 新建摄像机
var warningCam:FlxCamera;

function onStartCountdown(event) {
	if (finished == false) {
		event.cancel();
		if (started == false)
			showWarning();
	}
}

function showWarning() {
	// 初始化摄像机（只执行一次）
	if (warningCam == null) {
		warningCam = new FlxCamera();
		warningCam.bgColor = FlxColor.TRANSPARENT;
		warningCam.antialiasing = false;
		FlxG.cameras.add(warningCam, false);
		// 设置该摄像机为所有 UI 元素的默认摄像机（可选）
		// 但我们显式设置每个元素的 cameras
	}

	// 背景（全屏黑色半透明）
	add(bg = new FunkinSprite(0, 0).makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK));
	bg.cameras = [warningCam];
	bg.alpha = 0.5;

	// 标题
	titleAlphabet = new Alphabet(0, 250, "WARNING", true);
	titleAlphabet.screenCenter(FlxAxes.X);
	titleAlphabet.cameras = [warningCam];
	add(titleAlphabet);

	// 警告文本
	add(warningTxt = new FunkinText(0, titleAlphabet.y + 100, FlxG.width,
		"This song contains flashing rainbow effects that *may trigger photosensitive epilepsy*.\nIf you are sensitive to rapid light changes, please exit this song immediately.\n\nPress #YES# to start the song or #NO# to exit out of the song.",
		32));
	warningTxt.setFormat(Paths.font("CreatoDisplay-ExtraBold.otf"), 28, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
	warningTxt.cameras = [warningCam];
	warningTxt.applyMarkup(warningTxt.text, [
		new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFF4444), "*"),
		new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFFFFF44), "#")
	]);

	// YES / NO 按钮（字体更大）
	var yPos:Float = warningTxt.y + warningTxt.height + 30;
	var fontSize:Int = 36;
	yesTxt = new FunkinText(0, 0, 0, "YES", fontSize);
	yesTxt.setFormat(Paths.font("CreatoDisplay-ExtraBold.otf"), fontSize, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
	yesTxt.updateHitbox();

	noTxt = new FunkinText(0, 0, 0, "NO", fontSize);
	noTxt.setFormat(Paths.font("CreatoDisplay-ExtraBold.otf"), fontSize, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
	noTxt.updateHitbox();

	var spacing:Float = 50;
	var totalWidth:Float = yesTxt.width + spacing + noTxt.width;
	var startX:Float = (FlxG.width - totalWidth) / 2;
	yesTxt.setPosition(startX, yPos);
	noTxt.setPosition(startX + yesTxt.width + spacing, yPos);

	yesTxt.cameras = [warningCam];
	noTxt.cameras = [warningCam];
	add(yesTxt);
	add(noTxt);

	started = true;
	FlxG.sound.play(Paths.sound("settingTurnOff"), 0.75);
}

function update(elapsed:Float) {
	if (started && !finished) {
		// 获取相对于 warningCam 的鼠标位置
		var mousePoint = FlxG.mouse.getScreenPosition(warningCam);

		// 检测鼠标是否悬停在 YES 上
		var onYes:Bool = yesTxt.visible && yesTxt.overlapsPoint(mousePoint, false, warningCam);
		var onNo:Bool = noTxt.visible && noTxt.overlapsPoint(mousePoint, false, warningCam);

		// 更新颜色
		if (onYes) {
			yesTxt.color = 0xFFFFE066; // 淡黄
			if (FlxG.mouse.justReleased) {
				selectYes();
			}
		} else {
			yesTxt.color = 0xFFFFFFFF;
		}

		if (onNo) {
			noTxt.color = 0xFFFFE066;
			if (FlxG.mouse.justReleased) {
				selectNo();
			}
		} else {
			noTxt.color = 0xFFFFFFFF;
		}
	}
}

function selectYes() {
	if (finished) return;
	FlxG.sound.play(Paths.sound("keyboard2"), 0.75);
	hideWarning();
	finished = true;
	startCountdown();
}

function selectNo() {
	if (finished) return;
	FlxG.sound.play(Paths.sound("keyboard2"), 0.75);
	FlxG.switchState(new FreeplayState());
}

function hideWarning() {
	bg.visible = false;
	titleAlphabet.visible = false;
	warningTxt.visible = false;
	yesTxt.visible = false;
	noTxt.visible = false;
}