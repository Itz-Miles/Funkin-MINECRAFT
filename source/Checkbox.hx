package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class Checkbox extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var daValue(default, set):Bool;
	public var copyAlpha:Bool = true;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public function new(x:Float = 0, y:Float = 0, ?checked = false)
	{
		super(x, y);
		loadGraphic(Paths.image("settings/toggle", "shared"), true, 30, 16);
		animation.add("unchecked", [0], 0, false);
		animation.add("unchecking", [0, 1, 0], 12, false);
		animation.add("checking", [0, 1, 0], 12, false, true);
		animation.add("checked", [0], 0, false, true);

		antialiasing = false;
		setGraphicSize(120);
		updateHitbox();

		animationFinished(checked ? 'checking' : 'unchecking');
		animation.finishCallback = animationFinished;
		daValue = checked;
	}

	override function update(elapsed:Float)
	{
		if (sprTracker != null)
		{
			setPosition(sprTracker.x - 130 + offsetX, sprTracker.y + offsetY);
			if (copyAlpha)
			{
				alpha = sprTracker.alpha;
			}
		}
		super.update(elapsed);
	}

	function set_daValue(check:Bool):Bool
	{
		if (check)
		{
			if (animation.curAnim.name != 'checked' && animation.curAnim.name != 'checking')
			{
				animation.play('checking', true);
			}
		}
		else if (animation.curAnim.name != 'unchecked' && animation.curAnim.name != 'unchecking')
		{
			animation.play("unchecking", true);
		}
		return check;
	}

	function animationFinished(name:String)
	{
		switch (name)
		{
			case 'checking':
				animation.play('checked', true);

			case 'unchecking':
				animation.play('unchecked', true);
		}
	}
}
