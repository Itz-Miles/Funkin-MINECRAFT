package menus;

class MainMenu extends Menu
{
	override public function create()
	{
		header = new Panel(LayerData.HEADER);
		header.text = "select a submenu";
		add(header);
	}

	override public function refresh()
	{
		header.runAcrossLayers(0);
	}
}
