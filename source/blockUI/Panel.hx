package blockUI;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import blockUI.Layer;

enum abstract ButtonState(Int) from Int to Int
{
	var DISABLED = 0;
	var RELEASED = 1;
	var HOVERED = 2;
	var CLICKED = 3;
}

/**
 * A simple UI panel composed of multiple colored sprite layers.
 */
class Panel extends FlxSpriteContainer
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
	 * An array of this panel's button layers.
	 */
	public var buttons:Array<FlxSprite> = [];

	/**
	 * An array of this panel's sprite layers.
	 */
	public var sprites:Array<FlxSprite> = [];

	/**
	 * An array of each layer's functions. [0] is the panel itself.
	 */
	private var _layerFunctions:Array<Array<Void->Void>> = new Array();

	public var onClick:Array<Void->Void> = new Array();
	public var onHover:Array<Void->Void> = new Array();
	public var onRelease:Array<Void->Void> = new Array();

	public var buttonStates:Array<ButtonState> = new Array();

	/**
	 * Constructs the panel using an array of layer definitions.
	 * @param layers Array of Layers (x, y, width, height, color, text, font, size).
	 */
	public function new(?layers:Array<Layer>)
	{
		super();
		_layerFunctions.push([]);

			for (layer in layers ?? [])
			{
				addLayerInternal(layer);
			}

		scrollFactor.set(0, 0);
	}

	/**
	 * Dynamically adds a new layer to the panel after creation.
	 * Returns the index of the added layer.
	 */
	public function addLayer(layer:Layer):Void
	{
		addLayerInternal(layer);
	}

	/**
	 * Internal helper to handle layer creation logic for both constructor and addLayer().
	 */
	private function addLayerInternal(layer:Layer):Void
	{
		if (isOnlyFunctions(layer))
		{
			for (_function in layer._functions)
				addFunction(0, () -> _function(this));
			return;
		}

		var obj:FlxSprite = null;

		if (layer.text == null)
		{
			obj = new FlxSprite();
			obj.makeGraphic(1, 1, layer.color);
			obj.setPosition(layer.x, layer.y);
			obj.scale.set(layer.width, layer.height);
			obj.updateHitbox();
			sprites.push(obj);
		}
		else
		{
			var text = new FlxText(layer.x, layer.y, layer.width);
			text.setFormat(layer.font, layer.size, layer.color, layer.align);
			text.text = layer.text;
			fields.push(text);
			obj = text;
		}

		if (layer.onClick != null || layer.onHover != null || layer.onRelease != null)
		{
			buttonStates.push(RELEASED);
			buttons.push(obj);
			if (layer.onClick != null)
			{
				onClick.push(() -> layer.onClick(obj));
			}
			if (layer.onHover != null)
			{
				onHover.push(() -> layer.onHover(obj));
			}
			if (layer.onRelease != null)
			{
				onRelease.push(() -> layer.onRelease(obj));
			}
		}

		add(obj);

		_layerFunctions.push([]);
		if (layer._functions != null)
		{
			for (_function in layer._functions)
				addFunction(_layerFunctions.length - 1, () -> _function(obj));
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		for (i in 0...buttons.length)
		{
			if (buttonStates[i] == DISABLED)
				continue;

			if (FlxG.mouse.overlaps(buttons[i], this.camera))
			{
				if (FlxG.mouse.released && buttonStates[i] != HOVERED)
				{
					buttonStates[i] = HOVERED;

					if (onHover[i] != null)
						onHover[i]();
				}

				if (FlxG.mouse.justPressed)
				{
					buttonStates[i] = CLICKED;

					if (onClick[i] != null)
						onClick[i]();
				}
			}
			else
			{
				if (buttonStates[i] != RELEASED)
				{
					buttonStates[i] = RELEASED;

					if (onRelease[i] != null)
						onRelease[i]();
				}
			}
		}
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
