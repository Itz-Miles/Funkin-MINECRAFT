package editors;

class LevelEditor extends MusicBeatState
{
	/**
	 * A list of currently loaded levels (from Level.levelsList).
	 */
	public var loadedLevels:Array<String>;

	/**
	 * The currently selected MetaLevelObject.
	 */
	public static var selectedObject:MetaLevelObject;

	/**
	 * A list of MetaLevelObjects in the level editor.
	 */
	public var metaLevelObjects:Array<MetaLevelObject>;

	/**
	 * The size of a block in pixels.
	 */
	public static inline var BLOCK_SIZE:Int = 128;

	/**
	 * The size of a chunk in blocks.
	 */
	public static inline var CHUNK_SIZE:Int = 10;

	public function new()
	{
		super();
		loadedLevels = [];
		Level.reloadList();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		// loop through MetaLevelObjects update functions
		for (metaObj in metaLevelObjects)
		{
			metaObj.update(elapsed);
		}
	}
}


class MetaLevelObject
{
	/**
	 * The backing sprite for this MetaLevelObject.
	 * Used for clicking, dragging, rotating, scaling, e.t.c
	 */
	public var backing:FlxSprite;

	public function update(elapsed:Float)
	{
		// handle clicking, dragging, rotating, scaling, e.t.c
		// check if mouse is over backing
		if (FlxG.mouse.overlaps(backing))
		{
			if (FlxG.mouse.justPressed)
			{
				LevelEditor.selectedObject = this;
			}
			if (FlxG.mouse.pressed)
			{
				backing.x += FlxG.mouse.deltaViewX;
				backing.y += FlxG.mouse.deltaViewY;
			}
		}
	}
}
