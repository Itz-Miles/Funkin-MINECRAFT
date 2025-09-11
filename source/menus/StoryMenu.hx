package menus;

class StoryMenu extends Menu
{
	var header:Panel;

	override public function create()
	{
		super.create();
		header = new Panel(LayerData.HEADER);
		header.text = "understand the stories";
		header.runAcrossLayers(0);
		add(header);
	}

	override public function refresh()
	{
		super.refresh();
	}
}
