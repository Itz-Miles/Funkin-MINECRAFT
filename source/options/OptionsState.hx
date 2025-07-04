package options;

import flixel.tweens.FlxEase;
#if desktop
import Discord.DiscordClient;
#end
import MainMenuState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

using StringTools;

class OptionsState extends MusicBeatState
{
	public static var fromPlayState:Bool = false;

	var options:Array<String> = [' Gameplay ', ' Graphics ', ' Controls ', ' Offsets '];
	var grpOptions:Array<FlxText>;

	static var curSelection(default, set):Int = 0;

	@:noCompletion
	static function set_curSelection(value:Int):Int
	{
		if (value != curSelection)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.3);
			if (value > 3)
				value = 0;
			if (value < 0)
				value = 3;
		}

		return curSelection = value;
	}

	var directoryBar:FlxSprite;
	var directoryTitle:FlxText;

	function openSelectedSubstate(label:String)
	{
		switch (label)
		{
			case ' Controls ':
				openSubState(new options.ControlsSubState());
			case ' Graphics ':
				openSubState(new options.GraphicsSubState());
			case ' Gameplay ':
				openSubState(new options.GameplaySubState());
			case ' Offsets ':
				LoadingState.loadAndSwitchState(new options.OffsetsState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if desktop
		DiscordClient.changePresence("Options", null);
		#end

		grpOptions = new Array<FlxText>();

		persistentDraw = persistentUpdate = false;

		for (i in 0...options.length)
		{
			var optionText:FlxText = new FlxText(0, 200 + (100 * i), 0, options[i]);
			optionText.setFormat(Paths.font("Monocraft.ttf"), 48, FlxG.camera.bgColor, CENTER, OUTLINE, 0xffffffff);
			optionText.ID = i;
			optionText.borderSize = 4;
			optionText.screenCenter(X);
			grpOptions.push(optionText);
			add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '[', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, ']', true);
		add(selectorRight);

		directoryBar = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.WHITE);
		directoryBar.scrollFactor.set(0, 0);
		directoryBar.origin.set(0, 0);
		directoryBar.scale.x = 1280;
		directoryBar.scale.y = 0;
		add(directoryBar);
		FlxTween.tween(directoryBar, {"scale.y": 60}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.4});

		directoryTitle = new FlxText(0, -32, 0, "overview your choices", 36);
		directoryTitle.scrollFactor.set(0, 0);
		directoryTitle.setFormat(Paths.font('Minecrafter.ttf'), 36, 0xFF000000);
		directoryTitle.updateHitbox();
		directoryTitle.screenCenter(X);
		add(directoryTitle);
		FlxTween.tween(directoryTitle, {y: 12}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.4});
		FlxG.camera.flash(FlxG.camera.bgColor, 0.4);
		curSelection = curSelection;
		updateItems();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
		{
			curSelection--;
			updateItems();
		}
		if (controls.UI_DOWN_P)
		{
			curSelection++;
			updateItems();
		}

		if (FlxG.mouse.deltaY != 0)
		{
			for (item in grpOptions)
			{
				if (item.ID != curSelection && FlxG.mouse.overlaps(item))
				{
					curSelection = item.ID;
					updateItems();
					if (FlxG.mouse.justPressed)
						openSelectedSubstate(options[curSelection]);
				}
			}
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'), 0.3);
			this.camera.fade(FlxG.camera.bgColor, 0.35, false, function()
			{
				if (PlayState.instance != null && OptionsState.fromPlayState)
				{ // Check if player came from playstate.
					FlxG.sound.music.volume = 0.0;
					LoadingState.stage = PlayState.SONG.stage;
					LoadingState.loadAndSwitchState(new PlayState());
					FlxG.sound.music.volume = 0;
					OptionsState.fromPlayState = false;
				}
				else
				{ // No? Then return to the main menu.
					Conductor.bpm = 100;
					FlxG.switchState(new MainMenuState());
				}
			}, true);
		}
		else if (controls.ACCEPT)
			openSelectedSubstate(options[curSelection]);
	}

	function updateItems()
	{
		for (item in grpOptions)
		{
			item.alpha = 0.6;
			if (item.ID == curSelection)
			{
				item.alpha = 1;
				selectorLeft.x = item.x - selectorLeft.width + 30;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width - 30;
				selectorRight.y = item.y;
			}
		}
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}
