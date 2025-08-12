package blockUI;

import blockUI.Layer;
import flixel.FlxG;
import lime.system.System;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import MusicBeatState;

class LayerData
{
	public static var HEADER:Array<Layer> = [
		{ // panel code
			_functions: [
				function(obj)
				{
					obj.y = -72;
					FlxTween.tween(obj, {y: 50}, 1.5, {ease: FlxEase.elasticOut});
				},
				function(obj)
				{ // tween in
					FlxTween.tween(obj, {y: -72}, 1, {ease: FlxEase.quintInOut});
				},
				function(obj)
				{ // substate
					obj.y = 50;
				},
			]
		},
		{ // bottom
			x: 50,
			y: 44,
			width: 1180,
			height: 28,
			color: 0xff000000,
			_functions: [
				function(obj)
				{
					obj.scale.x *= 0.95;
					obj.scale.y *= 1.8;
					FlxTween.tween(obj, {"scale.x": 1180, "scale.y": 28}, 1.5, {ease: FlxEase.elasticOut});
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
					obj.scale.y *= 1.8;
					FlxTween.tween(obj, {"scale.x": 1180, "scale.y": 64}, 1.5, {ease: FlxEase.elasticOut});
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
					obj.scale.y *= 1.8;
					FlxTween.tween(obj, {"scale.x": 1164, "scale.y": 48}, 1.5, {ease: FlxEase.elasticOut});
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
					obj.scale.x *= 0.95;
					obj.scale.y *= 1.8;
					FlxTween.tween(obj, {"scale.x": 1164, "scale.y": 6}, 1.5, {ease: FlxEase.elasticOut});
				},
			]
		},
		{ // button backing
			x: 86,
			y: 14,
			width: 38,
			height: 38,
			color: 0xff2e2e2e,
			_functions: [
				function(obj)
				{
					obj.scale.x *= 0.95;
					obj.scale.y *= 1.05;
					FlxTween.tween(obj, {x: 64, "scale.x": 38, "scale.y": 38}, 1.5, {ease: FlxEase.elasticOut});
				},
				function(obj)
				{
					FlxTween.tween(obj, {alpha: 0}, 1.5, {ease: FlxEase.quintOut});
				},
				function(obj)
				{
					obj.x = 64;
				}
			]
		},
		{ // button
			x: 86,
			y: 12,
			width: 38,
			height: 38,
			color: 0xff626262,
			_functions: [
				function(obj)
				{
					obj.scale.x *= 0.95;
					obj.scale.y *= 1.05;
					obj.offset.y = -16;
					FlxTween.tween(obj, {x: 64, "scale.x": 38, "scale.y": 38}, 1.5, {ease: FlxEase.elasticOut});
				},
				function(obj)
				{
					FlxTween.tween(obj, {alpha: 0}, 1.5, {ease: FlxEase.quintOut});
				},
				function(obj)
				{
					obj.offset.y = -16;
					obj.x = 64;
				}
			],
			onClick: function(obj)
			{
				@:bypassAccessor Controls.instance.BACK = true;
				obj.offset.y = -18;
			},
			onHover: function(obj)
			{
				obj.offset.y = -14;
			},
			onRelease: function(obj)
			{
				obj.offset.y = -16;
			}
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
					obj.scale.y *= 1.8;
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
					obj.y = 60;
					obj.scale.set(1.02, 1.02);
					FlxTween.tween(obj, {y: 66, "scale.x": 1, "scale.y": 1}, 0.5, {ease: FlxEase.quintOut, startDelay: 0});
				},
			],
		}
	];
}
