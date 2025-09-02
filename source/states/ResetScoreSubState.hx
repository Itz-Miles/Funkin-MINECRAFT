package states;

import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;

using StringTools;

class ResetScoreSubState extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var FlxTextArray:Array<FlxText> = [];
	var onYes(default, set):Bool = false;
	var yesText:FlxText;
	var noText:FlxText;
	var volume:Float;
	var song:String;
	var difficulty:Int;
	var week:Int;

	// Week -1 = Freeplay
	public function new(song:String, difficulty:Int, character:String, week:Int = -1)
	{
		this.song = song;
		this.difficulty = difficulty;
		this.week = week;

		super();

		var name:String = song;
		if (week > -1)
		{
			name = WeekData.weeksLoaded.get(WeekData.weeksList[week]).weekName;
		}
		// name += ' (' + Difficulty.getString(difficulty) + ')?';

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		bg.origin.set();
		bg.scale.set(1280, 720);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		FlxTween.tween(bg, {alpha: 1}, 0.5);

		var resetText:FlxText = new FlxText(0, 80, 0, "discard your save data", 72);
		resetText.setFormat(Paths.font('Minecrafter.ttf'), 72, 0xFF000000);
		resetText.screenCenter(X);
		FlxTextArray.push(resetText);
		resetText.alpha = 0;
		add(resetText);
		var text:FlxText = new FlxText(0, resetText.y + 90, 0, name, 32);
		text.setFormat(Paths.font('Monocraft.ttf'), 64, 0xFF000000);
		text.screenCenter(X);
		FlxTextArray.push(text);
		text.alpha = 0;
		add(text);

		yesText = new FlxText(0, text.y + 250, 0, 'Yes', 48);
		yesText.screenCenter(X);
		yesText.setFormat(Paths.font('Monocraft.ttf'), 48, FlxG.camera.bgColor);
		yesText.x -= 200;
		add(yesText);
		noText = new FlxText(0, text.y + 250, 0, 'No', 48);
		noText.setFormat(Paths.font('Monocraft.ttf'), 48, FlxG.camera.bgColor);
		noText.screenCenter(X);
		noText.x += 200;
		add(noText);

		volume = FlxG.sound.music.volume;
		FlxG.sound.music.fadeOut(2);
		onYes = false;
	}

	override function close()
	{
		FlxG.sound.music.fadeIn(1.5, 0, volume);
		super.close();
	}

	override function update(elapsed:Float)
	{
		for (i in 0...FlxTextArray.length)
		{
			var spr = FlxTextArray[i];
			spr.alpha += elapsed * 2.5;
		}

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.3);
			onYes = !onYes;
		}
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'), 0.3);
			close();
		}
		else if (controls.ACCEPT)
		{
			if (onYes)
			{
				if (week == -1)
				{
					Highscore.resetSong(song, difficulty);
				}
				else
				{
					Highscore.resetWeek(WeekData.weeksList[week], difficulty);
				}
			}
			FlxG.sound.play(Paths.sound('cancelMenu'), 0.3);
			close();
		}
		super.update(elapsed);
	}

	function set_onYes(value:Bool)
	{
		if (value)
		{
			yesText.scale *= 1.06;
			yesText.alpha = 1;
			noText.alpha = 0.5;
		}
		else
		{
			noText.scale *= 1.06;
			noText.alpha = 1;
			yesText.alpha = 0.5;
		}
		return onYes = value;
	}
}
