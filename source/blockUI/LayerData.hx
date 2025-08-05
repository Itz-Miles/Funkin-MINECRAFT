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
				function(obj)
				{ // tween in
					FlxTween.tween(obj, {y: -72}, 1, {ease: FlxEase.quintIn, startDelay: 0.0});
				},
				function(obj)
				{ // substate
					obj.y = 50;
				},
			]
		},
		{ // bottom
			x: 50,
			y: 64,
			width: 1180,
			height: 8,
			color: 0xff000000,
			_functions: [
				function(obj)
				{
					obj.scale.x *= 0.95;
					obj.scale.y *= 1.05;
					FlxTween.tween(obj, {"scale.x": 1180, "scale.y": 8}, 1.5, {ease: FlxEase.elasticOut, startDelay: 0.0});
				},
			]
		},
		{ // border
			x: 50,
			y: 0,
			width: 1180,
			height: 64,
			color: 0xff353535,
			_functions: [
				function(obj)
				{
					obj.scale.x *= 0.95;
					obj.scale.y *= 1.05;
					FlxTween.tween(obj, {"scale.x": 1180, "scale.y": 64}, 1.5, {ease: FlxEase.elasticOut, startDelay: 0.0});
				},
			]
		},
		{ // content
			x: 58,
			y: 8,
			width: 1164,
			height: 48,
			color: 0xFF0f0f0f,
			_functions: [
				function(obj)
				{
					obj.scale.x *= 0.95;
					obj.scale.y *= 1.05;
					FlxTween.tween(obj, {"scale.x": 1164, "scale.y": 48}, 1.5, {ease: FlxEase.elasticOut, startDelay: 0.0});
				},
			]
		},
		{ // top shadow
			x: 58,
			y: 8,
			width: 1164,
			height: 6,
			color: 0xff000000,
			_functions: [
				function(obj)
				{
					obj.scale.x *= 0.9;
					obj.scale.y *= 1.11;
					FlxTween.tween(obj, {"scale.x": 1164, "scale.y": 6}, 1.5, {ease: FlxEase.elasticOut, startDelay: 0.0});
				},
			]
		},
		{ // header
			x: 640,
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
				{ // fade in
					obj.screenCenter(X);
					obj.alpha = 0;
					obj.scale.x *= 0.9;
					obj.scale.y *= 1.11;
					FlxTween.tween(obj, {alpha: 1, "scale.x": 1, "scale.y": 1}, 1.5, {ease: FlxEase.elasticOut, startDelay: 0});
				},
				function(obj)
				{ // fade out
					obj.alpha = 1;
					FlxTween.tween(obj, {alpha: 0}, 1.5, {ease: FlxEase.quintIn, startDelay: 0});
				},
				function(obj)
				{ // substate
					obj.screenCenter(X);
					obj.y = 62;
					FlxTween.tween(obj, {y: 66}, 1, {ease: FlxEase.elasticOut, startDelay: 0});
				},
			],
		}
	];
}
