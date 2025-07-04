package;

import flixel.FlxObject;
import flixel.text.FlxText;

class ToolTip extends FlxText
{
	public var targetSpr(default, set):FlxObject;
	public var above:Bool = true;

	var duration:Float = 3.0;

	var showTimer:Float = 0;

	override public function new(x:Float, y:Float, target:FlxObject, above:Bool, duration:Float)
	{
		super(x, y, this.width, "text");
		setFormat(Paths.font('Monocraft.ttf'), 24, 0xFFFFFF, CENTER, OUTLINE_FAST, 0xAA000000);
		borderSize = 48;
		targetSpr = target;
		this.above = above;
		showTimer = 0;
		this.duration = duration;
	}

	function set_targetSpr(object:FlxObject)
	{
		if (object != null)
		{
			if (!above)
			{
				x = object.x + (object.width * 0.5) - (width * 0.5);
				y = object.y + object.height + 1;
			}
			else
			{
				x = object.x + (object.width * 0.5) - (width * 0.5);
				y = (object.y - height - 1);
			}
		}
		return targetSpr = object;
	}

	override public function update(elapsed:Float):Void
	{
		if (visible)
		{
			showTimer += 1.0 * elapsed;
			if (showTimer >= duration)
			{
				visible = false;
				showTimer = 0;
			}
		}
	}
}
