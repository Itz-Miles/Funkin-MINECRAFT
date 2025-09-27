package editors;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
 * The Mod Editor serves as a hub for adding and creating mods.
 */
class ModEditor extends Menu
{
	var popup:Panel;

	var content:Panel;

	static var editorLabels:Array<String> = ["adventure editor", "level editor", "character editor", "song editor"];

	override function create()
	{
		super.create();

		header = new Panel(LayerData.HEADER);
		header.text = "modify game content";
		add(header);

		content = new Panel();
		add(content);
		content.addLayers([
			{
				x: 60,
				y: 160,
				width: 600,
				height: 500,
				color: 0x70000000
			},
			{
				x: 720,
				y: 160,
				width: 500,
				height: 500,
				color: 0x70000000
			},
			{
				x: 70,
				y: 170,
				size: 32,
				font: Paths.font("Monocraft.ttf"),
				color: 0xFFFFFFFF,
				text: "load and configure modpacks",
				align: LEFT
			},
			{
				x: 740,
				y: 170,
				size: 32,
				font: Paths.font("Monocraft.ttf"),
				color: 0xFFFFFFFF,
				text: "...or create your own!",
				align: LEFT
			}
		]);

		for (i in 0...editorLabels.length)
		{
			content.addLayers(LayerData.createButton(editorLabels[i], 740, 240 + (102 * i), 460, 72, 4, 12, 0xFF4B4A4E, null, function(obj)
			{
				selectMenu(i);
			}));
		}

		if (FlxG.save.data.showModEditorPopup == null)
			FlxG.save.data.showModEditorPopup = true;

		if (!FlxG.save.data.showModEditorPopup)
		{
			popup = new Panel([]);
			popup.addLayers([
				{
					_functions: [
						function(obj)
						{
							obj.sprite.y = 50;
							obj.sprite.alpha = 0;
							FlxTween.tween(obj.sprite, {y: 0, alpha: 1}, 1.5, {ease: FlxEase.elasticOut, startDelay: 0.7});
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

			popup.addLayers(LayerData.createButton("ok, that's pretty cool!", 60, 590, 575, 50, 4, 8, 0xFF00AA00, null, null, function(obj)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.3);
				/*
					new FlxTimer().start(2.5, function(tmr)
					{
						//popup.kill();
					});
				 */
			}));

			popup.addLayers(LayerData.createButton("do NOT show me this again.", 645, 590, 575, 50, 4, 8, 0xFFAA0000, null, null, function(obj)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.3);
				FlxG.save.data.showModEditorPopup = false;
				FlxG.save.flush();

				new FlxTimer().start(0.25, function(tmr)
				{
					popup.kill();
					content.active = true;
				});
			}));
			add(popup);
		}
	}

	override public function refresh()
	{
		if (Menu.previous is MainMenu)
		{
			super.refresh();
		}
		content.active = false;
		header.runAcrossLayers(0);
		if (popup != null)
			popup.revive();
		popup.runAcrossLayers(0);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Controls.BACK)
		{
			Menu.switchTo(MainMenu);
		}
	}

	static function selectMenu(index:Int)
	{
		switch (index)
		{
			case 0:
				Menu.switchTo(AdventureEditor);
			case 1:
				Menu.switchTo(LevelEditor);
			case 2:
				Menu.switchTo(CharacterEditor);
			case 3:
				Menu.switchTo(SongEditor);
		}
	}
}
