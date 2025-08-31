package objects;

import flixel.text.FlxText;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;

class FlxGroupText extends FlxSpriteGroup
{
	/**
	 * The text to display, can include newline characters (\n) to create multiple lines.
	 */
	public var text(default, set):String;

	/**
	 * The row width in pixels.
	 * When a line exceeds this width, it will automatically wrap to the next line.
	 * If set to 0, no wrapping will occur.
	 */
	public var rowWidth:Int = 0;

	/**
	 * The horizontal spacing between letters in pixels. 
	 */
	public var letterSpacing:Int = 0;

	/**
	 * The vertical spacing between lines in pixels.
	 */
	public var lineSpacing:Int = 0;

	/**
	 * Whether to use bold letters.
	 */
	public var bold:Bool = false;

	/**
	 * The display size of the letters.
	 */
	public static var fontSize(default, set):Int = 16;

	static function set_fontSize(value:Int)
	{
		return fontSize = value;
	}

	function set_text(value:String)
	{
		return text = value;
	}
}

/**
 * Utility class for managing letter graphics in FlxGroupText.
 */
class Letter
{
	// "singleton" FlxText instance responsible for generating letter graphics
	public static var flxText(get, default):FlxText;

	static function get_flxText():FlxText
	{
		if (flxText == null)
		{
			flxText = new FlxText(0, 0, 0, "", 16);
			flxText.setFormat("assets/fonts/vcr.ttf", 16, 0xFFFFFFFF, "center", 0xFF000000);
		}
		return flxText;
	}

	// "singleton" FlxText instance responsible for generating bold letter graphics
	public static var flxTextBold(get, default):FlxText;

	static function get_flxTextBold():FlxText
	{
		if (flxTextBold == null)
		{
			flxTextBold = new FlxText(0, 0, 0, "", 16);
			flxTextBold.setFormat("assets/fonts/vcr.ttf", 16, 0xFFFF0000, "center", 0xFF000000); // for now
		}
		return flxTextBold;
	}

	/**
	 * Map of "bold" letters to their corresponding FlxGraphics
	 */
	public static var boldLetters:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

	/**
	 * Map of "regular" letters to their corresponding FlxGraphics
	 */
	public static var regularLetters:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

	/**
	 * Returns the FlxGraphic for a given chracter.
	 * Generatesd if it doesn't exist.
	 * @param char 
	 * @param bold 
	 */
	public static function getSprite(char:String, bold:Bool = false)
	{
		if (bold)
		{
			if (boldLetters.exists(char))
			{
				return boldLetters.get(char);
			}
			else
			{
				return generateLetter(char, true);
			}
		}
		else
		{
			if (regularLetters.exists(char))
			{
				return regularLetters.get(char);
			}
			else
			{
				return generateLetter(char, false);
			}
		}
	}

	/**
	 * Generates the FlxGraphic for a given character and stores it in the appropriate map.
	 * @param char 
	 * @param bold 
	 */
	public static function generateLetter(char:String, bold:Bool = false)
	{
		if (bold)
		{
			flxTextBold.text = char;
			boldLetters.set(char, flxTextBold.graphic);
			return boldLetters.get(char);
		}
		else
		{
			flxText.text = char;
			regularLetters.set(char, flxText.graphic);
			return regularLetters.get(char);
		}
	}
}
