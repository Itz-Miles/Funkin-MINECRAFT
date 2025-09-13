package states;

import menus.Menu;
import parallax.ParallaxBG;
import parallax.ParallaxFG;
import Song.SongData;

/**
 * The Game World state, used for gameplay.
 */
class GameWorld extends MusicBeatState
{
	/**
	 * The Game World's instance.
	 */
	public static var instance:GameWorld;

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

	public static var BG:FlxGroup = new FlxGroup();

	public static var UI:FlxTypedGroup<Menu> = new FlxTypedGroup<Menu>();

	public static var FG:FlxGroup = new FlxGroup();

	public static function switchMenu(menu:Menu)
	{
		while (UI.length > 0)
		{
			UI.remove(UI.members[UI.members.length - 1], true);
		}

		if (menu.members.length < 1)
		{
			// trace("creating: " + Type.getClassName(Type.getClass(menu)));
			menu.create();
			UI.add(menu);
			menu.refresh();
		}
		else
		{
			// trace("refreshing: " + Type.getClassName(Type.getClass(menu)));
			UI.add(menu);
			menu.refresh();
		}
	}

	override public function create():Void
	{
		super.create();
		instance = this;
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		add(BG);
		add(UI);
		add(FG);

		var bg:ParallaxBG = new ParallaxBG('aero_archways', 0.2);
		BG.add(bg);

		var fg:ParallaxFG = new ParallaxFG('aero_archways', 0.2);
		fg.setPosition(-130, -70);
		FG.add(fg);
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	override public function beatHit()
	{
		super.beatHit();

		for (i in 0...UI.members.length)
		{
			UI.members[i].beatHit();
		}
	}

	override public function sectionHit()
	{
		super.sectionHit();

		for (i in 0...UI.members.length)
		{
			UI.members[i].sectionHit();
		}
	}
}
