package editors;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
 * The Mod Editor serves as a hub for adding and creating mods.
 */
class ModEditor extends MusicBeatSubstate
{
	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite();
		bg.makeGraphic(1, 1, FlxG.camera.bgColor);
		bg.scale.set(1290, 730);
		bg.alpha = 0;
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);
		FlxTween.tween(bg, {alpha: 0.7}, 0.5, {ease: FlxEase.quintOut});

		var header:Panel = new Panel(LayerData.HEADER);
		header.text = "modify game content";
		header.runAcrossLayers(0);
		add(header);

		var button:Panel = new Panel(LayerData.createButton("modpack", 50 + 393, 250, 393, 196, 8, 24, 0xFF504D5B, null, function(obj)
		{
			FlxG.sound.play(Paths.sound('missnote1'), 0.3);
		}));
		button.visible = false;
		add(button);

		if (FlxG.save.data.showModEditorPopup == null)
			FlxG.save.data.showModEditorPopup = true;

		if (!FlxG.save.data.showModEditorPopup)
		{
			var popup:Panel = new Panel();
			popup.addLayers([
				{
					_functions: [
						function(obj)
						{
							obj.sprite.y = 50;
							obj.sprite.alpha = 0;
							FlxTween.tween(obj.sprite, {y: 0, alpha: 1}, 1.5, {ease: FlxEase.elasticOut, startDelay: 0.5});
						}
					]
				},
				{
					x: 50,
					y: 150,
					width: 1180,
					height: 520,
					color: 0xFF000000,
				},
				{
					x: 50,
					y: 150,
					width: 1180,
					height: 510,
					color: 0xFF444444
				},
				{
					x: 60,
					y: 160,
					width: 1160,
					height: 420,
					color: 0xFF222222,
				},
				{
					x: 60,
					y: 160,
					width: 1160,
					height: 8,
					color: 0xFF000000,
				},
				{
					x: 70,
					y: 170,
					width: 1140,
					height: 128,
					text: "Welcome to the Mod Editor!",
					size: 64,
					align: CENTER,
					font: Paths.font("Monocraft.ttf"),
					color: 0xFFFFFFFF
				},
				{
					x: 70,
					y: 260,
					width: 1140,
					height: 480,
					text: "lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
					size: 32,
					align: LEFT,
					font: Paths.font("Monocraft.ttf"),
					color: 0xFFFFFFFF
				}
			]);

			popup.addLayers(LayerData.createButton("ok, that's pretty cool!", 60, 590, 575, 50, 4, 8, 0xFF00AA00, function(obj)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.3);
				/*
					new FlxTimer().start(2.5, function(tmr)
					{
						//popup.kill();
					});
				 */
			}));

			popup.addLayers(LayerData.createButton("do NOT show me this again.", 645, 590, 575, 50, 4, 8, 0xFFAA0000, function(obj)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.3);
				FlxG.save.data.showModEditorPopup = false;
				FlxG.save.flush();

				new FlxTimer().start(0.25, function(tmr)
				{
					popup.kill();
					button.visible = true;
				});
			}));
			add(popup);

			popup.runAcrossLayers(0);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
		{
			close();
			FlxG.resetState();
		}
	}
}
