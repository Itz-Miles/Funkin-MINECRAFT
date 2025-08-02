package blockUI;

import lime.system.System;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

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
		{
			x: 0,
			y: 16,
			width: 0,
			height: 0,
			color: 0xffffffff,
			text: "",
			font: "Minecrafter.ttf",
			size: 40,
			align: CENTER,
			objectCode: function(obj)
			{
				obj.screenCenter(X);
				obj.alpha = 0;
				FlxTween.tween(obj, {alpha: 1}, 1.5, {ease: FlxEase.quintOut, startDelay: 0.6});
			}
		},
	];
}
