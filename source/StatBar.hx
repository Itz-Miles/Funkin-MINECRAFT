import flixel.group.FlxSpriteGroup;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.FlxSprite;

class StatBar extends FlxSpriteGroup
{
	var bossMode:Bool = false;
	var uiScale(default, set):Float = 1;

	var icon:HealthIcon;
	var healthBar:FlxBar;
	var prideBar:FlxBar;
	var nerveBar:FlxBar;
	var rageBar:FlxBar;

	function set_uiScale(value:Float)
	{
		return uiScale = value;
	}

	public function new()
	{
		super();
		prideBar = new FlxBar();
		add(prideBar);
	}

	public function regen():Void
	{
	}
}
