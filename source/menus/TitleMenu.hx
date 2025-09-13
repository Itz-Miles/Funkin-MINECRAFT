package menus;

class TitleMenu extends Menu
{
	var logo:FlxSprite;

	var splashText:FlxText;

	override public function create()
	{
		logo = new FlxSprite(-15, -10).loadGraphic(Paths.image('logos/logo', "shared"));
		logo.antialiasing = ClientPrefs.data.antialiasing;
		add(logo);

		splashText = new FlxText(0, 560, 0, '', 1);
		splashText.bold = true;
		splashText.setFormat(Paths.font("Monocraft.ttf"), 72, 0xFFffda2a, CENTER, SHADOW_XY(0, 6), 0xff725728);
		splashText.text = 'click ANYWHERE to start!';
		splashText.antialiasing = ClientPrefs.data.antialiasing;
		splashText.screenCenter(X);
		add(splashText);
	}

	override public function refresh()
	{
		if (MainMenuState.curSelection != 5)
		{
			logo.alpha = 0;
			FlxTween.tween(logo, {alpha: 1}, 0.5, {ease: FlxEase.cubeIn});
			splashText.alpha = 0;
			FlxTween.tween(splashText, {alpha: 1}, 0.5, {ease: FlxEase.cubeIn});
			@:bypassAccessor MainMenuState.curSelection = 5;
		}
		else
		{
			FlxG.camera.flash(FlxG.camera.bgColor, 0.7);
			FlxG.camera.zoom = 3.5;
			FlxG.camera.scroll.y = 400;
			FlxTween.tween(FlxG.camera, {zoom: 1.0, "scroll.y": 0}, 1.8, {ease: FlxEase.quintOut});
		}
	}

	override public function beatHit(?curBeat:Int)
	{
		super.beatHit(curBeat);
	}
}
