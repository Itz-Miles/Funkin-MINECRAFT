import flixel.util.FlxColor;

class Level
{
	/**
	 * A list of the level directories found in the filesystem.
	 */
	public static var levelsList:Array<String>;

	public static function reloadList()
	{
		levelsList = CoolUtil.coolTextFile(Paths.getPreloadPath('levels/levels.txt'));
		trace('Levels: $levelsList');
	}
}

typedef LevelData =
{
	var chunks:Array<Array<Chunk>>;
}

typedef Chunk =
{
	/**
	 * A list of this chunk's level objects.
	 */
	var objects:Array<LevelObject>;

	/**
	 * OPTIONAL: This chunk's bgColor to fade into.
	 */
	var ?bgColor:FlxColor;
}

typedef LevelObject =
{
	/**
	 * Releative x coordinate.
	 */
	var ?x:Int;

	/**
	 * Releative y coordinate.
	 */
	var ?y:Int;
}
