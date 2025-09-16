package menus;

class StoryMenu extends Menu
{
	override public function create()
	{
		super.create();
		header = new Panel(LayerData.HEADER);
		header.text = "understand the stories";
		add(header);
	}

	override public function refresh()
	{
		header.runAcrossLayers(0);
		super.refresh();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (Controls.BACK)
		{
			GameWorld.switchMenu(Menu.MAIN);
		}
	}
}
