package objects;

import flixel.math.FlxPoint;

enum abstract State(Int) from Int to Int
{
	var IDLE = 0;
	var STUNNED = 1;
	var DEAD = 2;
}

class TestChar extends FlxSprite
{
	public var widthCM:Float;
	public var heightCM(default, set):Float;
	public var weightKG:Float;

	public var speed:Float;

	function set_heightCM(value:Float):Float
	{
		loadGraphic(Paths.image("characters/bf_nomodel", "shared"));
		setGraphicSize(widthCM * 0.01 * Physics.BLOCK_SIZE, (value * 0.01) * Physics.BLOCK_SIZE);
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
		acceleration.y = Physics.gravity * Physics.BLOCK_SIZE;
		setFacingFlip(RIGHT, true, false);
		setFacingFlip(LEFT, false, false);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		getInputs();
		if (y > FlxG.height - height - 250)
		{
			y = FlxG.height - height - 250;
			velocity.y = 0;
			velocity.y = (speed * 0.5) * Physics.BLOCK_SIZE * inputVertical;
			acceleration.x = speed * Physics.BLOCK_SIZE * inputHorizontal * (FlxG.keys.pressed.SHIFT ? 5 : 1);
			drag.x = speed * 2 * Physics.BLOCK_SIZE;
			facing = inputHorizontal > 0 ? RIGHT : inputHorizontal < 0 ? LEFT : NONE;
		}
		else
		{
			acceleration.x = 0;
			drag.x = 0;
		}

		if (x > FlxG.width - width)
		{
			velocity.x = -velocity.x * 0.75;
			facing = LEFT;
			x = FlxG.width - width;
		}
		if (x < 0)
		{
			facing = RIGHT;
			velocity.x = -velocity.x * 0.75;
			x = 0;
		}
	}
}
