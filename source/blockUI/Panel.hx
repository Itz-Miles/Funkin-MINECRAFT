package blockUI;

import flixel.text.FlxText;
import flixel.FlxSprite;
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
	 * An array of this panel's FlxText layers.
	 */
	public var fields:Array<FlxText> = [];

	/**
	 * An array of each layer's functions. [0] is the panel itself.
	 */
	private var _layerFunctions:Array<Array<Void->Void>> = new Array();

	/**
	 * Constructs the panel using an array of layer definitions.
	 * @param layers Array of Layers (x, y, width, height, color, text, font, size).
	 */
	public function new(layers:Array<Layer>)
	{
		super();
		_layerFunctions.push([]);

		var index:Int = 1;
		for (layer in layers)
		{
			if (isOnlyFunctions(layer))
			{
				for (_function in layer._functions)
					addFunction(0, () -> _function(this)); // index 0 is always panel code
				continue;
			}

			var obj:FlxSprite = null;

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
			_layerFunctions.push([]);

			if (layer._functions != null)
				for (_function in layer._functions)
					addFunction(index, () -> _function(obj));
			index++;
		}

		scrollFactor.set(0, 0);
	}

	/**
	 * Adds a function for the given layer, by index.
	 */
	public function addFunction(index:Int = 0, _function:Void->Void):Void
	{
		_layerFunctions[index].push(_function);
	}

	/**
	 * Runs each layer's function by index.
	 * Runs everything if not given. 
	 */
	public function runAcrossLayers(?index:Int = 0):Void
	{
		for (functionsArray in _layerFunctions)
		{
			if (index != null && functionsArray[index] != null)
			{
				functionsArray[index]();
			}
		}
	}
	/**
	 * Runs all the functions. All of them.
	 */
	public function runAllLayers()
	{
		for (functionsArray in _layerFunctions)
			for (_function in functionsArray)
			{
				_function();
			}
	}

	/**
	 * Runs the functions for a specific layer.
	 * @param layer The layer to run functions on, by index. The Panel itself is [0].
	 * @param indexes The functions to run, by indexes.
	 */
	public function runLayer(layer:Int = 0, ?indexes:Array<Int>):Void
	{
		if (_layerFunctions[layer] != null)
		{
			if (indexes != null)
			{
				for (index in indexes)
				{
					if (_layerFunctions[layer][index] != null)
					{
						_layerFunctions[layer][index]();
					}
				}
			}
			else
			{
				if (_layerFunctions[layer][0] != null)
					_layerFunctions[layer][0]();
			}
		}
	}

	/**
	 * Checks to see if there are only functions in this Layer
	 * @param layer 
	 * @return Bool
	 */
	static function isOnlyFunctions(layer:Layer):Bool
	{
		return layer.x == null && layer.y == null && layer.width == null && layer.height == null && layer.color == null && layer.text == null
			&& layer.font == null && layer.size == null && layer.align == null && layer._functions != null;
	}
}
