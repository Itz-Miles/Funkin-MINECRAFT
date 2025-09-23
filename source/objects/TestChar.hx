package objects;

import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;

enum abstract TestState(Int) from Int to Int
{
	var IDLE = 0;
	var STUNNED = 1;
	var DEAD = 2;
}

class TestChar extends FlxSprite
{
	public var displayScale:FlxPoint;
	public var widthCM:Float;
	public var heightCM(default, set):Float;
	public var weightKG:Float;

	public var speed:Float;

	var testBurst:Bool = true;

	function set_heightCM(value:Float):Float
	{
		loadGraphic(Paths.image("characters/bf_nomodel", "shared"));
		setGraphicSize(widthCM * 0.01 * Physics.BLOCK_SIZE, (value * 0.01) * Physics.BLOCK_SIZE);
		updateHitbox();
		return heightCM = value;
	}

	public var inputHorizontal:Float = 0;
	public var jumpInput:Bool = false;

	function getInputs()
	{
		jumpInput = Controls.JUMP;
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

	@:noCompletion
	override function initVars():Void
	{
		super.initVars();
		displayScale = FlxPoint.get(1, 1);
	}

	public function jump()
	{
		velocity.y = Physics.BLOCK_SIZE * 4.9 * 0.5 * 1.0; // times jump height meters
	}

	public function initialDash()
	{
		acceleration.x *= 10;
	}

	public var grounded:Bool = false;

	function getGrounded():Bool
	{
		return grounded = y > FlxG.height - height - 250; // that'll do for now
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		getInputs();

		getGrounded();

		if (FlxG.keys.justPressed.SIX)
		{
			testBurst = !testBurst;
			trace("test burst:" + testBurst);
		}

		if (grounded)
		{
			y = FlxG.height - height - 250;
			velocity.y = 0;
			if (jumpInput)
				jump();
			acceleration.x = speed * Physics.BLOCK_SIZE * inputHorizontal * (FlxG.keys.pressed.SHIFT ? 0.5 : 1);

			if (velocity.x > 0 && inputHorizontal < 0 || velocity.x < 0 && inputHorizontal > 0)
				acceleration.x = 0;
			if (testBurst && (velocity.x < 128 && velocity.x > -128))
				initialDash();

			drag.x = speed * 3 * Physics.BLOCK_SIZE;
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

	override public function destroy()
	{
		super.destroy();
		displayScale = FlxDestroyUtil.put(displayScale);
	}
}
