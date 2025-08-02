package blockUI;

import flixel.text.FlxText;
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
	 * @param layers Array of Layers (x, y, width, height, color, text, font, size).
	 */
	public function new(layers:Array<Layer>)
	{
		super();

		for (layer in layers)
		{
			if (layer.text == null)
			{
				var sprite = new FlxSprite();

				sprite.makeGraphic(1, 1, layer.color);
				sprite.setPosition(layer.x, layer.y);
				sprite.scale.set(layer.width, layer.height);
				sprite.updateHitbox();

				add(sprite);
			}
			else
			{
				var text:FlxText = new FlxText(layer.x, layer.y, layer.width);

				text.setFormat(Paths.font(layer.font), layer.size, layer.color);
				text.text = layer.text;
				
				add(text);
			}
		}
	}
}
