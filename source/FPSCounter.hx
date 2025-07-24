package;

import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;
import openfl.events.Event;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSCounter extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public static var currentFPS(default, null):Int;

	/**
		Represents the number of frames 
	**/
	@:noCompletion private static var times:Array<Int> = [];

	/**
		The number of milliseconds to wait before updating the TextField. 
	**/
	public static var updateFrequency:Int = 250; // something is happening

	public function new(x:Float = 0, y:Float = 0, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;
		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("Monocraft", 12, color);
		autoSize = LEFT;
		multiline = true;
		background = true;
		backgroundColor = 0x6F000000;
		alpha = 0.8;
		cacheAsBitmap = true;
		addEventListener(Event.DEACTIVATE, onFocusLost);
		addEventListener(Event.ACTIVATE, onFocusRegained);
	}

	private static function onFocusLost(event:Event):Void
	{
		focus = false;
	}

	private static function onFocusRegained(event:Event):Void
	{
		focus = true;
	}

	private static var focus:Bool = false;
	private static var then:Int = 0;

	private override function __enterFrame(deltaTime:Float):Void
	{
		if (focus)
		{
			final now:Int = lime.system.System.getTimer();
			times.push(now);
			while (times[0] < now - 1000)
				times.shift();

			if (now - then < updateFrequency)
			{
				return;
			}
			then = now;
			currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
			text = 'FPS: $currentFPS[${deltaTime}ms]\nRAM: ${flixel.util.FlxStringUtil.formatBytes(System.totalMemory)}';
		}
	}
}
