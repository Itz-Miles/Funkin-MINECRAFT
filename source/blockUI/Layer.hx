package blockUI;

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
	var ?_functions:Array<FlxSprite->Void>;
	var ?onClick:Void->Void;
	var ?onHover:Void->Void;
	var ?onLeave:Void->Void;
}
