package;

import flixel.math.FlxMath;
import flixel.FlxCamera;
import haxe.ds.Vector;
import parallax.ParallaxDebugState;
import flixel.ui.FlxButton;
import parallax.ParallaxFG;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import editors.ChartingState;
#if desktop
import Discord.DiscordClient;
#end
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxObject;
import parallax.ParallaxBG;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var menuItems:Vector<FlxButton>;

	var sideBar:FlxSprite;
	var directoryBar:FlxSprite;
	var directoryTitle:FlxText;
	var menuBF:Character;
	var menuGF:Character;
	var camFollow:FlxObject;
	var loadedWeeks:Array<WeekData> = [];

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

		var fg:ParallaxFG = new ParallaxFG('arch', 0.2);
		fg.setPosition(-130, -70);
		add(fg);

		sideBar = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/sidebar gradient', "shared"));
		sideBar.scrollFactor.set(0, 0);
		sideBar.scale.set(1.4, 720);
		sideBar.origin.set(0, 0);
		sideBar.alpha = 0;
		add(sideBar);

		FlxTween.tween(sideBar, {alpha: 1, "scale.x": 1.76}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.4});

		menuItems = new Vector<FlxButton>(4);

		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			loadedWeeks.push(weekFile);
		}

		for (i in 0...4)
		{
			var menuItem:FlxButton = new FlxButton(-80, 60 + (i * 158) + (i * 7), "", function()
			{
				if (!selected)
					select();
			});
			menuItem.ID = i;
			menuItem.onOver.callback = function()
			{
				curSelection = menuItem.ID;
			};

			if (ClientPrefs.data.shaders)
				menuItem.blend = SCREEN;

			menuItem.labelAlphas = [0.7, 1.0, 0.6, 0.5];
			menuItem.loadGraphic(Paths.image('menus/item', "shared"), true, 50, 18);
			menuItem.setGraphicSize(447.04, 0);
			menuItem.updateHitbox();
			menuItem.antialiasing = false;
			menuItem.label.antialiasing = false;
			menuItem.label.letterSpacing = -3;
			menuItem.label.fieldWidth = 447.04;
			menuItem.label.fieldHeight = menuItem.height;
			menuItem.label.shadowOffset.set(-5, 0);
			menuItem.label.setFormat(Paths.font('Monocraft.ttf'), 64, 0xFFFFFFFF, CENTER, SHADOW, 0x76000000);
			menuItem.label.text = labels[i];
			menuItem.labelOffsets[0].set(0, 24);
			menuItem.labelOffsets[1].set(-2, 24);
			menuItem.labelOffsets[2].set(-6, 24);
			menuItem.scrollFactor.set(0, 0);
			menuItem.alpha = 0;
			menuItems.set(i, menuItem);
			add(menuItem);
			FlxTween.tween(menuItem, {alpha: 1, x: 0}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.4});
		}
		directoryBar = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/menubar gradient', "shared"));
		directoryBar.scrollFactor.set(0, 0);
		directoryBar.origin.set(0, 0);
		directoryBar.scale.set(1280, 0);
		add(directoryBar);
		FlxTween.tween(directoryBar, {"scale.y": 1}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.4});

		directoryTitle = new FlxText(0, -32, 0, "select a submenu", 36);
		directoryTitle.scrollFactor.set(0, 0);
		directoryTitle.setFormat(Paths.font('Minecrafter.ttf'), 36, 0xFF000000);
		directoryTitle.updateHitbox();
		directoryTitle.screenCenter(X);
		add(directoryTitle);
		FlxTween.tween(directoryTitle, {y: 12}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.4});

		Paths.clearUnusedMemory();

		super.create();
	}

	@:noCompletion
	static function set_curSelection(value:Int):Int
	{
		if (!selected)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.3);
			if (value > 3)
				value = 0;
			if (value < 0)
				value = 3;
			return curSelection = value;
		}
		return curSelection = curSelection;
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}
		if (!selected)
		{
			if (controls.BACK)
			{
				selected = true;
				curSelection = 5;
				FlxG.switchState(() -> new TitleState());
			}

			if (FlxG.keys.pressed.SEVEN)
				FlxG.switchState(() -> new ParallaxDebugState());
		}
		camFollow.x = FlxMath.bound(FlxG.mouse.screenX, 0, 1280);
		camFollow.y = FlxMath.bound(FlxG.mouse.screenY, 0, 720);
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

		FlxTween.completeTweensOf(sideBar);
		FlxTween.completeTweensOf(directoryTitle);
		FlxTween.completeTweensOf(directoryBar);
		FlxTween.tween(sideBar, {alpha: 0, "scale.x": 1.4}, 0.5, {ease: FlxEase.quintOut, startDelay: 0.0});
		FlxTween.tween(directoryTitle, {y: -32}, 0.5, {ease: FlxEase.quintOut, startDelay: 0.0});
		FlxTween.tween(directoryBar, {"scale.y": 0}, 0.5, {ease: FlxEase.quintOut, startDelay: 0.0});

		for (spr in menuItems)
		{
			FlxTween.completeTweensOf(spr);
			if (curSelection != spr.ID)
			{
				FlxTween.tween(spr, {alpha: 0, x: -80}, 0.5, {ease: FlxEase.quintOut, startDelay: 0.0});
			}
			else
			{
				FlxTween.tween(spr, {alpha: 0, x: -80}, 0.6, {ease: FlxEase.quintIn, startDelay: 0.4});
				FlxFlicker.flicker(spr, 1.1, 0.07, false);
			}
		}

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
