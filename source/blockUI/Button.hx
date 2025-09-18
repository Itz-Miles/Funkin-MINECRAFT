package blockUI;

class Button extends FlxSpriteContainer
{
	private static var cache:FlxTypedGroup<Button> = new FlxTypedGroup<Button>();

	private var outline:FlxSprite;

	private var rim:FlxSprite;

	private var border:FlxSprite;

	private var face:FlxSprite;

	private var label:FlxText;

	/**
	 * Makes (or recycles) a Button.
	 */
	public static function make(X:Int, Y:Int, Width:Int, Height:Int, BorderSize:Int, RimSize:Int, Label:String, ?Color:Int = FlxColor.GRAY, ?LabelColor:Int = FlxColor.WHITE, ?OutlineColor:Int = FlxColor.BLACK):Button
	{
		var button:Button = cache.recycle(Button, Button.new);

		button.setup(X, Y, Width, Height, BorderSize, RimSize, Label, Color, LabelColor, OutlineColor);

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

	function setup(X:Int, Y:Int, Width:Int, Height:Int, BorderSize:Int, RimSize:Int, Label:String, Color:Int, LabelColor:Int, OutlineColor:Int)
	{
		// outline.setPosition(-BorderSize, -BorderSize);
		outline.setGraphicSize(Width + (BorderSize * 2), Height + (BorderSize * 2));
		outline.color = OutlineColor;

		rim.setGraphicSize(Width, Height);
		rim.color = FlxColor.fromInt(Color).getDarkened(0.3);

		// border.y -= RimSize;
		border.setGraphicSize(Width, Height);
		border.color = FlxColor.fromInt(Color).getLightened(0.1);

		// face.x += BorderSize;
		// face.y += BorderSize - RimSize;
		face.setGraphicSize(Width - (BorderSize * 2), Height - (BorderSize * 2));
		face.color = Color;

		// label.x += BorderSize * 4;
		var fntSize = Std.int(Math.min((Width - BorderSize * 4) / (Label.length * 0.8), (Height - 4 - BorderSize * 4) * 0.75));
		// label.y += BorderSize * 2 + ((Height - BorderSize * 4) * 0.5) - Std.int(Math.min((((Width - BorderSize * 4) / (Label.length * 0.8) + 4) / 3) * 4, (Height - BorderSize * 4)) * 0.5);
		label.setFormat(Paths.font("Monocraft.ttf"), fntSize, LabelColor, CENTER);
		label.text = Label;

		x = X;
		y = Y;
		scrollFactor.set();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (Controls.UI_LEFT)
			x -= 100 * elapsed;
		if (Controls.UI_RIGHT)
			x += 100 * elapsed;
		if (Controls.UI_UP)
			y -= 100 * elapsed;
		if (Controls.UI_DOWN)
			y += 100 * elapsed;
	}
}
