package blockUI;

import blockUI.Panel.LayerObject;
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
					FlxTween.cancelTweensOf(obj.sprite);
					obj.sprite.y = -72;
					FlxTween.tween(obj.sprite, {y: 50}, 1.5, {ease: FlxEase.elasticOut});
				},
				function(obj)
				{ // tween in
					FlxTween.tween(obj.sprite, {y: -72}, 1, {ease: FlxEase.quintInOut});
				},
				function(obj)
				{ // substate
					obj.sprite.y = 50;
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
					FlxTween.cancelTweensOf(obj.sprite);
					obj.sprite.scale.x = 1180 * 0.95;
					obj.sprite.scale.y = 28 * 1.8;
					FlxTween.tween(obj.sprite, {"scale.x": 1180, "scale.y": 28}, 1.5, {ease: FlxEase.elasticOut});
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
					FlxTween.cancelTweensOf(obj.sprite);
					obj.sprite.scale.x = 1180 * 0.95;
					obj.sprite.scale.y = 64 * 1.8;
					FlxTween.tween(obj.sprite, {"scale.x": 1180, "scale.y": 64}, 1.5, {ease: FlxEase.elasticOut});
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
					FlxTween.cancelTweensOf(obj.sprite);
					obj.sprite.scale.x = 1164 * 0.95;
					obj.sprite.scale.y = 48 * 1.8;
					FlxTween.tween(obj.sprite, {"scale.x": 1164, "scale.y": 48}, 1.5, {ease: FlxEase.elasticOut});
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
					FlxTween.cancelTweensOf(obj.sprite);
					obj.sprite.scale.x = 1164 * 0.95;
					obj.sprite.scale.y = 6 * 1.8;
					FlxTween.tween(obj.sprite, {"scale.x": 1164, "scale.y": 6}, 1.5, {ease: FlxEase.elasticOut});
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
					FlxTween.cancelTweensOf(obj.sprite);
					obj.sprite.x = 86;
					obj.sprite.scale.x = 38 * 0.95;
					obj.sprite.scale.y = 38 * 1.05;
					FlxTween.tween(obj.sprite, {x: 64, "scale.x": 38, "scale.y": 38}, 1.5, {ease: FlxEase.elasticOut});
				},
				function(obj)
				{
					FlxTween.cancelTweensOf(obj.sprite);
					FlxTween.tween(obj.sprite, {alpha: 0}, 1.5, {ease: FlxEase.quintOut});
				},
				function(obj)
				{
					obj.sprite.x = 64;
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
					FlxTween.cancelTweensOf(obj.sprite);
					obj.sprite.x = 86;
					obj.sprite.scale.x = 38 * 0.95;
					obj.sprite.scale.y = 38 * 1.05;
					obj.sprite.offset.y = -16;
					FlxTween.tween(obj.sprite, {x: 64, "scale.x": 38, "scale.y": 38}, 1.5, {ease: FlxEase.elasticOut});
				},
				function(obj)
				{
					FlxTween.tween(obj.sprite, {alpha: 0}, 1.5, {ease: FlxEase.quintOut});
				},
				function(obj)
				{
					obj.sprite.offset.y = -16;
					obj.sprite.x = 64;
				}
			],
			onClick: function(obj)
			{
				@:bypassAccessor Controls.BACK = true;
				obj.sprite.offset.y = -18;
			},
			onHover: function(obj)
			{
				obj.sprite.offset.y = -14;
			},
			onRelease: function(obj)
			{
				obj.sprite.offset.y = -16;
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
					FlxTween.cancelTweensOf(obj.sprite);
					obj.sprite.screenCenter(X);
					obj.sprite.alpha = 0;
					obj.sprite.scale.x = 0.9;
					obj.sprite.scale.y = 1.8;
					FlxTween.tween(obj.sprite, {alpha: 1, "scale.x": 1, "scale.y": 1}, 1.5, {ease: FlxEase.elasticOut, startDelay: 0});
				},
				function(obj)
				{ // fade out
					obj.sprite.alpha = 1;
					FlxTween.tween(obj.sprite, {alpha: 0}, 1.5, {ease: FlxEase.quintIn, startDelay: 0});
				},
				function(obj)
				{ // substate
					obj.sprite.screenCenter(X);
					obj.sprite.y = 60;
					obj.sprite.scale.set(1.02, 1.02);
					FlxTween.tween(obj.sprite, {y: 66, "scale.x": 1, "scale.y": 1}, 0.5, {ease: FlxEase.quintOut, startDelay: 0});
				},
			],
		}
	];

	public static function createButton(text:String = "button", x:Int = 0, y:Int = 0, width:Int = 100, height:Int = 50, borderSize:Int = 2, rimSize:Int = 4, color:Int = 0xFF888888, ?shadowColor:Int = 0x35000000, ?onClick:LayerObject->Void):Array<Layer>
	{
		return [

			{ // button outline
				x: x - borderSize,
				y: y - borderSize + rimSize,
				width: width + borderSize * 2,
				height: height + borderSize * 2,
				color: FlxColor.BLACK,
			},
			{ // button shadow
				x: x,
				y: y + rimSize,
				width: width,
				height: height + rimSize,
				color: shadowColor,
			},
			{ // button rim
				x: x,
				y: y + rimSize,
				width: width,
				height: height,
				color: FlxColor.fromInt(color).getDarkened(0.3),
			},
			{ // button backing
				x: x,
				y: y,
				width: width,
				height: height,
				color: FlxColor.fromInt(color).getLightened(0.1),
			},
			{ // button face
				x: x + borderSize,
				y: y + borderSize,
				width: width - borderSize * 2,
				height: height - borderSize * 2,
				color: color,
				onClick: function(obj)
				{
					FlxTween.cancelTweensOf(obj.last.last.last.sprite.offset);
					FlxTween.cancelTweensOf(obj.last.sprite.offset);
					FlxTween.cancelTweensOf(obj.sprite.offset);
					FlxTween.cancelTweensOf(obj.next.sprite.offset);
					FlxTween.tween(obj.last.last.last.sprite.offset, {y: ((-height - rimSize) * 0.5) + rimSize * 0.5}, 0.05);
					FlxTween.tween(obj.last.sprite.offset, {y: (-height * 0.5) - rimSize * 0.5}, 0.05);
					FlxTween.tween(obj.sprite.offset, {y: (-height * 0.5 + (borderSize)) - rimSize * 0.5}, 0.05);
					FlxTween.tween(obj.next.sprite.offset, {y: -rimSize * 0.5}, 0.05);
					onClick(obj);
				},
				onHover: function(obj)
				{
					FlxTween.cancelTweensOf(obj.last.last.last.sprite.offset);
					FlxTween.cancelTweensOf(obj.last.sprite.offset);
					FlxTween.cancelTweensOf(obj.sprite.offset);
					FlxTween.cancelTweensOf(obj.next.sprite.offset);
					FlxTween.tween(obj.last.last.last.sprite.offset, {y: ((-height - rimSize) * 0.5) - rimSize * 0.5}, 0.05);
					FlxTween.tween(obj.last.sprite.offset, {y: (-height * 0.5) + rimSize * 0.5}, 0.05);
					FlxTween.tween(obj.sprite.offset, {y: (-height * 0.5 + (borderSize)) + rimSize * 0.5}, 0.05);
					FlxTween.tween(obj.next.sprite.offset, {y: rimSize * 0.5}, 0.05);
				},
				onRelease: function(obj)
				{
					FlxTween.cancelTweensOf(obj.last.last.last.sprite.offset);
					FlxTween.cancelTweensOf(obj.last.sprite.offset);
					FlxTween.cancelTweensOf(obj.sprite.offset);
					FlxTween.cancelTweensOf(obj.next.sprite.offset);
					FlxTween.tween(obj.last.last.last.sprite.offset, {y: ((-height - rimSize) * 0.5)}, 0.05);
					FlxTween.tween(obj.last.sprite.offset, {y: (-height * 0.5)}, 0.05);
					FlxTween.tween(obj.sprite.offset, {y: (-height * 0.5 + (borderSize))}, 0.05);
					FlxTween.tween(obj.next.sprite.offset, {y: 0}, 0.05);
				}
			},
			{ // button text
				x: x + borderSize * 2,
				y: y + borderSize * 2 + ((height - borderSize * 4) * 0.5) - Std.int(Math.min((((width - borderSize * 4) / (text.length * 0.8) + 4) / 3) * 4, (height - borderSize * 4)) * 0.5),
				width: width - borderSize * 4,
				height: (height - borderSize * 4),
				color: FlxColor.WHITE,
				text: text,
				font: Paths.font("Monocraft.ttf"),
				size: Std.int(Math.min((width - borderSize * 4) / (text.length * 0.8), (height - 4 - borderSize * 4) * 0.75)),
				align: CENTER,
			},
		];
	}
}
