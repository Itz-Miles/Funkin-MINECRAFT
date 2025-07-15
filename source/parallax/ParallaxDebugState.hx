package parallax;

import flixel_5_3_1.ParallaxSprite;
import flixel.text.FlxText;
import flixel.FlxG;

class ParallaxDebugState extends MusicBeatState
{
	var amount:Int;

	override function create()
	{
		var bg:ParallaxBG = new ParallaxBG('arch');
		add(bg);

		var fg:ParallaxFG = new ParallaxFG('arch');
		fg.setPosition(-130, -70);
		add(fg);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.pressed.SHIFT)
			amount = 500;
		else
			amount = 100;
		if (controls.UI_UP)
			FlxG.camera.scroll.y -= amount * elapsed;

		if (controls.UI_DOWN)
			FlxG.camera.scroll.y += amount * elapsed;

		if (controls.UI_LEFT)
			FlxG.camera.scroll.x -= amount * elapsed;

		if (controls.UI_RIGHT)
			FlxG.camera.scroll.x += amount * elapsed;

		if (FlxG.keys.pressed.Z)
			FlxG.camera.zoom -= amount * 0.01 * elapsed;

		if (FlxG.keys.pressed.X)
			FlxG.camera.zoom += amount * 0.01 * elapsed;

		if (FlxG.mouse.pressed)
		{
			FlxG.camera.scroll.x -= FlxG.mouse.deltaScreenX * FlxG.camera.zoom;
			FlxG.camera.scroll.y -= FlxG.mouse.deltaScreenY * FlxG.camera.zoom;
		}

		if (FlxG.mouse.wheel != 0)
		{
			FlxG.camera.zoom += FlxG.mouse.wheel * amount * 0.1 * elapsed;
		}

		if (controls.BACK)
			FlxG.switchState(() -> new MainMenuState());
	}
}
