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
	 * Frees all of the buttons so they can be recycled
	 */
	public static function freeAll()
	{
		cache.killMembers();
	}

	/**
	 * Makes (or recycles) a Button.
	 */
	public static function make(X:Int, Y:Int, Width:Int, Height:Int, BorderSize:Int, RimSize:Int, Label:String, ?Color:Int = FlxColor.GRAY,
			?LabelColor:Int = FlxColor.WHITE, ?OutlineColor:Int = FlxColor.BLACK):Button
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
		scrollFactor.set();

		outline = new FlxSprite().makeGraphic(1, 1);
		outline.scrollFactor.set();

		rim = new FlxSprite().makeGraphic(1, 1);
		rim.scrollFactor.set();

		border = new FlxSprite().makeGraphic(1, 1);
		border.scrollFactor.set();

		face = new FlxSprite().makeGraphic(1, 1);
		face.scrollFactor.set();

		label = new FlxText();
		label.scrollFactor.set();

		add(outline);
		add(rim);
		add(border);
		add(face);
		add(label);
	}

	function setup(X:Int, Y:Int, Width:Int, Height:Int, BorderSize:Int, RimSize:Int, Label:String, Color:Int, LabelColor:Int, OutlineColor:Int)
	{
		outline.setPosition(-BorderSize, -BorderSize);
		outline.setGraphicSize(Width + (BorderSize * 2), Height + (BorderSize * 2));
		outline.updateHitbox();
		outline.color = OutlineColor;

		rim.setPosition(0, 0);
		rim.setGraphicSize(Width, Height);
		rim.updateHitbox();
		rim.color = FlxColor.fromInt(Color).getDarkened(0.3);

		border.setPosition(0, -RimSize);
		border.setGraphicSize(Width, Height);
		border.updateHitbox();
		border.color = FlxColor.fromInt(Color).getLightened(0.1);

		face.setPosition(BorderSize, BorderSize - RimSize);
		face.setGraphicSize(Width - (BorderSize * 2), Height - (BorderSize * 2));
		face.updateHitbox();
		face.color = Color;

		label.setPosition(BorderSize * 2, -RimSize + (BorderSize * 2));
		label.fieldWidth = Width - BorderSize - 4;
		var fntSize = Std.int(Math.min((Width - BorderSize * 4) / (Label.length * 0.8), (Height - 4 - BorderSize * 4) * 0.75));
		// label.y += BorderSize * 2 + ((Height - BorderSize * 4) * 0.5) - Std.int(Math.min((((Width - BorderSize * 4) / (Label.length * 0.8) + 4) / 3) * 4, (Height - BorderSize * 4)) * 0.5);
		label.setFormat(Paths.font("Monocraft.ttf"), fntSize, LabelColor, CENTER);
		label.text = Label;

		setPosition(X, Y);
	}
}
