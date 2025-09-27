package menus;

class CharacterMenu extends Menu
{
	var button:Button;

	override public function create()
	{
		super.create();
		header = new Panel(LayerData.HEADER);
		header.text = "select your character";
		add(header);

		button = Button.make(100, 200, 200, 100, 5, 10, "woah", null, 0xFF000000);
		add(button);
	}

	override public function refresh()
	{
		button = Button.make(100, 200, 200, 100, 5, 10, "woah", null, 0xFF000000);
		header.runAcrossLayers(0);
		super.refresh();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (Controls.BACK)
		{
			Menu.switchTo(AdventureMenu);
		}
		if (FlxG.keys.justPressed.B)
			trace('mouse position: ${FlxG.mouse.viewX}, ${FlxG.mouse.viewY}');
	}
}
