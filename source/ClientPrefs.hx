package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

@:structInit class SaveVariables
{
	public var fullscreen:Bool = false;
	public var downScroll:Bool = false;
	public var showFPS:Bool = true;
	public var autoPause:Bool = true;
	public var variableTimestep:Bool = true;
	public var antialiasing:Bool = true;
	public var particlePercentage:Float = 0.5;
	public var shaders:Bool = true;
	public var framerate:Int = 60;
	public var hudAlpha:Float = 1;
	public var noteOffset:Int = 0;
	public var timeBarType:String = 'Time Left';
	public var firstIntro:Bool = true;
	public var totems:Int = 0;
	public var healthBarAlpha:Float = 1;
	public var hitsoundVolume:Float = 0;
	public var checkForUpdates:Bool = true;
	public var clientVersion:Float = 1.0;
	public var hitWindow:Float = 166.7;
}

class ClientPrefs
{
	public static var data:SaveVariables = {};
	public static var defaultData:SaveVariables = {};

	// Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		// Key Bind, Name for ControlsSubState
		'note_up' => [W, UP],
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_right' => [D, RIGHT],
		'jump' => [SPACE],
		'ui_up' => [W, UP],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R],
		'taunt' => [X],
		'attack' => [J],
		'volume_mute' => [ZERO],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
	];
	public static var gamepadBinds:Map<String, Array<FlxGamepadInputID>> = [
		'note_up' => [LEFT_STICK_DIGITAL_UP, DPAD_UP],
		'note_left' => [LEFT_STICK_DIGITAL_LEFT, DPAD_LEFT],
		'note_down' => [LEFT_STICK_DIGITAL_DOWN, DPAD_DOWN],
		'note_right' => [LEFT_STICK_DIGITAL_RIGHT, DPAD_RIGHT],
		'jump' => [A],
		'ui_up' => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
		'ui_left' => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
		'ui_down' => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
		'ui_right' => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
		'accept' => [A, START],
		'back' => [B],
		'pause' => [START],
		'reset' => [BACK],
		'taunt' => [LEFT_STICK_CLICK],
		'attack' => [RIGHT_SHOULDER]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;
	public static var defaultButtons:Map<String, Array<FlxGamepadInputID>> = null;

	public static function resetKeys(controller:Null<Bool> = null) // Null = both, False = Keyboard, True = Controller
	{
		if (controller != true)
			for (key in keyBinds.keys())
				if (defaultKeys.exists(key))
					keyBinds.set(key, defaultKeys.get(key).copy());

		if (controller != false)
			for (button in gamepadBinds.keys())
				if (defaultButtons.exists(button))
					gamepadBinds.set(button, defaultButtons.get(button).copy());
	}

	public static function clearInvalidKeys(key:String)
	{
		var keyBind:Array<FlxKey> = keyBinds.get(key);
		var gamepadBind:Array<FlxGamepadInputID> = gamepadBinds.get(key);
		while (keyBind != null && keyBind.contains(NONE))
			keyBind.remove(NONE);
		while (gamepadBind != null && gamepadBind.contains(NONE))
			gamepadBind.remove(NONE);
	}

	public static function loadDefaultKeys()
	{
		defaultKeys = keyBinds.copy();
		defaultButtons = gamepadBinds.copy();
	}

	public static function saveSettings()
	{
		for (key in Reflect.fields(data))
			Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));

		FlxG.save.flush();

		// Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		var save:FlxSave = new FlxSave();
		save.bind('controls_v3', CoolUtil.getSavePath());
		save.data.keyboard = keyBinds;
		save.data.gamepad = gamepadBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs()
	{
		for (key in Reflect.fields(data))
			if (key != 'gameplaySettings' && Reflect.hasField(FlxG.save.data, key))
				Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));

		if (Main.fpsVar != null)
			Main.fpsVar.visible = data.showFPS;

		#if !switch
		if (FlxG.save.data.autoPause != null)
		{
			FlxG.autoPause = ClientPrefs.data.autoPause;
		}
		#if !html5
		if (FlxG.save.data.framerate == null)
		{
			final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
			data.framerate = refreshRate;
		}
		#end
		#if !mobile
		{
			if (FlxG.save.data.fullscreen != null)
				FlxG.fullscreen = ClientPrefs.data.fullscreen;
		}
		#end
		#end

		if (data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = data.framerate;
			FlxG.drawFramerate = data.framerate;
		}
		else
		{
			FlxG.drawFramerate = data.framerate;
			FlxG.updateFramerate = data.framerate;
		}

		// flixel automatically saves your volume!
		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		// controls on a separate save file
		var save:FlxSave = new FlxSave();
		save.bind('controls_v3', CoolUtil.getSavePath());
		if (save != null)
		{
			if (save.data.keyboard != null)
			{
				var loadedControls:Map<String, Array<FlxKey>> = save.data.keyboard;
				for (control => keys in loadedControls)
					if (keyBinds.exists(control))
						keyBinds.set(control, keys);
			}
			if (save.data.gamepad != null)
			{
				var loadedControls:Map<String, Array<FlxGamepadInputID>> = save.data.gamepad;
				for (control => keys in loadedControls)
					if (gamepadBinds.exists(control))
						gamepadBinds.set(control, keys);
			}
			reloadVolumeKeys();
		}
	}

	public static function reloadVolumeKeys()
	{
		IntroState.muteKeys = keyBinds.get('volume_mute').copy();
		IntroState.volumeDownKeys = keyBinds.get('volume_down').copy();
		IntroState.volumeUpKeys = keyBinds.get('volume_up').copy();
		toggleVolumeKeys(true);
	}

	public static function toggleVolumeKeys(?turnOn:Bool = true)
	{
		FlxG.sound.muteKeys = turnOn ? IntroState.muteKeys : [];
		FlxG.sound.volumeDownKeys = turnOn ? IntroState.volumeDownKeys : [];
		FlxG.sound.volumeUpKeys = turnOn ? IntroState.volumeUpKeys : [];
	}
}
