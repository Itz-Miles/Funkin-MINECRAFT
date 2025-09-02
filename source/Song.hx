package;

import Section.SwagSection;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

typedef SongData =
{
	var name:String;
	var sections:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var players:Array<String>;
	var opponents:Array<String>;
	var neutrals:Array<String>;
	var stage:String;
	var arrowSkin:String;
}

class Song
{
	public var name:String = "stalstruck";
	public var sections:Array<SwagSection> = [];
	public var events:Array<Dynamic> = [];
	public var bpm:Float = 159;
	public var needsVoices:Bool = false;
	public var arrowSkin:String = "";
	public var speed:Float = 1;
	public var stage:String = "aero_archways";
	public var players:Array<String> = ["bf"];
	public var opponents:Array<String> = ["dad"];
	public var neutrals:Array<String> = ["gf"];

	static function onLoadJson(songJson:Dynamic) // Convert old charts to newest format
	{
		if (songJson.name == null)
			songJson.name = songJson.song;
		songJson.song = null;
		if (songJson.neutrals == null)
		{
			songJson.neutrals[0] = songJson.player3;
			songJson.player3 = null;
			songJson.gfVersion = null;
		}
		if (songJson.opponents == null)
		{
			songJson.opponents[0] = songJson.player2;
			songJson.player2 = null;
		}
		if (songJson.players == null)
		{
			songJson.players[0] = songJson.player1;
			songJson.player1 = null;
		}

		if (songJson.sections == null)
			songJson.sections = songJson.notes;
		songJson.notes = null;

		for (secNum in 0...songJson.sections.length)
		{
			if (songJson.sections[secNum].beats == null)
			{
				songJson.sections[secNum].beats = songJson.sections[secNum].sectionBeats;
				songJson.sections[secNum].sectionBeats = null;
			}
			if (songJson.sections[secNum].notes == null)
			{
				songJson.sections[secNum].notes = songJson.sections[secNum].sectionNotes;
				songJson.sections[secNum].sectionNotes = null;
			}
		}
		if (songJson.events == null)
		{
			songJson.events = [];
			for (secNum in 0...songJson.sections.length)
			{
				var sec:SwagSection = songJson.sections[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.notes;
				var len:Int = notes.length;
				while (i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if (note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else
						i++;
				}
			}
		}
	}

	public function new(name, sections, bpm)
	{
		this.name = name;
		this.sections = sections;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SongData
	{
		var rawJson = null;

		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);

		rawJson = Assets.getText(Paths.json(formattedFolder + '/' + formattedSong)).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		var songJson:Dynamic = parseJSON(rawJson);
		if (jsonInput != 'events')
			LoadingState.stage = songJson.stage;
		onLoadJson(songJson);
		return songJson;
	}

	public static function parseJSON(rawJson:String):SongData
	{
		var swag:SongData = cast Json.parse(rawJson).song;
		return swag;
	}
}
