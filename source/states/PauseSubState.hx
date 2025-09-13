package states;

import blockUI.LayerData;
import blockUI.Panel;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var menuItems:Array<String> = ['Resume', 'Respawn', 'Settings', 'Exit to Menu'];
	var grpMenu:Array<FlxText>;

	var dead:Bool = !PlayState.instance.playerGroup[0].alive;

	var curSelection(default, set):Int = 0;

	@:noCompletion
	function set_curSelection(value:Int):Int
	{
		if (value != curSelection)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.3);
			if (value > menuItems.length - 1)
				value = 0;
			if (value < 0)
				value = menuItems.length - 1;
		}
		for (item in grpMenu)
		{
			item.alpha = 0.6;
			if (item.ID == value)
			{
				item.alpha = 1;
			}
		}
		return curSelection = value;
	}

	public function new()
	{
		super();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		if (dead)
		{
			menuItems.remove('Resume');
		#if desktop
		DiscordClient.changePresence('Game Over - ${PlayState.instance.detailsText} ${PlayState.SONG.name})', PlayState.instance.playerGroup[0].character);
		}
		else
		{
			DiscordClient.changePresence('Paused - ${PlayState.instance.detailsText} ${PlayState.SONG.name})', PlayState.instance.playerGroup[0].character);
		#end
		}

		if (PlayState.chartingMode)
		{
			menuItems.insert(3, 'Leave Editor');
		}

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, dead ? 0xFF2E0000 : FlxColor.BLACK);
		bg.scale.set(1290, 730);
		bg.alpha = 0;
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);
		FlxTween.tween(bg, {alpha: dead ? 0.8 : 0.6}, dead ? 1.6 : 0.4, {ease: FlxEase.quintOut});

		var header:Panel = new Panel(LayerData.HEADER);
		header.text = dead ? "you have suffered defeat" : "the game is suspended";
		header.buttons[0].onClick = function()
		{
			close();
		};
		header.camera = this.camera;
		header.runAcrossLayers(0);
		add(header);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('Monocraft.ttf'), 32);
		chartingText.x = 1280 - (chartingText.width + 20);
		chartingText.y = 720 - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		grpMenu = new Array<FlxText>();

		for (i in 0...menuItems.length)
		{
			var item:FlxText = new FlxText(0, 175 + (100 * i), 0, menuItems[i], 48);
			item.screenCenter(X);
			item.scrollFactor.set();
			item.ID = i;
			grpMenu.push(item);
			add(item);
		}
		curSelection = 0;
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;

	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;

		super.update(elapsed);

		if (Controls.UI_UP_P)
		{
			curSelection--;
		}
		if (Controls.UI_DOWN_P)
		{
			curSelection++;
		}

		for (item in grpMenu)
			if (FlxG.mouse.overlaps(item, this.camera))
			{
				if (item.ID != curSelection)
				{
					if (FlxG.mouse.deltaY != 0)
					{
						curSelection = item.ID;
					}
				}
				else if (FlxG.mouse.justPressed)
					accept();
			}

		if (Controls.ACCEPT)
		{
			accept();
		}
	}

	function accept()
	{
		switch (menuItems[curSelection])
		{
			case "Resume":
				close();
			case "Respawn":
				restartSong();
			case "Settings":
				PlayState.seenCutscene = true;
				options.OptionsState.fromPlayState = true;
				Conductor.bpm = 100;
				this.camera.fade(FlxG.camera.bgColor, 0.1, false, function()
				{
					FlxG.sound.playMusic(Paths.music('where_are_we_going'));
					FlxG.sound.music.fadeIn(2, 0, 1);
					FlxG.switchState(() -> new options.OptionsState());
				}, true);

			case "Leave Editor":
				restartSong();
				PlayState.chartingMode = false;
			case "Exit to Menu":
				PlayState.seenCutscene = false;

				this.camera.fade(FlxG.camera.bgColor, 0.1, false, function()
				{
					PlayState.cancelMusicFadeTween();
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
					Conductor.bpm = 100;
					FlxG.sound.playMusic(Paths.music('where_are_we_going'));
					FlxG.sound.music.fadeIn(2, 0, 1);
					if (PlayState.isStoryMode)
					{
						FlxG.switchState(() -> new MainMenuState());
					}
					else
					{
						FlxG.switchState(() -> new FreeplayState());
					}
				}, true);
		}
	}

	public static function restartSong(noTrans:Bool = false)
	{
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if (noTrans)
		{
			FlxG.resetState();
		}
		else
		{
			FlxG.resetState();
		}
	}

	override function destroy()
	{
		super.destroy();
	}
}
