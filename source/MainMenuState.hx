package;

import blockUI.LayerData;
import blockUI.Layer;
import blockUI.Panel;
import flixel.math.FlxMath;
import parallax.ParallaxDebugState;
import parallax.ParallaxFG;
#if desktop
import Discord.DiscordClient;
#end
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxObject;
import parallax.ParallaxBG;
import flixel.text.FlxText;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var header:Panel;
	var sideBar:Panel;
	var menuBF:Character;
	var menuGF:Character;
	var camFollow:FlxObject;
	var loadedWeeks:Array<WeekData> = [];

	var backed:Bool = false;

	static var labels:Array<String> = ['story mode', 'freeplay', 'settings', 'credits'];
	public static var curSelection(default, set):Int = 5;
	static var selected:Bool = true;

	override function create()
	{
		Conductor.bpm = 100;

		WeekData.reloadWeekFiles(true);
		Difficulty.resetList();

		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;

		var bg:ParallaxBG = new ParallaxBG('arch', 0.2);
		add(bg);

		if (curSelection != 5)
			FlxG.camera.fade(FlxG.camera.bgColor, 0.5, true);

		curSelection = curSelection;
		selected = false;

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		FlxG.camera.follow(camFollow, NO_DEAD_ZONE, 0.07);
		menuBF = new Character(660, 180, 'bf_arch', "shared");
		menuBF.scrollFactor.set(0.565789474 * 0.2, 0.565789474 * 0.2);
		add(menuBF);

		menuGF = new Character(410, 222, 'menuGF', "shared");
		menuGF.color = 0x7D7D7B;
		menuGF.scrollFactor.set(0.27741228 * 0.2, 0.27741228 * 0.2);
		add(menuGF);

		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			loadedWeeks.push(weekFile);
		}
		sideBar = new Panel();

		for (i in 0...4)
		{
			sideBar.addLayer(
				{
					width: 326,
					height: 96,
					color: 0xCF0F0F0F,
					_functions: [
						function(obj)
						{
							obj.setPosition(-80, 160 + (i * 108) + (i * 7));
							if (ClientPrefs.data.shaders)
								obj.blend = MULTIPLY;
							obj.alpha = 0;
							FlxTween.tween(obj, {alpha: 1, x: 58}, 1.3, {ease: FlxEase.elasticOut, startDelay: 0.4 + (i * 0.1)});
						},
						function(obj)
						{
							FlxTween.completeTweensOf(obj);
							FlxTween.tween(obj, {alpha: 0, x: -326}, 1, {ease: FlxEase.quintOut, startDelay: 0.3 - (i * 0.1)});
						},
						function(obj)
						{
							FlxTween.completeTweensOf(obj);
							if (curSelection != i)
							{
								FlxTween.tween(obj, {alpha: 0, x: -80}, 0.5, {ease: FlxEase.quintOut});
							}
							else
							{
								FlxTween.tween(obj, {alpha: 0, x: 180}, 1, {ease: FlxEase.quintIn});
							}
						}
					]
				});
			sideBar.addLayer(
				{
					width: 326,
					height: 96,
					color: 0xC1444444,
					_functions: [
						function(obj)
						{
							obj.setPosition(-80, 150 + (i * 108) + (i * 7));
							obj.alpha = 0;
							FlxTween.tween(obj, {alpha: 1, x: 58}, 1.3, {ease: FlxEase.elasticOut, startDelay: 0.42 + (i * 0.1)});
						},
						function(obj)
						{
							FlxTween.completeTweensOf(obj);
							FlxTween.tween(obj, {alpha: 0, x: -326}, 1, {ease: FlxEase.quintOut, startDelay: 0.3 - (i * 0.1)});
						},
						function(obj)
						{
							FlxTween.completeTweensOf(obj);
							if (curSelection != i)
							{
								FlxTween.tween(obj, {alpha: 0, x: -80}, 0.5, {ease: FlxEase.quintOut});
							}
							else
							{
								FlxTween.tween(obj, {alpha: 0, x: 180}, 1, {ease: FlxEase.quintIn});
							}
						}

					],
					onHover: function(obj)
					{
						curSelection = i;
						for (release in sideBar.onRelease)
							release();
						sideBar.fields[i].alpha = 1;
						sideBar.fields[i].offset.y = 2;
						obj.offset.y = -44;
					},
					onRelease: function(obj)
					{
						if (curSelection != i)
						{
							sideBar.fields[i].alpha = 0.4;
							sideBar.fields[i].offset.y = 0;
							obj.offset.y = -48;
						}
					},
					onClick: function(obj)
					{
						select();
						sideBar.fields[i].offset.y = -2;
						obj.offset.y = -52;
					}
				});
		}
		for (i in 0...4)
		{
			sideBar.addLayer(
				{ // button
					width: 326,
					height: 96,
					text: "",
					size: 48,
					align: CENTER,
					font: Paths.font("Monocraft.ttf"),
					_functions: [
						function(obj)
						{
							var text:FlxText = cast obj;
							text.setPosition(-80, 165 + (i * 108) + (i * 7));
							text.alpha = 0;
							text.letterSpacing = -3;
							text.text = labels[i];
							FlxTween.tween(obj, {alpha: 0.4, x: 58}, 1.3, {ease: FlxEase.elasticOut, startDelay: 0.4 + (i * 0.1)});
						},
						function(obj)
						{
							FlxTween.completeTweensOf(obj);
							FlxTween.tween(obj, {alpha: 0, x: -326}, 1, {ease: FlxEase.quintOut, startDelay: 0.3 - (i * 0.1)});
						},
						function(obj)
						{
							FlxTween.completeTweensOf(obj);
							if (curSelection != i)
							{
								FlxTween.tween(obj, {alpha: 0, x: -80}, 0.5, {ease: FlxEase.quintOut});
							}
							else
							{
								FlxTween.tween(obj, {alpha: 0, x: 180}, 1, {ease: FlxEase.quintIn});
							}
						}
					]
				});
		}
		sideBar.runAcrossLayers(0);
		add(sideBar);

		header = new Panel(LayerData.HEADER);
		header.text = "select a submenu";
		header.runAcrossLayers(0);
		add(header);

		var fg:ParallaxFG = new ParallaxFG('arch', 0.2);
		fg.setPosition(-130, -70);
		add(fg);

		Paths.clearUnusedMemory();

		super.create();
	}

	@:noCompletion
	static function set_curSelection(value:Int):Int
	{
		if (value > 3)
			value = 0;
		if (value < 0)
			value = 3;

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
		if (controls.UI_UP_P)
		{
			for (release in sideBar.onRelease)
				release();

			curSelection--;

			sideBar.onHover[curSelection]();
		}
		if (controls.UI_DOWN_P)
		{
			for (release in sideBar.onRelease)
				release();

			curSelection++;
			sideBar.onHover[curSelection]();
		}

		if (controls.ACCEPT)
		{
			sideBar.onClick[curSelection]();
		}

		if (!selected)
		{
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.3);
				selected = true;
				backed = true;

				FlxTween.completeTweensOf(header);
				header.runAcrossLayers(1);

				sideBar.runAcrossLayers(1);

				new FlxTimer().start(1.1, function(tmr:FlxTimer)
				{
					FlxG.switchState(() -> new TitleState());
				});
			}
		}
		if (backed)
		{
			camFollow.x = FlxMath.bound(FlxG.mouse.viewX, 640, 640);
			camFollow.y = FlxMath.bound(FlxG.mouse.viewY, 360, 360);
		}
		else
		{
			camFollow.x = FlxMath.bound(FlxG.mouse.viewX, 0, 1280);
			camFollow.y = FlxMath.bound(FlxG.mouse.viewY, 0, 720);
		}
		if (FlxG.keys.pressed.SEVEN)
			FlxG.switchState(() -> new ParallaxDebugState());
		super.update(elapsed);
	}

	override function beatHit()
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
			sideBar.onHover[curSelection]();
		});

		if (curSelection == 0)
		{
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[0].songs;
			for (i in 0...leWeek.length)
			{
				songArray.push(leWeek[i][0]);
			}

			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;

			var diffic = Difficulty.getFilePath(1);
			if (diffic == null)
				diffic = '';

			PlayState.storyDifficulty = 1;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
		}
		else
		{
			new FlxTimer().start(0.8, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxG.camera.bgColor, 0.3, false);
			});
		}

		new FlxTimer().start(1.1, function(tmr:FlxTimer)
		{
			switch (curSelection)
			{
				case 0:
					LoadingState.loadAndSwitchState(new PlayState(), true);
				case 1:
					// FlxG.switchState(()-> new ChartingState());
					FlxG.switchState(() -> new FreeplayState());
				case 2:
					FlxG.switchState(() -> new options.OptionsState());
				case 3:
					FlxG.switchState(() -> new CreditsState());
			}
		});
	}
}
