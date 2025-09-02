package states;

import Song.SongData;

/**
 * The Game World state, used for gameplay.
 */
class GameWorld extends MusicBeatState
{
	/**
	 * The currently loaded SongData
	 */
	public static var SONG:SongData;

	/**
	 * The current Difficulty
	 */
	public static var DIFFICULTY:Difficulty = NORMAL; // replace with Difficulty enum later

	/**
	 * Whether or not the game is in Story Mode
	 */
	public static var STORY_MODE:Bool = false;

	/**
	 * The current sky color.
	 */
	public static var ENVIONMENT_COLOR:FlxColor = FlxColor.CYAN;

	var _targetEnvColor:FlxColor = ENVIONMENT_COLOR;

	override public function create():Void
	{
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
