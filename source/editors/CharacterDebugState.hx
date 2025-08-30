package editors;

import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.FlxCamera;
import parallax.ParallaxFG;
import flixel.FlxG;
import parallax.ParallaxBG;

class CharacterDebugState extends MusicBeatState
{
	var char:Character;
	var statusText:FlxText;
	var camUI:FlxCamera;

	static var charToLoad:String = "bf_arch";

	override function create()
	{
		camUI = new FlxCamera();
		camUI.bgColor.alpha = 0;
		FlxG.cameras.add(camUI, false);
		var bg:ParallaxBG = new ParallaxBG('aero_archways');
		add(bg);

		char = new Character(0, 0, charToLoad);
		add(char);

		var fg:ParallaxFG = new ParallaxFG('aero_archways');
		fg.setPosition(-130, -70);
		add(fg);

		statusText = new FlxText(16, 688, 0, "status", 16);
		add(statusText);
		statusText.cameras = [camUI];

		Conductor.bpm = 100;
		FlxG.sound.playMusic(Paths.music('where_are_we_going'));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.sound.music != null)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if (controls.ATTACK)
			char.attack();

		if (FlxG.mouse.pressedRight)
		{
			FlxG.camera.scroll.x -= FlxG.mouse.deltaViewX * FlxG.camera.zoom;
			FlxG.camera.scroll.y -= FlxG.mouse.deltaViewY * FlxG.camera.zoom;
		}

		if (FlxG.mouse.wheel != 0)
		{
			FlxG.camera.zoom += FlxG.mouse.wheel * 10 * elapsed;
		}

		if (controls.BACK)
			FlxG.switchState(() -> new MainMenuState());

		statusText.text = "status: " + char.status.getName();
	}

	override function beatHit()
	{
		super.beatHit();
		char.dance(true);
	}
}
