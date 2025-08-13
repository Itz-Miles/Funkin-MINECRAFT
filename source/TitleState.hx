package;

import lime.system.System;
import parallax.ParallaxBG;
import parallax.ParallaxFG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

class TitleState extends MusicBeatState
{
	var logoBl:FlxSprite;
	var splashText:FlxText;
	var titleGF:Character;
	var transitioning:Bool;
	var gamepad:FlxGamepad;
	var pressedEnter:Bool;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		super.create();

		var bg:ParallaxBG = new ParallaxBG('arch');
		add(bg);

		titleGF = new Character(710, 220, "titleGF", "shared");
		add(titleGF);

		logoBl = new FlxSprite(-15, -10).loadGraphic(Paths.image('logos/logo', "shared"));
		logoBl.updateHitbox();
		logoBl.antialiasing = ClientPrefs.data.antialiasing;
		add(logoBl);

		splashText = new FlxText(0, 560, 0, ' click ANYWHERE to start! ', 80);
		splashText.setFormat(Paths.font("Monocraft.ttf"), 80, 0xffffff00, CENTER, OUTLINE, 0xffdea300);
		splashText.borderSize = 4;
		splashText.antialiasing = ClientPrefs.data.antialiasing;
		splashText.screenCenter(X);
		add(splashText);

		if (MainMenuState.curSelection != 5)
		{
			logoBl.alpha = 0;
			FlxTween.tween(logoBl, {alpha: 1}, 0.5, {ease: FlxEase.cubeIn});
			splashText.alpha = 0;
			FlxTween.tween(splashText, {alpha: 1}, 0.5, {ease: FlxEase.cubeIn});
			@:bypassAccessor MainMenuState.curSelection = 5;
		}
		else
		{
			FlxG.camera.flash(FlxG.camera.bgColor, 0.7);
			FlxG.camera.zoom = 3.5;
			FlxG.camera.scroll.y = 300;
			FlxTween.tween(FlxG.camera, {zoom: 1.0, "scroll.y": 0}, 1.8, {ease: FlxEase.quintOut});
		}

		FlxTween.tween(splashText.scale, {x: 0.96, y: 0.96}, 0.1, {ease: FlxEase.cubeOut});

		var fg:ParallaxFG = new ParallaxFG('arch');
		fg.setPosition(-130, -70);
		add(fg);

		/*
			touch ANYWHERE to start!
			click ANYWHERE to start!
			press ANYTHING to start!
		 */
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
				FlxTween.tween(splashText,
					{
						alpha: 0,
						"scale.x": 1.2,
						"scale.y": 1.2,
						y: 660
					}, 0.5, {ease: FlxEase.quadIn, type: FlxTweenType.PERSIST});
				FlxTween.tween(logoBl,
					{
						alpha: 0,
						"scale.x": 1.4,
						"scale.y": 1.4,
						x: -65,
						y: -100
					}, 0.5, {ease: FlxEase.quadIn, type: FlxTweenType.PERSIST});
				transitioning = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxG.switchState(() -> new MainMenuState());
				});
			}
			if (controls.BACK)
			{
				transitioning = true;
				FlxG.camera.fade(#if html5 FlxColor.BLACK #else 0xFF0F0F0F #end, 2, false);
				FlxTween.tween(FlxG.sound.music, {pitch: 0}, 2,
					{
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
			FlxTween.tween(splashText.scale, {x: 0.79, y: 0.79}, 0.165,
				{
					type: FlxTweenType.PERSIST,
					ease: FlxEase.cubeOut,
					onComplete: function(twn:FlxTween)
					{
						FlxTween.tween(splashText.scale, {x: 0.76, y: 0.76}, 0.165, {ease: FlxEase.cubeOut, type: FlxTweenType.PERSIST});
					}
				});
		if (logoBl != null && !transitioning)
			FlxTween.tween(logoBl.scale, {x: 1, y: 1}, 0.165,
				{
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
