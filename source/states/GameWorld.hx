package states;

import flixel.math.FlxMath;
import menus.Menu;
import parallax.ParallaxBG;
import parallax.ParallaxFG;
import Song.SongData;

/**
 * The Game World state, used for gameplay.
 */
class GameWorld extends MusicBeatState
{
	public static var player:TestChar;
	public static var GRAVITY:Float = 9.8;

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
	public static var SKY_COLOR(default, set):FlxColor = 0xff82aafa;

	static function set_SKY_COLOR(value:FlxColor):FlxColor
	{
		FlxG.camera.bgColor = value;
		return SKY_COLOR = value;
	}

	static var _targetEnvColor:FlxColor = SKY_COLOR;

	public static var BG:FlxGroup = new FlxGroup();

	public static var UI:FlxTypedGroup<Menu> = new FlxTypedGroup<Menu>();

	public static var FG:FlxGroup = new FlxGroup();

	var speed:FlxText;

	override public function create():Void
	{
		super.create();

		FlxG.sound.playMusic(Paths.music('where_are_we_going'), 0);

		FlxG.sound.music.fadeIn(4, 0, 1);

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		add(BG);

		player = new TestChar(100, 100, 100, 125, 10);
		add(player);

		speed = new FlxText(500, 560, 500, "", 24);
		speed.alignment = LEFT;
		speed.scrollFactor.set();
		add(speed);

		add(UI);
		add(FG);

		var bg:ParallaxBG = new ParallaxBG('aero_archways');
		BG.add(bg);

		var fg:ParallaxFG = new ParallaxFG('aero_archways');
		fg.setPosition(-130, -70);
		FG.add(fg);

		Menu.switchTo(TitleMenu);
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		speed.text = 'speed (mps): ${FlxMath.roundDecimal(player.velocity.x / Physics.BLOCK_SIZE, 3)}';

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
