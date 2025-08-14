package editors;

import flixel.FlxG;

class TestChartingState extends MusicBeatState
{
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			FlxG.switchState(() -> new FreeplayState());
		}
	}
}
