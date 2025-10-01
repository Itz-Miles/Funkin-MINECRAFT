package blockUI;

/**
 * The main header seen throughout the game.
 */
class Header extends FlxSpriteContainer
{
	public static var text(default, set):String;

	public static var instance:Header;

	static function set_text(value:String):String
	{
		// update the actual panel instance
		return text = value;
	}

	public function new()
	{
		super();

		init();
	}

	function init()
	{
		
	}
}
