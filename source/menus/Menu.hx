package menus;

/**
 * The Menu class
 */
class Menu extends FlxContainer
{
	public static var transitioning:Bool = true;
	public static var current:Menu;
	public static var previous:Menu;

	var bg:FlxSprite;
	var header:Panel;

	public function create()
	{
		bg = new FlxSprite().makeGraphic(1, 1, GameWorld.SKY_COLOR);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);
	}

	public function refresh()
	{
		if (bg != null)
		{
			bg.alpha = 0;
			FlxTween.tween(bg, {alpha: 0.5}, 0.5, {ease: FlxEase.quintOut});
		}
	}

	public function close()
	{
		Button.freeAll();
	}

	public function beatHit(?curBeat:Int)
	{
	}

	public function sectionHit(?curSection:Int)
	{
	}
}

var TITLE(get, default):TitleMenu;

function get_TITLE():TitleMenu
{
	if (TITLE == null)
		TITLE = new TitleMenu();
	return TITLE;
}

var MAIN(get, default):MainMenu;

function get_MAIN():MainMenu
{
	if (MAIN == null)
		MAIN = new MainMenu();
	return MAIN;
}

var ADVENTURE(get, default):AdventureMenu;

function get_ADVENTURE():AdventureMenu
{
	if (ADVENTURE == null)
		ADVENTURE = new AdventureMenu();
	return ADVENTURE;
}

var MOD(get, default):ModEditor;

function get_MOD():ModEditor
{
	if (MOD == null)
		MOD = new ModEditor();
	return MOD;
}

var SONG(get, default):SongEditor;

function get_SONG():SongEditor
{
	if (SONG == null)
		SONG = new SongEditor();
	return SONG;
}
