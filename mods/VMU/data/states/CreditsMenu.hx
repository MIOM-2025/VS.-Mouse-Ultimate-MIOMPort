import flixel.text.FlxTextAlign;
import flixel.text.FlxTextBorderStyle;
import flixel.addons.display.FlxBackdrop;
import funkin.backend.utils.DiscordUtil;
import openfl.display.BlendMode;
import flixel.util.FlxAxes;
import flixel.text.FlxText;
import flixel.FlxCamera;  // 新增

var iconGroup:FlxTypedGroup<FunkinSprite>;
var iconTimers:Array<Float> = [];
var folders:Array<String> = ["directors", "coders", "artnim", "musicians", "va", "port", "specialthanks"]; // folder Categories .
var milestones:Array<Int> = [500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 6000, 7000, 8000, 9000, 10000, 12500, 15000, 17500, 20000, 25000, 30000, 35000, 40000, 45000, 50000];
var folderCounts:Array<Int> = [4, 3, 16, 7, 3, 6, 21]; 

// THIS WAS A PAIN TO WRITE
var creditNames:Array<Array<String>> = [
    ["Saster", "Doorknob", "CloudDaGoat", "dani_gfbi"],
    ["CoolSunnyBoi", "StaleTide", "lunarcleint"],
    ["totallynotdumb", "Borupen", "flyplague", "Novasaur", "Candias", "SkeeterYeti", "weedeet", "Stonesteve", "PaigeyPaper", "FadoraDude", "ToasterTrash", "BrownieBro", "Bradley", "Erick Animations", "TerminalRepo", "Mr. DJ"], // artnim
    ["MarStarBro", "Drop0ff", "RiverMusic", "smileysqueak", "JordoPrice", "Olimac31", "Cytrogen"],
    ["Smooth Brewed Sound", "Donald Ducc", "Brock Baker"],
    ["MIOM", "Icarus Higgs", "Luzew", "Wolf Yeying", "Exist", "wsha"], 
    ["MickeyTesticles", "Ristar", "Gally", "TheShipySea", "Xender", "JukoDuko", "DuskieWhy", "SariSorta", "LuigiOmega", "Skylar", "CableKid", "ComicVito", "MuraSaki", "PurbleBun/Polygon64", "Toknull", "Rookies Team", "MOUSE! Team", "The Funkin' Crew Inc.", "Disney", "And you!", "NICE"]
];

var creditRoles:Array<Array<String>> = [
    ["Director, Main Musician, Artist & Script Writer", "Director, Main Artist & Script Writer", "Director, Artist & Script Writer", "Co-Director, Artist"],
    ["Programming, Charter", "Programming, Charter", "Compiling Help"],
    ["Sprite Artist, Background Artist, Concept Artist & Cleanup Artist", "Sprite Artist, Animator & Charter", "Sprite Artist, Concept Artist & Animator", "Background Artist, Menu Artist & Logo Artist",
    "Sprite Artist, Animator", "Sprite Artist, Concept Artist, Menu Artist & Animator", "Sprite, Menu & Concept Artist", "Sprite Artist, Animator",
    "Sprite Artist, Concept Artist & Animator", "Sprite Artist, Animator", "Sprite Artist, Animator",
    "Sprite Artist", "Sprite Artist", "Sprite Artist, Concept Artist & Animator", "Sprite Artist", "Sprite, Thumbnail, Concept, Visualizer Artist & Animator"], // this sucks im sorry
    ["Musician", "Musician", "Musician", "Musician", "Musician", "Musician", "Musician"],
    ["Mickey Mouse VA", "Donald Duck VA", "Goofy VA"],
    ["Lead porter", "Port Playtester", "Port Playtester", "Port Playtester", "Port Playtester", "Port Playtester"], 
    ["Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks", "Special Thanks"]
];

var folderDisplayNames:Array<String> = [ // this is OBVIOUSLY for da category text
    "Directors",  "Programmers", "Art / Animation", "Musicians", "Voice Actors", "Port developer", "Special Thanks!"];

var curSelected:Int = 0;
var animSpeed:Float = 0.15;
var totalClicks:Int = 0;
var cooldown:Float = 0;
var clickCounterText, descText, roleTxt:FunkinText;
var trophy:FunkinSprite; // DONT LET THEM KNOW! Well. I Suppose it is kind of visible in its own way...

// ---------- 新增 Back 按钮相关变量 ----------
var backButton:FlxText;
var backCam:FlxCamera;
var pendingBack:Bool = false;
var mouseOverBack:Bool = false;

function postCreate() {
    CoolUtil.playMusic(Paths.music("credits"), false, 1, true, 80);
    FlxG.mouse.visible = true;

    clubhouse = new FunkinSprite(-585, -900).loadSprite(Paths.image('menus/credits/CLUBHOUSE-si'));
    clubhouse.updateHitbox();
    clubhouse.color = 0xFF636363;

    bg = new FlxBackdrop(Paths.image('menus/circle'), 0x11);
    bg.velocity.set(25, 25);
    bg.alpha = 0.05;
    bg.blend = 14;

    for (i in [clubhouse, bg]) {
        i.antialiasing = Options.antialiasing;
        i.scrollFactor.set();
        add(i);
    }

    iconGroup = new FlxTypedGroup<FunkinSprite>();
    add(iconGroup);

    var txtSettings:Array<Dynamic> = [
        [descText = new FunkinText(0, FlxG.height - 125, FlxG.width), 32, 0xFFFFFFFF, "center", 2],
        [roleText = new FunkinText(0, FlxG.height - 80, FlxG.width), 24, 0xFFCCCCCC, "center", 1.5],
        [categoryText = new FunkinText(0, 10, FlxG.width), 32, 0xFFFAE251, "center", 2],
        [leftScrollText = new FunkinText(0, 10, 0, "V"), 32, 0xFFFAE251, "center", 2],
        [rightScrollText = new FunkinText(0, 10, 0, "V"), 32, 0xFFFAE251, "center", 2],
        [clickCounterText = new FunkinText(10, FlxG.height - 35, FlxG.width), 18, 0xFFFFFFFF, "left", 2]
    ];

    for (s in txtSettings) {
        s[0].setFormat(Paths.font("WickedMouse.ttf"), s[1], s[2], s[3]);
        s[0].setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, s[4]);
        s[0].scrollFactor.set();
        add(s[0]);
    }

    for (i in [leftScrollText, rightScrollText]) {
        i.screenCenter(FlxAxes.X);
        i.x += (i == leftScrollText ? -200 : 200);
        i.angle = (i == leftScrollText ? 90 : -90);
    }
    descText.alpha = roleText.alpha = 0; 
    clickCounterText.alpha = 0.5;

    if (FlxG.save.data.totalCreditsClicks == null) FlxG.save.data.totalCreditsClicks = 0;
    totalClicks = FlxG.save.data.totalCreditsClicks;
    clickCounterText.text = "Total Clicks: " + totalClicks;

    trophy = new FunkinSprite(FlxG.width - 1100, FlxG.height - 480).loadSprite(Paths.image('menus/credits/trophy'));
    trophy.scrollFactor.set();
    trophy.antialiasing = Options.antialiasing;
    trophy.scale.set(0, 0); 
    trophy.alpha = 0;
    add(trophy);

    // ---------- 创建 Back 按钮（左下角） ----------
    backButton = new FlxText(15, FlxG.height - 100, 0, "Back", 48);
    backButton.setFormat(Paths.font("WickedMouse.ttf"), 48, FlxColor.WHITE, "left");
    backButton.antialiasing = Options.antialiasing;
    backButton.borderStyle = FlxTextBorderStyle.OUTLINE;
    backButton.borderColor = FlxColor.BLACK;
    backButton.borderSize = 3;

    backCam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
    backCam.bgColor = FlxColor.TRANSPARENT;
    backCam.zoom = 1;
    backCam.scroll.set(0, 0);
    FlxG.cameras.add(backCam);

    backButton.cameras = [backCam];
    add(backButton);

    new FlxTimer().start(2, function(tmr:FlxTimer) updateDiscordRPC(), 0);
    loadIcons();
}

function loadIcons() {
    iconGroup.clear();
    iconTimers = [];
    descText.alpha = roleText.alpha = 0;

    categoryText.text = folderDisplayNames[curSelected];
    categoryText.scale.set(1.2, 1.2);
    categoryText.alpha = 0;

    animSpeed = 0.15 + (folderCounts[curSelected] * 0.015);

    for (i in 0...folderCounts[curSelected]) {
        var icon:FunkinSprite = new FunkinSprite();
        icon.loadGraphic(Paths.image("menus/credits/" + folders[curSelected] + "/" + (i + 1)));
        icon.antialiasing = Options.antialiasing;
        icon.ID = i;

        icon.x = (FlxG.width / 2) - ((Math.min(folderCounts[curSelected], 7) - 1) * 75) + (i % 7 * 150) - (icon.width / 2);
        icon.y = (FlxG.height / 2) - ((Math.ceil(folderCounts[curSelected] / 7) - 1) * 90) + (Std.int(i / 7) * 180) - (icon.height / 2);

        icon.alpha = 0;
        icon.scale.set(0, 0);
        iconGroup.add(icon);
        
        iconTimers.push(i * (0.4 / folderCounts[curSelected]));

        new FlxTimer().start(iconTimers[i], function(tmr:FlxTimer) {
            var snd = FlxG.sound.play(Paths.sound("credits/" + FlxG.random.int(1, 3)), 0.4);
            if (snd != null) snd.pitch = FlxG.random.float(1, 1.1);
        });
    }
}

function beatHit(curBeat:Int) {
    if (curBeat % 2 == 0) {
        FlxG.camera.zoom += 0.005;
        
        bg.alpha = 0.075;
        FlxTween.tween(bg, {alpha: 0.05}, 0.25);

        clubhouse.color = 0xFF6e6e6e; 
        FlxTween.color(clubhouse, 0.75, 0xFF6e6e6e, 0xFF636363); 
    }
}

function update(elapsed:Float) {
    FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1.0, 0.025);
    clickCounterText.scale.set(FlxMath.lerp(clickCounterText.scale.x, 1, 0.05), FlxMath.lerp(clickCounterText.scale.y, 1, 0.05));

    if (controls.BACK) FlxG.switchState(new MainMenuState());

    // ---------- Back 按钮交互逻辑 ----------
    var backMousePos = FlxG.mouse.getWorldPosition(backCam);
    mouseOverBack = backButton.overlapsPoint(backMousePos);
    backButton.color = mouseOverBack ? FlxColor.BLUE : FlxColor.WHITE;

    if (FlxG.mouse.justPressed) {
        if (mouseOverBack) {
            pendingBack = true;
        }
    }
    if (FlxG.mouse.justReleased) {
        if (pendingBack && mouseOverBack) {
            goBack();
        }
        pendingBack = false;
    }

	var leftP = FlxG.keys.justPressed.LEFT || (FlxG.mouse.overlaps(leftScrollText) && FlxG.mouse.justPressed);
	var rightP = FlxG.keys.justPressed.RIGHT || (FlxG.mouse.overlaps(rightScrollText) && FlxG.mouse.justPressed);
	var scroll = FlxG.mouse.wheel;

	if (leftP || rightP || scroll != 0) {
		if (leftP) leftScrollText.scale.set(0.4, 1.5);
		if (rightP) rightScrollText.scale.set(0.4, 1.5);

		curSelected += (leftP ? -1 : 0) + (rightP ? 1 : 0) - Math.round(scroll);

		if (curSelected < 0)
			curSelected = folders.length - 1;
		if (curSelected >= folders.length)
			curSelected = 0;

		loadIcons();
	}

    var isHoveringAny:Bool = false;
    var hoveredID:Int = -1;

    categoryText.alpha = FlxMath.lerp(categoryText.alpha, 1, 0.05);
    var catS:Float = FlxMath.lerp(categoryText.scale.x, 1, 0.05);
    categoryText.scale.set(catS, catS);

    leftScrollText.scale.set(FlxMath.lerp(leftScrollText.scale.x, 1, 0.05), FlxMath.lerp(leftScrollText.scale.y, 1, 0.05));
    rightScrollText.scale.set(FlxMath.lerp(rightScrollText.scale.x, 1, 0.05), FlxMath.lerp(rightScrollText.scale.y, 1, 0.05));

    for (icon in iconGroup.members) {
        if (icon != null && FlxG.mouse.overlaps(icon)) {
            isHoveringAny = true;
            hoveredID = icon.ID;
            break;
        }
    }

    if (cooldown > 0) cooldown -= elapsed;
    if (isHoveringAny) {
        descText.text = creditNames[curSelected][hoveredID];
        descText.alpha = FlxMath.lerp(descText.alpha, 1, 0.15 * 60 * elapsed);
        if (curSelected == 4 && hoveredID == 0 && cooldown <= 0) {
            FlxG.sound.play(Paths.sound("squish/itsMe"), 1);
            cooldown = 10;
        }
        if (curSelected == 6) {
            roleText.alpha = 0; 
            roleText.text = "";
        } else {
            roleText.text = creditRoles[curSelected][hoveredID];
            roleText.alpha = FlxMath.lerp(roleText.alpha, 0.75, 0.15 * 60 * elapsed);
        }
    } else {
        descText.alpha = FlxMath.lerp(descText.alpha, 0, 0.15 * 60 * elapsed);
        roleText.alpha = FlxMath.lerp(roleText.alpha, 0, 0.15 * 60 * elapsed);
    }

    // 图标点击处理（注意不要和 Back 按钮冲突，Back 按钮在左下角，图标在中央）
    if (isHoveringAny && FlxG.mouse.justPressed) {
        var icon = iconGroup.members[hoveredID];
        
        icon.scale.set(FlxG.random.float(1.3, 1.6), FlxG.random.float(0.4, 0.7));
        icon.angle = FlxG.random.float(-15, 15);
        FlxTween.tween(icon, {angle: 0}, 0.5, {ease: FlxEase.elasticOut});

        clickCounterText.text = "Total Clicks: " + (totalClicks = ++FlxG.save.data.totalCreditsClicks);
        clickCounterText.scale.set(1, 1.2);
        if (totalClicks % 10 == 0) FlxG.save.flush();

        if (milestones.contains(totalClicks)) {
            FlxG.sound.play(Paths.sound("credits/trophyUnlock"));
            icon.scale.set(2, 0.2);
            trophy.alpha = 1;
            trophy.x = FlxG.width - 1100;
            FlxTween.tween(trophy.scale, {x: 0.5, y: 0.5}, 0.6, {ease: FlxEase.elasticOut});
            FlxTween.tween(trophy, {x: -600, alpha: 0}, 1, {ease: FlxEase.quadIn, startDelay: 1.5, onComplete: function(_) trophy.scale.set(0, 0)});
        }

        var clickSound:String = "squish/perc" + FlxG.random.int(1, 3);
        var pitch:Array<Float> = [0.9, 1.1];

        switch(curSelected + "-" + hoveredID) {
            case "0-3": clickSound = "squish/believeIt"; pitch = [1, 1.6];
            case "2-2": clickSound = "squish/gf_beep"; pitch = [1, 1.3];
            case "1-1": clickSound = "squish/meow"; pitch = [0.8, 1.3];
            case "0-2": clickSound = "squish/k" + FlxG.random.int(1, 6); pitch = [0.8, 1.2];
			case "2-1": clickSound = "squish/boru" + FlxG.random.int(1, 4);
			case "2-0": clickSound = "squish/duck";
        }

        var snd = FlxG.sound.play(Paths.sound(clickSound), 2);
        if (snd != null) snd.pitch = FlxG.random.float(pitch[0], pitch[1]);
    }

    for (i in 0...iconGroup.members.length) {
        var icon = iconGroup.members[i];
        if (icon == null) continue;
        
        if (iconTimers[i] > 0) {
            iconTimers[i] -= elapsed;
        } else {
            var speed:Float = animSpeed * 30 * elapsed;
            var targetAlpha:Float = isHoveringAny ? (FlxG.mouse.overlaps(icon) ? 1.0 : 0.5) : 1.0;
            var targetScale:Float = isHoveringAny ? (FlxG.mouse.overlaps(icon) ? 1.1 : 0.9) : 1.0;

            var sX:Float = FlxMath.lerp(icon.scale.x, targetScale, speed);
            var sY:Float = FlxMath.lerp(icon.scale.y, targetScale, speed);
            
            icon.scale.set(sX, sY);
            icon.alpha = FlxMath.lerp(icon.alpha, targetAlpha, speed);
        }
    }
}

function updateDiscordRPC() {
    var unlockedCount:Int = 0;
    for (m in milestones) {
        if (totalClicks >= m) unlockedCount++;
    }
    
    DiscordUtil.changePresence("Credits Menu", "Clicks: " + totalClicks + " (Trophies: " + unlockedCount + "/25)");
}

// ---------- 退出按钮回调 ----------
function goBack() {
    FlxG.switchState(new MainMenuState());
}