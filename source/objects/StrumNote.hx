package objects;

import flixel.FlxSprite;

using StringTools;

class StrumNote extends FlxSprite
{
	public var resetAnim:Float = 0;

	public var pressed(default, set):Bool = false;

	function set_pressed(value:Bool)
	{
		if (value)
			loadGraphic(Paths.image('notes/slot_selected', "shared"));
		else
			loadGraphic(Paths.image('notes/slot', "shared"));

		return pressed = value;
	}

	public function new(x:Float, y:Float, leData:Int, player:Int)
	{
		super(x + (Note.swagWidth * leData) + (740 * player), y, Paths.image('notes/slot', "shared"));

		scrollFactor.set();

		antialiasing = false;
		setGraphicSize(Note.swagWidth);

		updateHitbox();
		ID = leData;
	}

	public function bounceIn():Void
	{
	}

	public function bounceOut():Void
	{
	}
}
