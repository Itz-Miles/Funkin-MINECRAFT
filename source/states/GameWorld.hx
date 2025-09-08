package states;

import Song.SongData;

/**
 * The Game World state, used for gameplay.
 */
class GameWorld extends MusicBeatState
{
	/**
	 * The Game World's instance.
	 */
	static var instance:GameWorld;

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
	public static var SKY_COLOR(default, set):FlxColor = FlxColor.CYAN;

	static function set_SKY_COLOR(value:FlxColor):FlxColor
	{
		FlxG.camera.bgColor = value;
		return SKY_COLOR = value;
	}

	static var _targetEnvColor:FlxColor = SKY_COLOR;

	public static function switchMenu(state:FlxSubState)
	{
		instance.closeSubState();
		instance.openSubState(state);
	}

	override public function create():Void
	{
		super.create();
		instance = this;
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		// destroySubStates = false;
		switchMenu(new TitleState());
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
