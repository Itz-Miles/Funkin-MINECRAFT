package editors;

/**
 * The Mod Editor serves as a hub for adding and creating mods.
 */
class ModEditor extends MusicBeatState
{
	override function create()
	{
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}
	}
}
