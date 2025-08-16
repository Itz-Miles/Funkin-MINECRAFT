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
	var PUSHED = 4;
}

typedef ButtonData =
{
	var sprite:FlxSprite;
	var state:ButtonState;
	var onClick:Void->Void;
	var onHover:Void->Void;
	var onRelease:Void->Void;
	var onPush:Void->Void;
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
	public var buttons:Array<ButtonData> = [];

	/**
	 * An array of this panel's sprite layers.
	 */
	public var sprites:Array<FlxSprite> = [];

	/**
	 * An array of each layer's functions. [0] is the panel itself.
	 */
	private var _layerFunctions:Array<Array<Void->Void>> = new Array();

	public var buttonStates:Array<ButtonState> = new Array();

	/**
	 * Constructs the panel using an array of layer definitions.
	 * @param layers Array of Layers (x, y, width, height, color, text, font, size).
	 */
	public function new(?layers:Array<Layer>)
	{
		super();
		_layerFunctions.push([]);

		addLayers(layers);

		scrollFactor.set(0, 0);
	}

	/**
	 * Dynamically adds a new layer to the panel after creation.
	 */
	public function addLayer(layer:Layer):Void
	{
		addLayerInternal(layer);
	}

	/**
	 * Dynamically adds new layers to the panel after creation.
	 */
	public function addLayers(?layers:Array<Layer>):Void
	{
		for (layer in layers ?? [])
		{
			addLayerInternal(layer);
		}
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
			obj.makeGraphic(1, 1, layer.color); // low ram usage
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

		if (layer.onClick != null || layer.onHover != null || layer.onRelease != null || layer.onPush != null)
		{
			var button:ButtonData =
				{
					sprite: obj,
					state: RELEASED,
					onClick: layer.onClick != null ? () -> layer.onClick(obj) : null,
					onHover: layer.onHover != null ? () -> layer.onHover(obj) : null,
					onRelease: layer.onRelease != null ? () -> layer.onRelease(obj) : null,
					onPush: layer.onPush != null ? () -> layer.onPush(obj) : null
				};
			buttons.push(button);
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

		for (button in buttons)
		{
			if (button.state == DISABLED || !button.sprite.visible)
				continue;

			var isPush = button.onPush != null;

			if (FlxG.mouse.overlaps(button.sprite, this.camera))
			{
				// FlxG.mouse.released is any frame the mouse is not held - different from JustReleased
				if (FlxG.mouse.released && button.state != HOVERED && button.state != PUSHED)
				{
					button.state = HOVERED;
					if (button.onHover != null)
						button.onHover();
				}

				if (FlxG.mouse.justPressed)
				{
					if (isPush)
					{
						if (button.state == PUSHED)
						{
							button.state = RELEASED;
							if (button.onRelease != null)
								button.onRelease();
						}
						else
						{
							button.state = PUSHED;
							if (button.onPush != null)
								button.onPush();
						}
					}
					else
					{
						button.state = CLICKED;
						if (button.onClick != null)
							button.onClick();
					}
				}
			}
			else
			{
				if (button.state != RELEASED && button.state != PUSHED)
				{
					button.state = RELEASED;
					if (button.onRelease != null)
						button.onRelease();
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
