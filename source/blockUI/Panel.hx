package blockUI;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxRect;
import flixel.group.FlxSpriteGroup;

/**
 * Simple UI panel supporting multiple layered rectangles.
 * Each layer is a 1x1 FlxSprite scaled to a given size and color.
 */
class Panel extends FlxSpriteGroup
{
	/**
	 * Create a layered panel.
	 * @param dims Array of FlxRects defining position and size of each layer.
	 * @param colors Array of FlxColors for each corresponding layer.
	 */
	public function new(dims:Array<FlxRect>, colors:Array<FlxColor>)
	{
		super();

		if (dims.length != colors.length)
		{
			throw "Panel: Dimensions and colors arrays must be of equal length.";
		}

		for (i in 0...dims.length)
		{
			var dim = dims[i];
			var color = colors[i];
			var sprite = new FlxSprite();

			sprite.makeGraphic(1, 1, color);
			sprite.setPosition(dim.x, dim.y);
			sprite.scale.set(dim.width, dim.height);
			sprite.updateHitbox();
			add(sprite);
		}
	}
}
