package menus;

import lime.system.System;

class TitleMenu extends Menu
{
	var titleGF:Character;
	var logo:FlxSprite;

	var splashText:FlxText;

	override public function create()
	{
		Paths.clearUnusedMemory();

		titleGF = new Character(710, 220, "titleGF", "shared"); // for now
		add(titleGF);
		titleGF.scrollFactor.set(0.565789474, 0.565789474);

		logo = new FlxSprite(-15, -10).loadGraphic(Paths.image('logos/logo', "shared"));
		logo.antialiasing = ClientPrefs.data.antialiasing;
		add(logo);

		splashText = new FlxText(0, 560, 0, '', 1);
		splashText.bold = true;
		splashText.setFormat(Paths.font("Monocraft.ttf"), 72, 0xFFffda2a, CENTER, SHADOW_XY(0, 6), 0xff725728);
		splashText.text = 'click ANYWHERE to start!';
		splashText.antialiasing = ClientPrefs.data.antialiasing;
		splashText.screenCenter(X);
		add(splashText);
	}

	override public function refresh()
	{
		logo.y = -10;
		splashText.y = 560;
		Menu.transitioning = false;
		if (Menu.previous != null)
		{
			logo.alpha = 0;
			FlxTween.tween(logo, {alpha: 1}, 0.5, {ease: FlxEase.cubeIn});
			splashText.alpha = 0;
			FlxTween.tween(splashText, {alpha: 1}, 0.5, {ease: FlxEase.cubeIn});
		}
		else
		{
			FlxG.camera.flash(FlxG.camera.bgColor, 0.7);
			FlxG.camera.zoom = 3.5;
			FlxG.camera.scroll.y = 400;
			FlxTween.tween(FlxG.camera, {zoom: 1.0, "scroll.y": 0}, 1.8, {ease: FlxEase.quintOut});
		}
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < 1)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}
		if (!Menu.transitioning)
		{
			if (FlxG.mouse.justPressed || Controls.ACCEPT)
			{
				FlxTween.cancelTweensOf(splashText);
				FlxTween.cancelTweensOf(logo);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.3);
				// @formatter:off
				FlxTween.tween(splashText, {alpha: 0, "scale.x": 1.2,"scale.y": 1.2, y: 660}, 0.5, {ease: FlxEase.quadIn});
				// @formatter:on
				FlxTween.tween(logo, {alpha: 0, "scale.x": 1.4, "scale.y": 1.4}, 0.5, {ease: FlxEase.quadIn});

				Menu.transitioning = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					Menu.switchTo(MainMenu);
				});
			}

			if (Controls.BACK)
			{
				Menu.transitioning = true;
				FlxG.camera.fade(#if html5 FlxColor.BLACK #else 0xFF0F0F0F #end, 2, false);
				FlxTween.tween(FlxG.sound.music, {pitch: 0}, 2,
					{
						ease: FlxEase.cubeIn,
						onComplete: function(twn:FlxTween)
						{
							FlxG.sound.play(Paths.sound('fnf_loss_sfx'), 1);
							new FlxTimer().start(0.25, function(tmr:FlxTimer)
							{
								System.exit(0);
							});
						}
					});
			}
		}
		super.update(elapsed);
	}

	override public function beatHit(?curBeat:Int)
	{
		super.beatHit(curBeat);

		if (!Menu.transitioning)
		{
			if (splashText != null)
				FlxTween.tween(splashText.scale, {x: 1, y: 1}, 0.165,
					{
						ease: FlxEase.cubeOut,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(splashText.scale, {x: 0.975, y: 0.975}, 0.165, {ease: FlxEase.cubeOut});
						}
					});
			if (logo != null)
				FlxTween.tween(logo.scale, {x: 1, y: 1}, 0.165,
					{
						ease: FlxEase.cubeOut,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(logo.scale, {x: 0.975, y: 0.975}, 0.165, {ease: FlxEase.cubeOut});
						}
					});
		}

		if (titleGF != null)
		{
			titleGF.beatHit(curBeat);
		}
	}
}
