package options;

import blockUI.LayerData;
import blockUI.Panel;
import flixel.tweens.FlxEase;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

using StringTools;

class OptionsState extends MusicBeatSubstate
{
	public static var fromPlayState:Bool = false;

	var options:Array<String> = [' Gameplay ', ' Graphics ', ' Controls ', ' Offsets '];
	var grpOptions:Array<FlxText>;

	static var curSelection(default, set):Int = 0;

	var header:Panel;

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

		header = new Panel(LayerData.HEADER);
		header.text = "choose your preferences";
		header.runAcrossLayers();
		add(header);

		FlxG.camera.flash(FlxG.camera.bgColor, 0.4);
		curSelection = curSelection;
		updateItems();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		// header.text = "choose your preferences";
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Controls.UI_UP_P)
		{
			curSelection--;
			updateItems();
		}
		if (Controls.UI_DOWN_P)
		{
			curSelection++;
			updateItems();
		}

		for (item in grpOptions)
			if (FlxG.mouse.overlaps(item, this.camera))
			{
				if (item.ID != curSelection)
				{
					if (FlxG.mouse.deltaY != 0)
					{
						curSelection = item.ID;
						updateItems();
					}
				}
				else if (FlxG.mouse.justPressed)
					openSelectedSubstate(options[curSelection]);
			}

		if (Controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'), 0.3);
			header.runAcrossLayers(1);
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
					FlxG.switchState(() -> new MainMenuState());
				}
			}, true);
		}
		else if (Controls.ACCEPT)
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
