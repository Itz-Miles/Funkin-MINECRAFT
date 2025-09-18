package blockUI;

class Button extends FlxSpriteContainer
{
	private static var cache:FlxTypedGroup<Button>;

	private var outline:FlxSprite;

	private var rim:FlxSprite;

	private var border:FlxSprite;

	private var face:FlxSprite;

	private var label:FlxText;

	/**
	 * Makes (or recycles) a Button.
	 */
	public static function make(X:Int, Y:Int, Width:Int, Height:Int, BorderSize:Int, RimSize:Int, Label:String, Color:Int, LabelColor:Int):Button
	{
		var button:Button = cache.recycle(Button, Button.new);

		return button;
	}

	public function new()
	{
		super();

		init();
	}

	function init()
	{
		outline = new FlxSprite().makeGraphic(1, 1);
		rim = new FlxSprite().makeGraphic(1, 1);
		border = new FlxSprite().makeGraphic(1, 1);
		face = new FlxSprite().makeGraphic(1, 1);
		label = new FlxText();

		add(outline);
		add(rim);
		add(border);
		add(face);
		add(label);
	}

	function setup(X:Int, Y:Int, Width:Int, Height:Int, BorderSize:Int, RimSize:Int, Label:String, Color:Int, LabelColor:Int)
	{
		x = X;
		y = Y;

		outline.setPosition(X - BorderSize, Y - BorderSize);
		outline.setGraphicSize(Width + BorderSize * 2, Height + BorderSize * 2);
	}
}
