package editors;

class AdventureEditor extends Menu
{
	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Controls.BACK)
		{
			Menu.switchTo(ModEditor);
		}
	}
}
