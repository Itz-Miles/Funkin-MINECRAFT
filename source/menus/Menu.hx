package menus;

/**
 * The Menu class
 */
class Menu extends FlxSpriteContainer
{
	var bg:FlxSprite;

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
}

var STORY(get, default):StoryMenu;

function get_STORY():StoryMenu
{
	if (STORY == null)
		STORY = new StoryMenu();
	return STORY;
}
