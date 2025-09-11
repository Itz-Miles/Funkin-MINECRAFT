package states;

import menus.Menu;
import parallax.ParallaxBG;
import parallax.ParallaxFG;
import menus.StoryMenu;
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

	public static var BG:FlxContainer = new FlxContainer();

	public static var UI:FlxContainer = new FlxContainer();

	public static var FG:FlxContainer = new FlxContainer();

	public static function switchMenu(menu:Menu)
	{
		if (menu == null)
		{
			menu = Type.createInstance(Type.getClass(menu), []);
			menu.create();
			menu.refresh();
		}
		else
		{
			menu.refresh();
		}
	}

	override public function create():Void
	{
		super.create();
		instance = this;
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		// destroySubStates = false;
		// switchMenu(new TitleState());

		add(BG);
		add(UI);
		add(FG);

		var bg:ParallaxBG = new ParallaxBG('aero_archways', 0.2);
		BG.add(bg);

		var storyMenu:StoryMenu = new StoryMenu();
		storyMenu.create();
		UI.add(storyMenu);

		var fg:ParallaxFG = new ParallaxFG('aero_archways', 0.2);
		fg.setPosition(-130, -70);
		FG.add(fg);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
