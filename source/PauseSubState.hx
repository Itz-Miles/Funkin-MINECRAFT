package;

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
	var menuItems:Array<String> = ['Resume', 'Respawn', 'Settings', 'Save and Quit'];
	var grpMenu:Array<FlxText>;

	public static var songName:String = '';

	var dead:Bool = !PlayState.instance.playerGroup[0].alive;

	var curSelection(default, set):Int = 0;

	@:noCompletion
	function set_curSelection(value:Int):Int
	{
		if (value != curSelection)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.3);
			if (value > menuItems.length)
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

	var directoryBar:FlxSprite;
	var directoryTitle:FlxText;

	public function new()
	{
		super();

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
		bg.scale.set(1280, 720);
		bg.alpha = 0;
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);
		FlxTween.tween(bg, {alpha: dead ? 0.8 : 0.6}, dead ? 1.6 : 0.4, {ease: FlxEase.quintOut});

		var directoryBar:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/menubar gradient', "shared"));
		directoryBar.scrollFactor.set(0, 0);
		directoryBar.origin.y = 0;
		directoryBar.scale.set(1280, 0);
		directoryBar.screenCenter(X);
		add(directoryBar);
		FlxTween.tween(directoryBar, {"scale.y": 1}, dead ? 1.6 : 0.4, {ease: FlxEase.quintOut});

		var directoryTitle:FlxText = new FlxText(0, -32, 0, dead ? "you have suffered defeat" : "the game is suspended", 36);
		directoryTitle.scrollFactor.set(0, 0);
		directoryTitle.setFormat(Paths.font('Minecrafter.ttf'), 36, 0xFF000000);
		directoryTitle.updateHitbox();
		directoryTitle.screenCenter(X);
		add(directoryTitle);
		FlxTween.tween(directoryTitle, {y: 12}, dead ? 1.6 : 0.4, {ease: FlxEase.quintOut});

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
			var item:FlxText = new FlxText(0, 200 + (100 * i), 0, menuItems[i], 48);
			item.screenCenter(X);
			item.scrollFactor.set();
			item.ID = i;
			grpMenu.push(item);
			add(item);
		}
		curSelection = 0;
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;

	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;

		super.update(elapsed);

		if (controls.UI_UP_P)
		{
			curSelection--;
		}
		if (controls.UI_DOWN_P)
		{
			curSelection++;
		}

		if (FlxG.mouse.deltaY != 0)
		{
			for (item in grpMenu)
				if (item.ID != curSelection && FlxG.mouse.overlaps(item, item.camera))
				{
					curSelection = item.ID;
				}
		}

		if (controls.ACCEPT)
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
				case "Save and Quit":
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
