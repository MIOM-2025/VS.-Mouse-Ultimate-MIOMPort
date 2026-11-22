package funkin.backend.system;

import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.ui.FlxSoundTray;
import funkin.backend.assets.AssetSource;
import funkin.backend.assets.AssetsLibraryList;
import funkin.backend.assets.ModsFolder;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.system.framerate.SystemInfo;
import funkin.backend.system.modules.*;
import funkin.backend.utils.ThreadUtil;
import funkin.editors.SaveWarning;
import funkin.options.PlayerSettings;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.text.TextFormat;
import openfl.utils.AssetLibrary;
#if sys
import sys.FileSystem;
import sys.io.File;
#elseif js
import js.html.FileSystem;
import js.html.File;
#end
#if android
import android.content.Context;
import android.os.Build;
#end

class Main extends Sprite
{
	public static var instance:Main;

	public static var modToLoad:String = null;
	public static var forceGPUOnlyBitmapsOff:Bool = #if (desktop || mobile) false #else true #end;
	public static var noTerminalColor:Bool = false;
	public static var verbose:Bool = false;

	public static var scaleMode:FunkinRatioScaleMode;
	public static var framerateSprite:Framerate;

	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels).
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var game:FunkinGame;

	/**
	 * The time since the game was focused last time in seconds.
	 */
	public static var timeSinceFocus(get, never):Float;
	public static var time:Int = 0;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function preInit() {
		funkin.backend.utils.NativeAPI.registerAsDPICompatible();
		funkin.backend.system.CommandLineHandler.parseCommandLine(Sys.args());
		funkin.backend.system.Main.fixWorkingDirectory();
	}

	public function new()
	{
		super();

		instance = this;

		#if mobile
		#if android
		MobileUtil.getPermissions();
		MobileUtil.initDirectory();
		#end
		Sys.setCwd(MobileUtil.getAssetDirectory());
		// Install the bundled assets/mods into the writable storage directory on first
		// launch (or after an update), showing a progress bar while it runs.
		MobileUtil.registerFonts();
		startAssetInstall();
		return;
		#end

		finishInit();
	}

	function finishInit():Void
	{
		CrashHandler.init();

		#if !web framerateSprite = new Framerate(); #end

		addChild(game = new FunkinGame(gameWidth, gameHeight, MainState, Options.framerate, Options.framerate, skipSplash, startFullscreen));

		#if !web
		addChild(framerateSprite);
		SystemInfo.init();
		#end
		#if android FlxG.android.preventDefaultKeys = [BACK]; #end
	}

	#if mobile
	var __installRoot:String = "";
	var __installList:Array<String> = [];
	var __installIndex:Int = 0;
	var __installTotal:Int = 0;
	var __installBar:openfl.display.Shape;
	var __installBack:openfl.display.Shape;
	var __installLabel:openfl.text.TextField;

	function __installFontName():String
	{
		try {
			var f = openfl.Assets.getFont("assets/fonts/WickedMouse.ttf");
			if (f != null) return f.fontName;
		} catch (e:Dynamic) {}
		return "sans-serif";
	}

		function __assetInstallStamp():String
	{
		try {
			var t = openfl.Assets.getText("assets/data/installStamp.txt");
			if (t != null && t.length > 0) return StringTools.trim(t);
		} catch (e:Dynamic) {}
		try {
			var b = openfl.Assets.getBytes("assets/data/installStamp.txt");
			if (b != null && b.length > 0) return StringTools.trim(b.toString());
		} catch (e:Dynamic) {}
		return "";
	}

	function __storedInstallStamp():String
	{
		try {
			var p = MobileUtil.getDirectory() + "installStamp.txt";
			if (sys.FileSystem.exists(p)) return StringTools.trim(sys.io.File.getContent(p));
		} catch (e:Dynamic) {}
		return "";
	}

	function startAssetInstall():Void
		{
		var wantedStamp = __assetInstallStamp();
		if (wantedStamp != "" && wantedStamp == __storedInstallStamp()) {
			// Already copied this exact build once, no need to walk every asset again.
			finishInit();
			return;
		}

		var stage = openfl.Lib.current.stage;
		__installBack = new openfl.display.Shape();
		__installBar = new openfl.display.Shape();
		__installLabel = new openfl.text.TextField();
		var installFormat = new openfl.text.TextFormat(__installFontName(), 26, 0xFFFFFF);
		installFormat.align = openfl.text.TextFormatAlign.CENTER;
		__installLabel.defaultTextFormat = installFormat;
		__installLabel.width = stage.stageWidth;
		__installLabel.y = stage.stageHeight * 0.5 - 48;

		addChild(__installBack);
		addChild(__installLabel);
		addChild(__installBar);

		__installRoot = MobileUtil.getAssetDirectory();
		__installList = [];
		for (id in openfl.Assets.list())
		{
			var clean = id;
			var ci = clean.indexOf(":");
			if (ci != -1) clean = clean.substring(ci + 1);
			if (StringTools.startsWith(clean, "assets/") || StringTools.startsWith(clean, "mods/") || StringTools.startsWith(clean, "addons/"))
				__installList.push(id);
		}
		__installTotal = __installList.length;
		__installIndex = 0;
		drawInstallBar(0);

		stage.addEventListener(openfl.events.Event.ENTER_FRAME, __installStep);
	}

	function __installStep(_):Void
	{
		var i:Int = 0;
		while (i < 20 && __installIndex < __installTotal)
		{
			MobileUtil.installAsset(__installList[__installIndex++], __installRoot);
			i++;
		}
		drawInstallBar(__installTotal == 0 ? 1 : __installIndex / __installTotal);

		if (__installIndex >= __installTotal)
		{
			openfl.Lib.current.stage.removeEventListener(openfl.events.Event.ENTER_FRAME, __installStep);
			MobileUtil.writeModsVersion();
			MobileUtil.writeCopyLog();
			try {
				var st = __assetInstallStamp();
				if (st != "") sys.io.File.saveContent(MobileUtil.getDirectory() + "installStamp.txt", st);
			} catch (e:Dynamic) {}
			removeChild(__installBack);
			removeChild(__installLabel);
			removeChild(__installBar);
			finishInit();
		}
	}

	function drawInstallBar(ratio:Float):Void
	{
		var stage = openfl.Lib.current.stage;
		var w = stage.stageWidth, h = stage.stageHeight;
		var barW = w * 0.6, barH = 18;
		var bx = (w - barW) / 2, by = h * 0.5;

		__installBack.graphics.clear();
		__installBack.graphics.beginFill(0x000000);
		__installBack.graphics.drawRect(0, 0, w, h);
		__installBack.graphics.endFill();

		__installBar.graphics.clear();
		if (ratio > 0)
		{
			__installBar.graphics.beginFill(0xFFFFFF);
			__installBar.graphics.drawRect(bx, by, barW * ratio, barH);
			__installBar.graphics.endFill();
		}

		__installLabel.text = "Installing assets... " + __installIndex + " / " + __installTotal + " (" + Std.int(ratio * 100) + "%)";
	}
	#end

	@:dox(hide)
	public static var audioDisconnected:Bool = false;

	public static var changeID:Int = 0;
	public static var pathBack = #if (windows || linux)
			"../../../../"
		#elseif mac
			"../../../../../../../"
		#else
			"../../../../"
		#end;
	public static var startedFromSource:Bool = #if TEST_BUILD true #else false #end;

	// DEPRECATED
	@:dox(hide) public static function execAsync(func:Void->Void) ThreadUtil.execAsync(func);

	private static function getTimer():Int {
		return time = Lib.getTimer();
	}

	public static function loadGameSettings() {
		WindowUtils.init();
		SaveWarning.init();
		MemoryUtil.init();
		@:privateAccess
		FlxG.game.getTimer = getTimer;
		FunkinCache.init();
		Paths.assetsTree = new AssetsLibraryList();

		#if UPDATE_CHECKING
		funkin.backend.system.updating.UpdateUtil.init();
		#end
		ShaderResizeFix.init();
		Logs.init();
		Paths.init();

		hscript.Interp.importRedirects = funkin.backend.scripting.Script.getDefaultImportRedirects();

		#if GLOBAL_SCRIPT
		funkin.backend.scripting.GlobalScript.init();
		#end

		var lib = new AssetLibrary();
		@:privateAccess
		lib.__proxy = Paths.assetsTree;
		Assets.registerLibrary('default', lib);

		funkin.options.PlayerSettings.init();
		Options.load();

		FlxG.fixedTimestep = false;

		if (!funkin.backend.system.Controls.instance.mobileC) FlxG.scaleMode = scaleMode = new FunkinRatioScaleMode();

		Conductor.init();
		AudioSwitchFix.init();
		EventManager.init();
		FlxG.signals.focusGained.add(onFocus);
		FlxG.signals.preStateSwitch.add(onStateSwitch);
		FlxG.signals.postStateSwitch.add(onStateSwitchPost);
		FlxG.signals.postUpdate.add(onUpdate);

		FlxG.mouse.useSystemCursor = !Controls.instance.mobileC;
		#if DARK_MODE_WINDOW
		if(funkin.backend.utils.NativeAPI.hasVersion("Windows 10")) funkin.backend.utils.NativeAPI.redrawWindowHeader();
		#end

		ModsFolder.init();
		#if MOD_SUPPORT
		if (FileSystem.exists("mods/autoload.txt"))
			modToLoad = File.getContent("mods/autoload.txt").trim();

		// VMU is bundled with the app: fall back to it when autoload.txt is missing.
		if (modToLoad == null && FileSystem.exists("mods/VMU/data/config/modpack.ini"))
			modToLoad = "VMU";

		ModsFolder.switchMod(modToLoad.getDefault(Options.lastLoadedMod));
		#end

		initTransition();
	}

	public static function refreshAssets() @:privateAccess {
		FunkinCache.instance.clearSecondLayer();

		var game = FlxG.game;
		var daSndTray = Type.createInstance(game._customSoundTray = funkin.menus.ui.FunkinSoundTray, []);
		var index:Int = game.numChildren - 1;

		if(game.soundTray != null)
		{
			var newIndex:Int = game.getChildIndex(game.soundTray);
			if(newIndex != -1) index = newIndex;
			game.removeChild(game.soundTray);
			game.soundTray.__cleanup();
		}

		game.addChildAt(game.soundTray = daSndTray, index);
	}

	public static function initTransition() {
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xFF000000, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xFF000000, 0.7, new FlxPoint(0, 1),
			{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
	}

	public static function onFocus() {
		_tickFocused = FlxG.game.ticks;
	}

	private static function onStateSwitch() {
	  if (!funkin.backend.system.Controls.instance.mobileC)
		scaleMode.resetSize();
	}

	public static function onUpdate() {
		if (PlayerSettings.solo.controls.DEV_CONSOLE)
			NativeAPI.allocConsole();

		if (PlayerSettings.solo.controls.FPS_COUNTER)
			Framerate.debugMode = (Framerate.debugMode + 1) % 3;
	}

	private static function onStateSwitchPost() {
		// manual asset clearing since base openfl one does'nt clear lime one
		// does'nt clear bitmaps since flixel fork does it auto

		@:privateAccess {
			// clear uint8 pools
			for(length=>pool in openfl.display3D.utils.UInt8Buff._pools) {
				for(b in pool.clear())
					b.destroy();
			}

			openfl.display3D.utils.UInt8Buff._pools.clear();
		}

		MemoryUtil.clearMajor();
	}

	public static var noCwdFix:Bool = false;
	public static function fixWorkingDirectory() {
		#if windows
		if (!noCwdFix && !sys.FileSystem.exists('manifest/default.json')) {
			Sys.setCwd(haxe.io.Path.directory(Sys.programPath()));
		}
		#elseif switch
		Sys.setCwd(haxe.io.Path.addTrailingSlash(openfl.filesystem.File.applicationStorageDirectory.nativePath));
		#end
	}

	private static var _tickFocused:Float = 0;
	public static function get_timeSinceFocus():Float {
		return (FlxG.game.ticks - _tickFocused) / 1000;
	}
}
