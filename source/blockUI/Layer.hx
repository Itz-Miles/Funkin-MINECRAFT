package blockUI;

import flixel.util.FlxColor;

typedef Layer =
{
	var x:Float;
	var y:Float;
	var width:Float;
	var height:Float;
	var color:FlxColor;

	var ?text:String;
	var ?font:String;
	var ?size:Int;
}
