package blockUI;

import blockUI.Layer;
import flixel.FlxG;
import lime.system.System;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class LayerData
{
	public static var HEADER:Array<Layer> = [
		{ // panel code
			_functions: [
				function(obj)
				{
					obj.y = -72;
					FlxTween.tween(obj, {y: 50}, 1.5, {ease: FlxEase.elasticOut, startDelay: 0.0});
				},
				/*
					function(obj)
					{ // tween out (dead)
						FlxTween.tween(obj, {y: 0}, 1.6, {ease: FlxEase.quintOut});
					},
					function(obj)
					{ // tween out (paused)
						FlxTween.tween(obj, {y: 0}, 0.4, {ease: FlxEase.quintOut});
					},
					function(obj)
					{ // tween in
						FlxTween.tween(obj, {y: -72}, 0.5, {ease: FlxEase.quintOut, startDelay: 0.0});
					}
				 */
			]
		},
		{ // bottom
			x: 0,
			y: 64,
			width: 1280,
			height: 8,
			color: 0xff000000
		},
		{ // border
			x: 0,
			y: 0,
			width: 1280,
			height: 64,
			color: 0xff353535
		},
		{ // content
			x: 8,
			y: 8,
			width: 1280 - 16,
			height: 64 - 16,
			color: 0xFF0f0f0f
		},
		{ // top shadow
			x: 8,
			y: 8,
			width: 1280 - 16,
			height: 6,
			color: 0xff000000
		},
		{ // header
			x: 0,
			y: 16,
			width: 0,
			height: 0,
			color: 0xffffffff,
			text: "",
			font: Paths.font("Minecrafter.ttf"),
			size: 40,
			align: CENTER,
			_functions: [
				function(obj)
				{
					obj.screenCenter(X);
					obj.alpha = 0;
					FlxTween.tween(obj, {alpha: 1}, 1.5, {ease: FlxEase.quintOut, startDelay: 0});
				}
			],
		}
	];
}
