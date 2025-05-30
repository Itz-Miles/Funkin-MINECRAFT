package states;

import lime.system.System;
import objects.Character;
import backend.WeekData;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import haxe.Json;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import shaders.ColorSwap;
import states.StoryMenuState;
import states.OutdatedState;
import states.MainMenuState;

typedef TitleData =
{
	var titlex:Float;
	var titley:Float;
	var startx:Float;
	var starty:Float;
	var gfx:Float;
	var gfy:Float;
	var backgroundSprite:String;
	var bpm:Float;

	@:optional var animation:String;
	@:optional var dance_left:Array<Int>;
	@:optional var dance_right:Array<Int>;
	@:optional var idle:Bool;
}

class TitleState extends MusicBeatState
{
	public static var updateVersion:String = '';

	var logoBl:FlxSprite;
	var splashText:FlxText;
	var titleGF:Character;
	var transitioning:Bool;
	var gamepad:FlxGamepad;
	var pressedEnter:Bool;
	var swagShader:ColorSwap = null;
	var mustUpdate:Bool = false;

	override public function create():Void
	{
		#if CHECK_FOR_UPDATES
		if (ClientPrefs.data.checkForUpdates && !closedState)
		{
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/Itz-Miles/Funkin-MINECRAFT/main/gitVersion.txt");

			http.onData = function(data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if (updateVersion != curVersion)
				{
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function(error)
			{
				trace('error: $error');
			}

			http.request();
		}
		#end

		super.create();
		/*
			var bg:ParallaxBG = new ParallaxBG('arch');
			add(bg);
		 */

		titleGF = new Character(710, 220, "titleGF" /*, "shared"*/);
		add(titleGF);
		/*
			var fg:ParallaxFG = new ParallaxFG('arch');
			fg.setPosition(-130, -70);
			add(fg);
		 */

		logoBl = new FlxSprite(-15, -10).loadGraphic(Paths.image('logos/logo', "shared"));
		logoBl.updateHitbox();
		logoBl.antialiasing = ClientPrefs.data.antialiasing;
		add(logoBl);

		/*
			touch ANYWHERE to start!
			click ANYWHERE to start!
			press ANYTHING to start!
		 */
		splashText = new FlxText(0, 560, 0, ' click ANYWHERE to start! ', 80);
		splashText.setFormat(Paths.font("Monocraft.ttf"), 80, 0xffffff00, CENTER, OUTLINE, 0xffffbb00);
		splashText.borderSize = 4;
		splashText.antialiasing = ClientPrefs.data.antialiasing;
		splashText.screenCenter(X);
		add(splashText);
		FlxTween.tween(splashText.scale, {x: 0.96, y: 0.96}, 0.1, {ease: FlxEase.cubeOut, type: FlxTweenType.PERSIST});

		if (ClientPrefs.data.shaders)
		{
			swagShader = new ColorSwap();
			titleGF.shader = swagShader.shader;
			logoBl.shader = swagShader.shader;
		}

		FlxG.camera.flash(FlxG.camera.bgColor, 0.7);
		FlxG.camera.zoom = 3.5;
		FlxG.camera.scroll.y = 300;
		FlxTween.tween(FlxG.camera, {zoom: 1.0, "scroll.y": 0}, 1.8, {ease: FlxEase.quintOut});
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}

		if (FlxG.mouse.justPressed || controls.ACCEPT)
			pressedEnter = true;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (!transitioning)
		{
			if (pressedEnter)
			{
				FlxTween.completeTweensOf(splashText);
				FlxTween.completeTweensOf(logoBl);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.3);
				FlxTween.tween(splashText, {
					alpha: 0,
					"scale.x": 1.2,
					"scale.y": 1.2,
					y: 660
				}, 0.5, {ease: FlxEase.quadIn, type: FlxTweenType.PERSIST});
				FlxTween.tween(logoBl, {
					alpha: 0,
					"scale.x": 1.4,
					"scale.y": 1.4,
					x: -65,
					y: -100
				}, 0.5, {ease: FlxEase.quadIn, type: FlxTweenType.PERSIST});
				transitioning = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate)
						MusicBeatState.switchState(new OutdatedState());
					else
						MusicBeatState.switchState(new MainMenuState());
				});
			}
			if (controls.BACK)
			{
				transitioning = true;
				FlxG.camera.fade(#if html5 FlxColor.BLACK #else 0x0F0F0F #end, 2);
				FlxTween.tween(FlxG.sound.music, {pitch: 0}, 2, {
					ease: FlxEase.cubeIn,
					onComplete: function(twn:FlxTween)
					{
						System.exit(0);
					}
				});
			}
		}
		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();
		if (splashText != null && !transitioning)
			FlxTween.tween(splashText.scale, {x: 0.79, y: 0.79}, 0.165, {
				type: FlxTweenType.PERSIST,
				ease: FlxEase.cubeOut,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(splashText.scale, {x: 0.76, y: 0.76}, 0.165, {ease: FlxEase.cubeOut, type: FlxTweenType.PERSIST});
				}
			});
		if (logoBl != null && !transitioning)
			FlxTween.tween(logoBl.scale, {x: 1, y: 1}, 0.165, {
				type: FlxTweenType.PERSIST,
				ease: FlxEase.cubeOut,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(logoBl.scale, {x: 0.975, y: 0.975}, 0.165, {ease: FlxEase.cubeOut, type: FlxTweenType.PERSIST});
				}
			});

		if (titleGF != null)
		{
			titleGF.beatHit(curBeat);
		}
	}
}
