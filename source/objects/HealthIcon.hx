package objects;

import flixel.FlxSprite;
import flixel.math.FlxPoint;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var trackerOffset:FlxPoint = FlxPoint.get(10, -30);

	var isPlayer:Bool = false;
	var char:String = '';

	public function new(char:String, isPlayer:Bool = false, ?library:String = "shared")
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(char, library);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + trackerOffset.x, sprTracker.y + trackerOffset.y);
	}

	var iconOffsets:Array<Float> = [0, 0];

	public function changeIcon(char:String, ?library:String)
	{
		if (this.char != char)
		{
			var name:String = 'icons/' + char;
			if (!Paths.fileExists('images/' + name + '.png', IMAGE, null, library))
				name = 'icons/icon-' + char; // Older versions of psych engine's support
			if (!Paths.fileExists('images/' + name + '.png', IMAGE, null, library))
				name = 'icons/icon-face'; // Prevents crash from missing icon
			var file:Dynamic = Paths.image(name, library);

			loadGraphic(file); // Load stupidly first for getting the file size
			if (width == height * 2)
			{
				loadGraphic(file, true, Math.floor(width * 0.5), Math.floor(height)); // Then load it fr
				animation.add(char, [0, 1], 0, false, isPlayer);
				iconOffsets[0] = (width - 150) * 0.5;
				iconOffsets[1] = (width - 150) * 0.5;
			}
			else
			{
				animation.add(char, [0, 0], 0, false, isPlayer);
			}
			animation.play(char);
			this.char = char;

			antialiasing = ClientPrefs.data.antialiasing;
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String
	{
		return char;
	}
}
