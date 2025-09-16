package blockUI;

import flixel.text.FlxInputText;
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
	var isPush:Bool;
}

typedef LayerObject =
{
	var sprite:FlxSprite;
	var last:Null<LayerObject>;
	var next:Null<LayerObject>;
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
	private var _layerFunctions:Array<Array<Void->Void>> = [];

	public var layers:Array<LayerObject> = [];

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
		for (i in 0...layers.length ?? [].length)
		{
			addLayerInternal(layers[i]);
		}
	}

	/**
	 * Internal helper to handle layer creation logic for both constructor and addLayer().
	 */
	private function addLayerInternal(layer:Layer, ?parent:FlxSpriteContainer):Void
	{
		if (isOnlyFunctions(layer))
		{
			var layerObj:LayerObject =
				{
					sprite: this,
					last: null,
					next: null
				};
			layerObj.last = layerObj;
			layerObj.next = layerObj;

			layers.push(layerObj);

			if (layers.length > 0 && layers[layers.length - 1] != null)
			{
				layers[layers.length - 1].next = layerObj;
				layerObj.last = layers[layers.length - 1];
			}

			for (_function in layer._functions)
				addFunction(0, () -> _function(layerObj));
			return;
		}
		_layerFunctions.push([]);

		var obj:FlxSprite = null;

		if (layer.group != null)
		{
			var group:FlxSpriteContainer = new FlxSpriteContainer();

			add(obj);
			for (sublayer in layer.group)
			{
				addLayerInternal(sublayer, group);
			}
			obj = group;
		}
		if (layer.onChange != null)
		{
			var input = new FlxInputText(layer.x, layer.y, layer.width, layer.text, layer.size, layer.color);
			input.setFormat(layer.font, layer.size, layer.color, layer.align);
			input.backgroundColor = 0xFF000000;
			input.fieldBorderColor = 0xFFFFFFFF;
			input.fieldBorderThickness = 4;

			input.onTextChange.add((_, c) -> layer.onChange(input));

			fields.push(input);
			obj = input;
			add(obj);
		}
		else if (layer.text == null)
		{
			obj = new FlxSprite();
			obj.makeGraphic(1, 1, layer.color); // low ram usage
			obj.setPosition(layer.x, layer.y);
			obj.scale.set(layer.width, layer.height);
			obj.updateHitbox();
			sprites.push(obj);
			add(obj);
		}
		else
		{
			var text = new FlxText(layer.x, layer.y, layer.width);
			text.setFormat(layer.font, layer.size, layer.color, layer.align);
			text.text = layer.text;
			fields.push(text);
			obj = text;
			add(obj);
		}

		var layerObj:LayerObject =
			{
				sprite: obj,
				last: null,
				next: null
			};
		layerObj.last = layerObj;
		layerObj.next = layerObj;

		if (layers.length > 0 && layers[layers.length - 1] != null)
		{
			layers[layers.length - 1].next = layerObj;
			layerObj.last = layers[layers.length - 1];
		}

		layers.push(layerObj);

		if (layer.onClick != null || layer.onHover != null || layer.onRelease != null || layer.onPush != null)
		{
			var button:ButtonData =
				{
					sprite: obj,
					state: RELEASED,
					onClick: () -> if (layer.onClick != null) layer.onClick(layerObj),
					onHover: () -> if (layer.onHover != null) layer.onHover(layerObj),
					onRelease: () -> if (layer.onRelease != null) layer.onRelease(layerObj),
					onPush: () -> if (layer.onPush != null) layer.onPush(layerObj),
					isPush: layer.onPush != null
				};
			buttons.push(button);
		}

		if (layer._functions != null)
		{
			for (_function in layer._functions)
				addFunction(_layerFunctions.length - 1, () -> _function(layerObj));
		}

		if (parent != null)
			parent.add(obj);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		for (i in 0...buttons.length)
		{
			if (buttons[i] == null)
				continue;

			if (buttons[i].state == DISABLED || !buttons[i].sprite.visible)
				continue;

			if (FlxG.mouse.overlaps(buttons[i].sprite, this.camera))
			{
				// FlxG.mouse.released is any frame the mouse is not held - different from JustReleased
				if (FlxG.mouse.released && buttons[i].state != HOVERED && buttons[i].state != PUSHED)
				{
					buttons[i].state = HOVERED;
					buttons[i].onHover();
				}

				if (FlxG.mouse.justPressed)
				{
					if (buttons[i].isPush)
					{
						if (buttons[i].state == PUSHED)
						{
							buttons[i].state = RELEASED;
							buttons[i].onRelease();
						}
						else
						{
							buttons[i].state = PUSHED;
							buttons[i].onPush();
						}
					}
					else
					{
						buttons[i].state = CLICKED;
						buttons[i].onClick();
					}
				}
			}
			else
			{
				if (buttons[i].state != RELEASED && buttons[i].state != PUSHED)
				{
					buttons[i].state = RELEASED;
					buttons[i].onRelease();
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
	 * Runs each layer's `n`th function by index. 
	 */
	public function runAcrossLayers(index:Int = 0):Void
	{
		for (functionsArray in _layerFunctions)
		{
			if (index < functionsArray.length && functionsArray[index] != null)
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
		return layer.x == null && layer.y == null && layer.width == null && layer.height == null && layer.color == null && layer.text == null && layer.font == null && layer.size == null && layer.align == null && layer._functions != null;
	}
}
