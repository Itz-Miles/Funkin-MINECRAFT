package menus;

import flixel.FlxBasic;
import haxe.ds.ObjectMap;

/**
 * The Menu class
 */
class Menu extends FlxContainer
{
	public static var cache:Map<String, Menu> = new Map();
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

	public function tryAdd(member:FlxBasic)
	{
		if (members.indexOf(member) == -1)
			add(member);
	}

	public function beatHit(?curBeat:Int)
	{
	}

	public function sectionHit(?curSection:Int)
	{
	}

	public static function switchTo<T:Menu>(menuClass:Class<Menu>)
	{
		Menu.previous = Menu.current;

		var key:String = Type.getClassName(menuClass);
		var menu:Menu = null;

		// reuse existing or create a new one
		if (cache.exists(key))
		{
			menu = cast cache.get(key);
		}
		else
		{
			menu = Type.createInstance(menuClass, []);
			cache.set(key, menu);
		}

		Menu.current = menu;

		// clear UI
		while (GameWorld.UI.length > 0)
		{
			GameWorld.UI.members[GameWorld.UI.members.length - 1].close();
			GameWorld.UI.remove(GameWorld.UI.members[GameWorld.UI.members.length - 1], true);
		}

		// init if first time
		if (menu.members.length < 1)
		{
			menu.create();
		}

		GameWorld.UI.add(menu);
		menu.refresh();
	}
}
