package objects;

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
		The current frame rate, expressed as frames-per-second.
	**/
	public static var currentFPS(default, null):Int;

	/**
		The number of frames rendered in the last second.
	**/
	@:noCompletion private static var times:Array<Int> = [];

	/**
		The number of milliseconds to wait before updating the TextField. 
	**/
	public static var updateInterval:Int = 250; // keep this high

	public function new(x:Float = 0, y:Float = 0)
	{
		super();

		this.x = x;
		this.y = y;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("Monocraft", 12, 0xFFFFFF);
		multiline = false;
		wordWrap = false;
		autoSize = LEFT;
		background = true;
		backgroundColor = 0xFF000000;
		alpha = 0.8;
		cacheAsBitmap = false;
		addEventListener(Event.DEACTIVATE, _ -> focus = false);
		addEventListener(Event.ACTIVATE, _ -> focus = true);
	}

	private static var then:Int = 0;
	private static var now:Int = 0;
	private static var focus:Bool = true;

	private override function __enterFrame(deltaTime:Float):Void
	{
		if (!focus || !visible)
			return;

		now = lime.system.System.getTimer();
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();

		if (now - then < updateInterval)
			return;

		then = now;
		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
		text = 'FPS: $currentFPS[${Std.int(1000 / currentFPS)}ms]\nRAM: ${flixel.util.FlxStringUtil.formatBytes(System.totalMemory)}';
		// The frametime is currently a lie. Using deltaTime causes the TextField to regen more frequently, which is hideously memory intensive.
	}
}
