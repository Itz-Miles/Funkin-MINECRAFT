package menus;

import flixel.math.FlxMath;
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

	var header:Panel;

	public function create()
	{
	}

	public function refresh()
	{
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (MainMenu.camFollow != null)
		{
			MainMenu.camFollow.x = 640 + 0.2 * (FlxMath.bound(FlxG.mouse.viewX, 0, 1280) - 640);
			MainMenu.camFollow.y = 360 + 0.2 * (FlxMath.bound(FlxG.mouse.viewY, 0, 720) - 360);
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
