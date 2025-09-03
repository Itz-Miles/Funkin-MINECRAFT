package editors;

/**
 * The Mod Editor serves as a hub for adding and creating mods.
 */
class ModEditor extends MusicBeatState
{
	override function create()
	{
		super.create();

		var header:Panel = new Panel(LayerData.HEADER);
		header.text = "modify game content";
		header.runAcrossLayers(0);
		add(header);
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
