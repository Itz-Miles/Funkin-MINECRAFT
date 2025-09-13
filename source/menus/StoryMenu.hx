package menus;

class StoryMenu extends Menu
{
	var header:Panel;

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
}
