package menus;

/**
 * The Menu class
 */
class Menu extends FlxSpriteContainer
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
		bg.screenCenter();
		add(bg);
	}

	public function refresh()
	{
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.5}, 0.5, {ease: FlxEase.quintOut});
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

var STORY(get, default):StoryMenu;

function get_STORY():StoryMenu
{
	if (STORY == null)
		STORY = new StoryMenu();
	return STORY;
}
