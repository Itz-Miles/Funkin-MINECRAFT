import flixel.FlxG;
import flixel.FlxSprite;
import Character;

class Item extends FlxSprite
{
	public var bobSpeed:Float;

	var bobAmplitude:Float;
	var startY:Float;

	public var held:Bool;
	public var wielder:Character;
	public var offsets:Array<Float>;

	public function new(x:Float, y:Float, bobSpeed:Float = 5.0, bobAmplitude:Float = 1.0)
	{
		super();
		this.x = x;
		this.y = startY = y;
		held = true;
		bobSpeed = 1.0;
		bobAmplitude = 5.0;
		startY = y;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (held)
		{
			if (wielder != null)
			{
				this.x = wielder.x;
				this.y = wielder.y - this.height;
			}
		}
		else
		{
			this.y = startY + bobAmplitude * Math.sin(FlxG.elapsed * bobSpeed);
		}
	}
}
