package blockUI;

import blockUI.Panel.LayerObject;
import flixel.text.FlxInputText;
import flixel.FlxSprite;
import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxColor;

typedef Layer =
{
	var ?x:Float;
	var ?y:Float;
	var ?width:Float;
	var ?height:Float;
	var ?color:FlxColor;

	var ?text:String;
	var ?font:String;
	var ?size:Int;
	var ?align:FlxTextAlign;
	var ?_functions:Array<LayerObject->Void>;
	var ?onClick:LayerObject->Void;
	var ?onPush:LayerObject->Void;
	var ?onHover:LayerObject->Void;
	var ?onRelease:LayerObject->Void;
	var ?onChange:FlxInputText->Void;
	var ?group:Array<Layer>;
}
