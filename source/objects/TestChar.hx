package objects;

import flixel.math.FlxPoint;

class TestChar extends FlxSprite
{
	public var widthCM:Float;
	public var heightCM(default, set):Float;
	public var weightKG:Float;

	public var speed:Float;

	function set_heightCM(value:Float):Float
	{
		setGraphicSize(widthCM * 0.01 * LevelEditor.BLOCK_SIZE, (value * 0.01) * LevelEditor.BLOCK_SIZE);
		updateHitbox();
		return heightCM = value;
	}

	public var inputHorizontal:Float = 0;
	public var inputVertical:Float = 0;

	function getInputs()
	{
		inputVertical = Controls.NOTE_DOWN ? 1 : Controls.NOTE_UP ? -1 : 0;
		inputHorizontal = Controls.NOTE_LEFT ? -1 : Controls.NOTE_RIGHT ? 1 : 0;
	}

	override public function new(?X:Float, ?Y:Float, ?WidthCM:Float, ?HeightCM:Float, ?Speed:Float)
	{
		super(X, Y);
		makeGraphic(1, 1);
		widthCM = WidthCM;
		heightCM = HeightCM;
		speed = Speed;
		color = FlxColor.CYAN;
		moves = true;
		acceleration.y = GameWorld.GRAVITY * LevelEditor.BLOCK_SIZE;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		getInputs();
		if (y > FlxG.height - height - 250)
		{
			y = FlxG.height - height - 250;
			velocity.y = 0;
			velocity.y = (speed * 0.5) * LevelEditor.BLOCK_SIZE * inputVertical;
			acceleration.x = speed * LevelEditor.BLOCK_SIZE * inputHorizontal * (FlxG.keys.pressed.SHIFT ? 5 : 1);
			drag.x = speed * 2 * LevelEditor.BLOCK_SIZE;
		}
		else
		{
			acceleration.x = 0;
			drag.x = 0;
		}

		if (x > FlxG.width - width)
		{
			velocity.x = -velocity.x * 0.5;
			x = FlxG.width - width;
		}
		if (x < 0)
		{
			velocity.x = -velocity.x * 0.5;
			x = 0;
		}
	}
}
