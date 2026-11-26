package funkin.game.cutscenes;

import funkin.backend.scripting.events.NameEvent;
import funkin.menus.PauseSubState;

/**
 * Substate made for cutscenes.
 */
class Cutscene extends MusicBeatSubstate {
	var __callback:Void->Void;
	var game:PlayState = PlayState.instance;

	public var paused:Bool = false;
	public var pauseItems:Array<String>;
	public var pausable:Bool;
	public var skippable(default, set):Bool;

	public function set_skippable(val:Bool):Bool {
		if (!val) pauseItems.remove('Skip Cutscene');
		else if (!pauseItems.contains('Skip Cutscene')) pauseItems.insert(1, 'Skip Cutscene');
		return skippable = val;
	}

	public function new(callback:Void->Void, allowPause:Bool = true, canSkip:Bool = true) {
		super();
		canOpenCustomTransition = true;

		__callback = callback;

		pauseItems = Flags.DEFAULT_CUTSCENE_PAUSE_ITEMS;
		pausable = allowPause;
		skippable = canSkip;

		// Keep the mobile pause button on top of the cutscene so it stays visible and clickable.
		if (game != null && game.mobilePauseButton != null && game.mobilePauseButton.cameras != null && game.mobilePauseButton.cameras.length > 0) {
			var cam = game.mobilePauseButton.cameras[0];
			if (FlxG.cameras.list.contains(cam)) {
				FlxG.cameras.remove(cam, false);
				FlxG.cameras.add(cam, false);
			}
		}
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (pauseCheck()) pauseCutscene();
	}

	public function pauseCheck():Bool
		return (controls.PAUSE || (game != null && game.mobilePauseButton != null && game.mobilePauseButton.justPressed)) && pausable;

	var _before:Array<Bool> = [false, true];
	public function pauseCutscene() {
		_before = [game.persistentUpdate, game.persistentDraw];
		game.persistentUpdate = persistentUpdate = false;
		game.persistentDraw = persistentDraw = true;
		paused = true;

		openSubState(new PauseSubState(pauseItems, selectPauseOption));
	}

	public override function closeSubState() {
		if (paused) {
			game.persistentUpdate = _before[0];
			game.persistentDraw = _before[1];
			paused = false;
		}

		super.closeSubState();
	}

	public function onSkipCutscene(event:NameEvent) close();
	public function onRestartCutscene(event:NameEvent) event.name = "Restart Song";  // Making the whole PlayState restart just for precaution  - Nex
	public function onResumeCutscene(event:NameEvent) event.name = "Resume";

	public function selectPauseOption(event:NameEvent) {
		switch(event.name) {
			case 'Skip Cutscene': onSkipCutscene(event);
			case 'Restart Cutscene': onRestartCutscene(event);
			case 'Resume Cutscene': onResumeCutscene(event);
		}

		return true;
	}

	public override function close() {
		canOpenCustomTransition = false;
		__callback();
		super.close();
	}
}