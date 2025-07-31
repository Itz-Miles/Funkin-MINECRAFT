package blockUI;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxRect;
import flixel.group.FlxSpriteGroup;
import blockUI.Layer;

/**
 * A simple UI panel composed of multiple colored sprite layers.
 */
class Panel extends FlxSpriteGroup
{
	/**
	 * Constructs the panel using an array of layer definitions.
	 * @param layers Array of Layers (x, y, width, height, color).
	 */
	public function new(layers:Array<Layer>)
	{
		super();

		for (layer in layers)
		{
			var sprite = new FlxSprite();

			sprite.makeGraphic(1, 1, layer.color);
			sprite.setPosition(layer.x, layer.y);
			sprite.scale.set(layer.width, layer.height);
			sprite.updateHitbox();

			add(sprite);
		}
	}
}
