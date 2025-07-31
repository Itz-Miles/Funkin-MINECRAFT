package;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

class Controls
{
	// Keeping same use cases on stuff for it to be easier to understand/use
	// I'd have removed it but this makes it a lot less annoying to use in my opinion
	// Pressed buttons (directions)
	public var UI_UP_P(get, never):Bool;
	public var UI_DOWN_P(get, never):Bool;
	public var UI_LEFT_P(get, never):Bool;
	public var UI_RIGHT_P(get, never):Bool;
	public var NOTE_UP_P(get, never):Bool;
	public var NOTE_DOWN_P(get, never):Bool;
	public var NOTE_LEFT_P(get, never):Bool;
	public var NOTE_RIGHT_P(get, never):Bool;

	function get_UI_UP_P()
		return FlxG.mouse.wheel > 0 || justPressed('ui_up');

	function get_UI_DOWN_P()
		return FlxG.mouse.wheel < 0 || justPressed('ui_down');

	function get_UI_LEFT_P()
		return justPressed('ui_left');

	function get_UI_RIGHT_P()
		return justPressed('ui_right');

	function get_NOTE_UP_P()
		return justPressed('note_up');

	function get_NOTE_DOWN_P()
		return justPressed('note_down');

	function get_NOTE_LEFT_P()
		return justPressed('note_left');

	function get_NOTE_RIGHT_P()
		return justPressed('note_right');

	// Held buttons (directions)
	public var UI_UP(get, never):Bool;
	public var UI_DOWN(get, never):Bool;
	public var UI_LEFT(get, never):Bool;
	public var UI_RIGHT(get, never):Bool;
	public var NOTE_UP(get, never):Bool;
	public var NOTE_DOWN(get, never):Bool;
	public var NOTE_LEFT(get, never):Bool;
	public var NOTE_RIGHT(get, never):Bool;

	function get_UI_UP()
		return pressed('ui_up');

	function get_UI_DOWN()
		return pressed('ui_down');

	function get_UI_LEFT()
		return pressed('ui_left');

	function get_UI_RIGHT()
		return pressed('ui_right');

	function get_NOTE_UP()
		return pressed('note_up');

	function get_NOTE_DOWN()
		return pressed('note_down');

	function get_NOTE_LEFT()
		return pressed('note_left');

	function get_NOTE_RIGHT()
		return pressed('note_right');

	// Released buttons (directions)
	public var UI_UP_R(get, never):Bool;
	public var UI_DOWN_R(get, never):Bool;
	public var UI_LEFT_R(get, never):Bool;
	public var UI_RIGHT_R(get, never):Bool;
	public var NOTE_UP_R(get, never):Bool;
	public var NOTE_DOWN_R(get, never):Bool;
	public var NOTE_LEFT_R(get, never):Bool;
	public var NOTE_RIGHT_R(get, never):Bool;

	function get_UI_UP_R()
		return justReleased('ui_up');

	function get_UI_DOWN_R()
		return justReleased('ui_down');

	function get_UI_LEFT_R()
		return justReleased('ui_left');

	function get_UI_RIGHT_R()
		return justReleased('ui_right');

	function get_NOTE_UP_R()
		return justReleased('note_up');

	function get_NOTE_DOWN_R()
		return justReleased('note_down');

	function get_NOTE_LEFT_R()
		return justReleased('note_left');

	function get_NOTE_RIGHT_R()
		return justReleased('note_right');

	// Pressed buttons (others)
	public var ACCEPT(get, never):Bool;
	public var BACK(get, never):Bool;
	public var PAUSE(get, never):Bool;
	public var RESET(get, never):Bool;
	public var TAUNT(get, never):Bool;
	public var JUMP(get, never):Bool;
	public var ATTACK(get, never):Bool;

	function get_ACCEPT()
		return justPressed('accept');

	function get_BACK()
		return justPressed('back');

	function get_PAUSE()
		return justPressed('pause');

	function get_RESET()
		return justPressed('reset');

	function get_TAUNT()
		return justPressed('taunt');

	function get_JUMP()
		return justPressed('jump');

	function get_ATTACK()
		return FlxG.mouse.justPressed || justPressed('attack');

	// Gamepad & Keyboard stuff
	public var keyboardBinds:Map<String, Array<FlxKey>>;
	public var gamepadBinds:Map<String, Array<FlxGamepadInputID>>;

	public function justPressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustPressed(keyboardBinds[key]) == true);
		if (result)
			controllerMode = false;

		return result || _myGamepadJustPressed(gamepadBinds[key]) == true;
	}

	public function pressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyPressed(keyboardBinds[key]) == true);
		if (result)
			controllerMode = false;

		return result || _myGamepadPressed(gamepadBinds[key]) == true;
	}

	public function justReleased(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustReleased(keyboardBinds[key]) == true);
		if (result)
			controllerMode = false;

		return result || _myGamepadJustReleased(gamepadBinds[key]) == true;
	}

	public var controllerMode:Bool = false;

	function _myGamepadJustPressed(keys:Array<FlxGamepadInputID>):Bool
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

	function _myGamepadPressed(keys:Array<FlxGamepadInputID>):Bool
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

	function _myGamepadJustReleased(keys:Array<FlxGamepadInputID>):Bool
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

	// IGNORE THESE
	public static var instance:Controls;

	public function new()
	{
		// nothing, haxe just wants it
	}

	public static function init()
	{
		instance = new Controls();
		instance.keyboardBinds = ClientPrefs.keyBinds;
		instance.gamepadBinds = ClientPrefs.gamepadBinds;
	}
}
