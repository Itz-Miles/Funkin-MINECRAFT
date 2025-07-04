package;

import Song.SwagSong;

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
	@:optional var stepCrochet:Float;
}

class Conductor
{
	public static var bpm(default, set):Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet * 0.25; // steps in milliseconds
	public static var songPosition:Float = 0;
	public static var offset:Float = 0;

	public static var hitWindow:Float = ClientPrefs.data.hitWindow * 0.5;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	/*
		Ratings
	 */
	public static function judge(noteDelta:Float):Dynamic
	{
		for (rating in Ratings.list)
		{
			if (noteDelta <= Conductor.hitWindow * rating[2])
			{
				return rating;
			}
		}
		return Ratings.list[Ratings.list.length - 1];
	}

	public static function getAverageRating():Dynamic
	{
		if (PlayState.instance.noteJudges > 0)
		{
			return [
				getRatingName(PlayState.instance.noteRatings / PlayState.instance.noteJudges),
				PlayState.instance.noteRatings / PlayState.instance.noteJudges
			];
		}
		else
		{
			return ['?/10', null];
		}
	}

	public static function getRatingName(avgRating:Float):String
	{
		for (rating in Ratings.list)
		{
			if (rating[1] <= avgRating)
			{
				return rating[0];
			}
		}
		return '0/10';
	}

	/* 
		BPM stuff
	 */
	public static function getCrotchetAtTime(time:Float)
	{
		var lastChange = getBPMFromSeconds(time);
		return lastChange.stepCrochet * 4;
	}

	public static function getBPMFromSeconds(time:Float)
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm,
			stepCrochet: stepCrochet
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (time >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange;
	}

	public static function getBPMFromStep(step:Float)
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm,
			stepCrochet: stepCrochet
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.bpmChangeMap[i].stepTime <= step)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange;
	}

	public static function beatToSeconds(beat:Float):Float
	{
		var step = beat * 4;
		var lastChange = getBPMFromStep(step);
		return lastChange.songTime + ((step - lastChange.stepTime) / (lastChange.bpm / 60) * 0.25) * 1000; // TODO: rework and take BPM into account PROPERLY
	}

	public static function getStep(time:Float)
	{
		var lastChange = getBPMFromSeconds(time);
		return lastChange.stepTime + (time - lastChange.songTime) / lastChange.stepCrochet;
	}

	public static function getStepRounded(time:Float)
	{
		var lastChange = getBPMFromSeconds(time);
		return lastChange.stepTime + Math.floor(time - lastChange.songTime) / lastChange.stepCrochet;
	}

	public static function getBeat(time:Float)
	{
		return getStep(time) * 0.25;
	}

	public static function getBeatRounded(time:Float):Int
	{
		return Math.floor(getStepRounded(time) * 0.25);
	}

	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.sections.length)
		{
			if (song.sections[i].changeBPM && song.sections[i].bpm != curBPM)
			{
				curBPM = song.sections[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM,
					stepCrochet: calculateCrochet(curBPM) * 0.25
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = Math.round(getSectionBeats(song, i) * 4);
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 250) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	static function getSectionBeats(song:SwagSong, section:Int)
	{
		var val:Null<Float> = null;
		if (song.sections[section] != null)
			val = song.sections[section].beats;
		return val != null ? val : 4;
	}

	inline public static function calculateCrochet(bpm:Float)
	{
		return (60 / bpm) * 1000;
	}

	public static function set_bpm(newBPM:Float):Float
	{
		bpm = newBPM;
		crochet = calculateCrochet(bpm);
		stepCrochet = crochet * 0.25;

		return bpm = newBPM;
	}
}
