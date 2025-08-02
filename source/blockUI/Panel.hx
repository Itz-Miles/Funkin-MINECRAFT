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
	 * Sets the first FlxText's text. 
	 * 
	 * Shorthand + null check for fields[0].text.
	 */
	public var text(get, set):String;

	function get_text():String
	{
		return fields.length > 0 ? fields[0].text : "";
	}

	function set_text(value:String):String
	{
		if (fields.length > 0)
			fields[0].text = value;
		return value;
	}

	/**
	 * An array of this panel's FlxTexts.
	 */
	public var fields:Array<FlxText> = [];

	/**
	 * Constructs the panel using an array of layer definitions.
	 * @param layers Array of Layers (x, y, width, height, color, text, font, size).
	 */
	public function new(layers:Array<Layer>)
	{
		super();

		for (layer in layers)
		{
			var obj:FlxSprite;

			if (layer.text == null)
			{
				obj = new FlxSprite();
				obj.makeGraphic(1, 1, layer.color);
				obj.setPosition(layer.x, layer.y);
				obj.scale.set(layer.width, layer.height);
				obj.updateHitbox();
			}
			else
			{
				var text = new FlxText(layer.x, layer.y, layer.width);
				text.setFormat(layer.font, layer.size, layer.color, layer.align);
				text.text = layer.text;
				fields.push(text);
				obj = text;
			}

			add(obj);

			if (layer.objectCode != null)
			{
				var code = layer.objectCode;
				var target = obj;
				_deferredFunctions.push(() -> code(target));
			}
		}

		scrollFactor.set(0, 0);
	}

	/**
	 * A list of functions
	 */
	public var _deferredFunctions:Array<Void->Void> = [];
	/**
	 * Calls the members' objectCode functions.
	 */
	public function runFunctions()
	{
		for (fn in _deferredFunctions)
			fn();
	}
}
