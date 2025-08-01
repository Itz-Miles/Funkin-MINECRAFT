package;

typedef SwagSection =
{
	var notes:Array<Dynamic>;
	var beats:Float;
	var characterGroup:Int;
	var mustHitSection:Bool;
	var gfSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

class Section
{
	public var notes:Array<Dynamic> = [];

	public var beats:Float = 4;
	public var gfSection:Bool = false;
	public var characterGroup:Int = 0;
	public var mustHitSection:Bool = true;

	/**
	 *	Copies the first section into the second section!
	 */
	public static var COPYCAT:Int = 0;

	public function new(beats:Float = 4)
	{
		this.beats = beats;
		trace('test created section: ' + beats);
	}
}
