package menus;

class AdventureMenu extends Menu
{
	override public function create()
	{
		super.create();
		header = new Panel(LayerData.HEADER);
		header.text = "select your adventure";
		add(header);
	}

	override public function refresh()
	{
		if (Menu.previous is MainMenu)
			header.runAcrossLayers(2);
		else
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

		if (Controls.ACCEPT)
		{
			Menu.switchTo(CharacterMenu);
		}
	}
}
