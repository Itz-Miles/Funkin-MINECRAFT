package states;

import flixel.FlxG;
import flixel.FlxState;

class MusicBeatState extends FlxState
{
	var curSection:Int = 0;
	var stepsToDo:Int = 0;

	var curStep:Int = 0;
	var curBeat:Int = 0;

	public static function getCurBeat()
	{
		return instance.curBeat;
	}

	public static var instance:MusicBeatState;

	var curDecStep:Float = 0;
	var curDecBeat:Float = 0;
	var controls(get, never):Controls;

	inline function get_controls():Controls
		return Controls.instance;

	override function create()
	{
	}

	override public function new()
	{
		super();
		instance = this;
	}

	override function update(elapsed:Float)
	{
		var oldStep:Int = curStep;
		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if (curStep > 0)
				stepHit();

			if (PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}
		super.update(elapsed);
	}

	function updateSection():Void
	{
		if (stepsToDo < 1)
			stepsToDo = Math.round(getBeatsOnSection() * 4);
		while (curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	function rollbackSection():Void
	{
		if (curStep < 0)
			return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.sections.length)
		{
			if (PlayState.SONG.sections[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if (stepsToDo > curStep)
					break;

				curSection++;
			}
		}

		if (curSection > lastSection)
			sectionHit();
	}

	function updateBeat():Void
	{
		curBeat = Math.floor(curStep * 0.25);
		curDecBeat = curDecStep * 0.25;
	}

	function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var currentTime = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + currentTime;
		curStep = lastChange.stepTime + Math.floor(currentTime);
	}

	public static function getState():MusicBeatState
	{
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// trace('Beat: ' + curBeat);
	}

	public function sectionHit():Void
	{
		// trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if (PlayState.SONG != null && PlayState.SONG.sections[curSection] != null)
			val = PlayState.SONG.sections[curSection].beats;
		return val == null ? 4 : val;
	}
}
