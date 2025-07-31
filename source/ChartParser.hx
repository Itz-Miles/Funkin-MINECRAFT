package;

import flixel.math.FlxMath;
import Section.SwagSection;
import Song.SwagSong;

using StringTools;

class ChartParser
{
	/**
	 * base game chart parsing;
	 * used with the current chart format that we have (from 0.2.8);
	 * @return an array full of notes from your chart data
	 */
	public static function parseSongChart(songData:SwagSong):Array<Note>
	{
		var lane:Array<SwagSection>;
		var unspawnNotes:Array<Note> = [];

		lane = songData.sections;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		for (section in lane)
		{
			for (songNotes in section.notes)
			{
				var daStrumTime:Float = songNotes[0];
				var dalane:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, dalane, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1] < 4));

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if (floorSus > 0)
				{
					for (susNote in 0...floorSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime
							+ (Conductor.stepCrochet * susNote)
							+ (Conductor.stepCrochet / FlxMath.roundDecimal(PlayState.instance.songSpeed, 2)),
							dalane, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1] < 4));
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += 1280 * 0.5; // general offset
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += 1280 * 0.5; // general offset
				}
			}
			daBeats += 1;
		}

		return unspawnNotes;
	}
}
