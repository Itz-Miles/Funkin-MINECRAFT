package menus;

class SettingsMenu extends Menu
{
	var button:Button;

	override public function create()
	{
		super.create();
		header = new Panel(LayerData.HEADER);
		header.text = "choose your preferences";
		add(header);
	}

	override public function refresh()
	{
		button = Button.make(100, 200, 200, 100, 5, 10, "woah", null, 0xFF000000);
		tryAdd(button);

		header.runAcrossLayers(0);
		super.refresh();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (Controls.BACK)
		{
			Menu.switchTo(MainMenu);
		}
	}
}
