package;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

class Controls
{
	// Keeping same use cases on stuff for it to be easier to understand/use
	// I'd have removed it but this makes it a lot less annoying to use in my opinion
	// Pressed buttons (directions)
	public static var UI_UP_P(get, never):Bool;
	public static var UI_DOWN_P(get, never):Bool;
	public static var UI_LEFT_P(get, never):Bool;
	public static var UI_RIGHT_P(get, never):Bool;
	public static var NOTE_UP_P(get, never):Bool;
	public static var NOTE_DOWN_P(get, never):Bool;
	public static var NOTE_LEFT_P(get, never):Bool;
	public static var NOTE_RIGHT_P(get, never):Bool;

	static function get_UI_UP_P()
		return FlxG.mouse.wheel > 0 || justPressed('ui_up');

	static function get_UI_DOWN_P()
		return FlxG.mouse.wheel < 0 || justPressed('ui_down');

	static function get_UI_LEFT_P()
		return justPressed('ui_left');

	static function get_UI_RIGHT_P()
		return justPressed('ui_right');

	static function get_NOTE_UP_P()
		return justPressed('note_up');

	static function get_NOTE_DOWN_P()
		return justPressed('note_down');

	static function get_NOTE_LEFT_P()
		return justPressed('note_left');

	static function get_NOTE_RIGHT_P()
		return justPressed('note_right');

	// Held buttons (directions)
	public static var UI_UP(get, never):Bool;
	public static var UI_DOWN(get, never):Bool;
	public static var UI_LEFT(get, never):Bool;
	public static var UI_RIGHT(get, never):Bool;
	public static var NOTE_UP(get, never):Bool;
	public static var NOTE_DOWN(get, never):Bool;
	public static var NOTE_LEFT(get, never):Bool;
	public static var NOTE_RIGHT(get, never):Bool;

	static function get_UI_UP()
		return pressed('ui_up');

	static function get_UI_DOWN()
		return pressed('ui_down');

	static function get_UI_LEFT()
		return pressed('ui_left');

	static function get_UI_RIGHT()
		return pressed('ui_right');

	static function get_NOTE_UP()
		return pressed('note_up');

	static function get_NOTE_DOWN()
		return pressed('note_down');

	static function get_NOTE_LEFT()
		return pressed('note_left');

	static function get_NOTE_RIGHT()
		return pressed('note_right');

	// Released buttons (directions)
	public static var UI_UP_R(get, never):Bool;
	public static var UI_DOWN_R(get, never):Bool;
	public static var UI_LEFT_R(get, never):Bool;
	public static var UI_RIGHT_R(get, never):Bool;
	public static var NOTE_UP_R(get, never):Bool;
	public static var NOTE_DOWN_R(get, never):Bool;
	public static var NOTE_LEFT_R(get, never):Bool;
	public static var NOTE_RIGHT_R(get, never):Bool;

	static function get_UI_UP_R()
		return justReleased('ui_up');

	static function get_UI_DOWN_R()
		return justReleased('ui_down');

	static function get_UI_LEFT_R()
		return justReleased('ui_left');

	static function get_UI_RIGHT_R()
		return justReleased('ui_right');

	static function get_NOTE_UP_R()
		return justReleased('note_up');

	static function get_NOTE_DOWN_R()
		return justReleased('note_down');

	static function get_NOTE_LEFT_R()
		return justReleased('note_left');

	static function get_NOTE_RIGHT_R()
		return justReleased('note_right');

	// Pressed buttons (others)
	public static var ACCEPT(get, never):Bool;
	public static var BACK(get, default):Bool;
	public static var PAUSE(get, never):Bool;
	public static var RESET(get, never):Bool;
	public static var TAUNT(get, never):Bool;
	public static var JUMP(get, never):Bool;
	public static var ATTACK(get, never):Bool;

	static function get_ACCEPT()
		return justPressed('accept');

	static function get_BACK() // very hacky, change later!!!
	{
		if (BACK)
		{
			BACK = false;
			return true;
		}
		return justPressed('back');
	}

	static function get_PAUSE()
		return justPressed('pause');

	static function get_RESET()
		return justPressed('reset');

	static function get_TAUNT()
		return justPressed('taunt');

	static function get_JUMP()
		return justPressed('jump');

	static function get_ATTACK()
		return FlxG.mouse.justPressed || justPressed('attack');

	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	// Gamepad & Keyboard stuff
	public static var keyboardBinds:Map<String, Array<FlxKey>>;
	public static var gamepadBinds:Map<String, Array<FlxGamepadInputID>>;

	public static function justPressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustPressed(keyboardBinds[key]) == true);
		if (result)
			controllerMode = false;

		return result || _myGamepadJustPressed(gamepadBinds[key]) == true;
	}

	public static function pressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyPressed(keyboardBinds[key]) == true);
		if (result)
			controllerMode = false;

		return result || _myGamepadPressed(gamepadBinds[key]) == true;
	}

	public static function justReleased(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustReleased(keyboardBinds[key]) == true);
		if (result)
			controllerMode = false;

		return result || _myGamepadJustReleased(gamepadBinds[key]) == true;
	}

	public static var controllerMode:Bool = false;

	static function _myGamepadJustPressed(keys:Array<FlxGamepadInputID>):Bool
	{
		if (keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyJustPressed(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}

	static function _myGamepadPressed(keys:Array<FlxGamepadInputID>):Bool
	{
		if (keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyPressed(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}

	static function _myGamepadJustReleased(keys:Array<FlxGamepadInputID>):Bool
	{
		if (keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyJustReleased(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}

	public static function init()
	{
		keyboardBinds = ClientPrefs.keyBinds;
		gamepadBinds = ClientPrefs.gamepadBinds;
	}
}
