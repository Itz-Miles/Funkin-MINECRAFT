package objects;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.math.FlxPoint;

using StringTools;

enum Alignment
{
	LEFT;
	CENTERED;
	RIGHT;
}

class Alphabet extends FlxText
{
	public var isMenuItem:Bool = false;
	public var targetY(default, set):Int = 0;
	public var changeX:Bool = true;
	public var changeY:Bool = true;
	public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0);

	/*
		public var duration:Float = 1;
		public var ease:EaseFunction = FlxEase.bounceOut;

		var _timeElapsed:Float;
		var _prevTargetY:Int;
	 */
	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = true)
	{
		super(x, y, 0, text, 48);
		antialiasing = false;
		startPosition.x = x;
		startPosition.y = y;
		this.bold = bold;
		if (bold)
		{
			setFormat(Paths.font("Monocraft.ttf"), 48, FlxG.camera.bgColor, CENTER, OUTLINE, 0xffffffff);
			borderSize = 4;
		}
		else
		{
			setFormat(Paths.font("Monocraft.ttf"), 48, 0xffffffff, CENTER, OUTLINE, 0xffffffff);
			borderSize = 1;
		}
	}

	public function clearLetters()
	{
		text = "";
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			/*
					_timeElapsed += elapsed;

					if (_timeElapsed > duration)
						_timeElapsed = duration;


				var lerpVal:Float = ease(_timeElapsed / duration);
			 */
			/*
				if (changeX)
					x = FlxMath.lerp((_prevTargetY * distancePerItem.x) + startPosition.x, (targetY * distancePerItem.x) + startPosition.x, lerpVal);
				if (changeY)
					y = FlxMath.lerp((_prevTargetY * 1.3 * distancePerItem.y) + startPosition.y, (targetY * 1.3 * distancePerItem.y) + startPosition.y, lerpVal);
			 */

			var lerpVal:Float = FlxMath.bound(elapsed * 9.6, 0, 1);
			if (changeX)
				x = FlxMath.lerp(x, (targetY * distancePerItem.x) + startPosition.x, lerpVal);
			if (changeY)
				y = FlxMath.lerp(y, (targetY * 1.3 * distancePerItem.y) + startPosition.y, lerpVal);
		}
		super.update(elapsed);
	}

	public function snapToPosition()
	{
		if (isMenuItem)
		{
			if (changeX)
				x = (targetY * distancePerItem.x) + startPosition.x;
			if (changeY)
				y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
		}
	}

	function set_targetY(value:Int):Int
	{
		/*
			_timeElapsed = 0;
			_prevTargetY = targetY;
		 */
		return targetY = value;
	}
}
