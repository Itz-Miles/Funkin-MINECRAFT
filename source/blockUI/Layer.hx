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
	var ?align:Bool;
}

class LayerData
{
	public static var HEADER:Array<Layer> = [
		{
			x: 0,
			y: 0,
			width: 1280,
			height: 64,
			color: 0xff353535
		},
		{
			x: 8,
			y: 8,
			width: 1280 - 16,
			height: 64 - 16,
			color: 0xFF0f0f0f
		},
		{
			x: 0,
			y: 64,
			width: 1280,
			height: 8,
			color: 0xff000000
		},
	];
}
