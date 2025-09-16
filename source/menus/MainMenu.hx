package menus;

#if desktop
import Discord.DiscordClient;
#end
import flixel.math.FlxMath;

class MainMenu extends Menu
{
	var sideBar:Panel;
	var menuBF:Character;
	var menuGF:Character;
	var camFollow:FlxObject;
	var loadedWeeks:Array<WeekData> = [];

	var backed:Bool = false;

	static var labels:Array<String> = ['story mode', 'freeplay', 'settings', 'modpacks', 'credits'];
	public static var curSelection(default, set):Int = 5;
	static var selected:Bool = true;

	override function create()
	{
		Conductor.bpm = 100;

		WeekData.reloadWeekFiles(true);

		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (curSelection != 5)
			FlxG.camera.fade(FlxG.camera.bgColor, 0.5, true);

		curSelection = curSelection;
		selected = false;

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		FlxG.camera.follow(camFollow, NO_DEAD_ZONE, 0.07);
		menuBF = new Character(660, 180, 'bf_arch', "shared");
		menuBF.scrollFactor.set(0.565789474, 0.565789474);
		add(menuBF);

		menuGF = new Character(410, 222, 'menuGF', "shared");
		menuGF.color = 0x7D7D7B;
		menuGF.scrollFactor.set(0.27741228, 0.27741228);
		add(menuGF);

		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			loadedWeeks.push(weekFile);
		}
		sideBar = new Panel();

		for (i in 0...5)
		{
			for (j in 0...3)
			{
				sideBar.addLayer(
					{
						width: 340,
						height: 84,
						color: j == 0 ? 0xCF0F0F0F : j == 1 ? 0xC1444444 : 0xFFFFFFFF,
						text: j == 2 ? labels[i] : null,
						align: CENTER,
						font: Paths.font("Monocraft.ttf"),
						size: 48,
						_functions: [
							function(obj)
							{
								obj.sprite.setPosition(-80, 140 + (i * 94) + (i * 10));

								if (j == 0 && ClientPrefs.data.shaders)
									obj.sprite.blend = MULTIPLY;
								else if (j == 1)
									obj.sprite.offset.y = -35;
								obj.sprite.alpha = 0;
								FlxTween.tween(obj.sprite, {alpha: j == 2 ? 0.4 : 1, x: 58}, 1.3, {ease: FlxEase.elasticOut, startDelay: 0.4 + (i * 0.1)});
							},
							function(obj)
							{
								FlxTween.tween(obj.sprite, {alpha: 0, x: -326}, 1, {ease: FlxEase.quintOut, startDelay: 0.4 - (i * 0.1)});
							},
							function(obj)
							{
								FlxTween.completeTweensOf(obj.sprite);
								if (curSelection != i)
									FlxTween.tween(obj.sprite, {alpha: 0, x: -80}, 0.5, {ease: FlxEase.quintOut});
								else
									FlxTween.tween(obj.sprite, {alpha: 0, x: 180}, 1, {ease: FlxEase.quintIn});
							},
						],
						onHover: j == 1 ? function(obj)
						{
							curSelection = i;
							for (button in sideBar.buttons)
								button.onRelease();

							sideBar.fields[i].alpha = 1;
							sideBar.fields[i].offset.y = 2;
							obj.sprite.offset.y = -30;
						} : null,
						onRelease: j == 1 ? function(obj)
						{
							if (curSelection != i)
							{
								sideBar.fields[i].alpha = 0.4;
								sideBar.fields[i].offset.y = 0;
								obj.sprite.offset.y = -35;
							}
						} : null,
						onClick: j == 1 ? function(obj)
						{
							select();
							sideBar.fields[i].offset.y = -2;
							obj.sprite.offset.y = -38;
						} : null
					});
			}
		}

		sideBar.runAcrossLayers(0);
		add(sideBar);

		header = new Panel(LayerData.HEADER);
		header.text = "select a submenu";
		header.runAcrossLayers(0);
		add(header);

		Paths.clearUnusedMemory();
	}

	override public function refresh()
	{
	}

	@:noCompletion
	static function set_curSelection(value:Int):Int
	{
		if (value > labels.length - 1)
			value = 0;
		if (value < 0)
			value = labels.length - 1;

		if (!selected && curSelection != value)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.3);
		}
		return curSelection = value;
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}
		if (Controls.UI_UP_P)
		{
			for (button in sideBar.buttons)
				button.onRelease();

			curSelection--;

			sideBar.buttons[curSelection].onHover();
		}
		if (Controls.UI_DOWN_P)
		{
			for (button in sideBar.buttons)
				button.onRelease();

			curSelection++;
			sideBar.buttons[curSelection].onHover();
		}

		if (Controls.ACCEPT)
		{
			sideBar.buttons[curSelection].onClick();
		}

		if (!selected)
		{
			if (Controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.3);
				selected = true;
				backed = true;

				FlxTween.completeTweensOf(header);
				header.runAcrossLayers(1);

				sideBar.runAcrossLayers(1);

				new FlxTimer().start(1.1, function(tmr:FlxTimer)
				{
					GameWorld.switchMenu(Menu.TITLE);
				});
			}
		}
		if (backed)
		{
			camFollow.x = 640;
			camFollow.y = 360;
		}
		else
		{
			camFollow.x = 640 + 0.2 * (FlxMath.bound(FlxG.mouse.viewX, 0, 1280) - 640);
			camFollow.y = 360 + 0.2 * (FlxMath.bound(FlxG.mouse.viewY, 0, 720) - 360);
		}
		super.update(elapsed);
	}

	override function beatHit(?curBeat:Int)
	{
		super.beatHit();

		menuGF.dance();
		menuBF.dance(true);
	}

	function select()
	{
		selected = true;

		menuGF.hey(1);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.3);

		FlxTween.completeTweensOf(header);
		header.runAcrossLayers(1);
		sideBar.runAcrossLayers(2);

		new FlxTimer().start(0.25, function(tmr:FlxTimer)
		{
			sideBar.buttons[curSelection].onHover();
		});

		if (curSelection == 0)
		{
			/*
				FlxG.sound.music.fadeOut(1);
				var songArray:Array<String> = [];
				var leWeek:Array<Dynamic> = loadedWeeks[0].songs;
				for (i in 0...leWeek.length)
				{
					songArray.push(leWeek[i][0]);
				}

				PlayState.storyPlaylist = songArray;
				PlayState.isStoryMode = true;

				PlayState.storyDifficulty = 1;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
			 */
		}
		else
		{
			new FlxTimer().start(0.8, function(tmr:FlxTimer)
			{
				// FlxG.camera.fade(FlxG.camera.bgColor, 0.3, false);
			});
		}

		new FlxTimer().start(1.1, function(tmr:FlxTimer)
		{
			switch (curSelection)
			{
				case 0:
					GameWorld.switchMenu(Menu.STORY);
				case 1:
					// GameWorld.switchMenu(new FreeplayState());
				case 2:
					// GameWorld.switchMenu(new options.OptionsState());
				case 3:
					// GameWorld.switchMenu(new ModEditor());
				case 4:
					// GameWorld.switchMenu(new CreditsState());
			}
		});
	}
}
