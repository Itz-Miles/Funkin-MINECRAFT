package objects;

import flixel.FlxSprite;

using StringTools;

typedef EventNote =
{
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

enum NoteType
{
	NOTE;
	SUS;
	END;
	EVENT;
}

enum NoteStatus
{
	TOO_LATE;
	TOO_EARLY;
	WAS_HIT;
	CAN_BE_HIT;
}

class Note extends FlxSprite
{
	public var type(default, set):NoteType = NOTE;

	function set_type(value:NoteType):NoteType
	{
		scale.x = 0.7;
		switch (value)
		{
			case EVENT:
				loadGraphic(Paths.image('chart editor/eventArrow', "shared"));
				setGraphicSize(ChartEditor.GRID_SIZE, ChartEditor.GRID_SIZE);
			case NOTE:
				scale.y = 0.7;
				loadGraphic(Paths.image('notes/${_laneKeys[lane % 4]}', "shared"));
			case END:
				alpha = 0.6;
				multAlpha = 0.6;
				if (ClientPrefs.data.downScroll)
					flipY = true;

				loadGraphic(Paths.image('notes/${_laneKeys[lane % 4]} end', "shared"));

				if (prevNote != null && prevNote.type == END)
					prevNote.type = SUS;

			case SUS:
				loadGraphic(Paths.image('notes/${_laneKeys[lane % 4]} sus', "shared"));
				scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if (PlayState.instance != null)
				{
					scale.y *= PlayState.instance.songSpeed;
				}
		}
		updateHitbox();

		return type = value;
	}

	public var status(default, set):NoteStatus = TOO_EARLY;

	function set_status(value:NoteStatus):NoteStatus
	{
		if (status != value)
		{
			switch (value)
			{
				case TOO_EARLY:
				case TOO_LATE:
					alpha = 0.3;
				case CAN_BE_HIT:
				case WAS_HIT:
			}
		}
		return status = value;
	}

	public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var lane:Int = 0;
	public var prevNote:Note;
	public var nextNote:Note;

	public var sustainLength:Float = 0;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var animSuffix:String = '';
	public var gfNote:Bool = false;

	public static var swagWidth:Float = 110;

	var _laneKeys:Array<String> = ['left', 'down', 'up', 'right'];

	public var multAlpha:Float = 1;
	public var multSpeed(default, set):Float = 1;

	function set_multSpeed(value:Float):Float
	{
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		return value;
	}

	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.25;
	public var missHealth:Float = 0.475;

	public var noAnimation:Bool = false;
	public var distance:Float = 2000;

	public function resizeByRatio(ratio:Float)
	{
		if (type == SUS)
		{
			scale.y *= ratio;
			updateHitbox();
		}
	}

	public function new(strumTime:Float, lane:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?debug:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;

		if (prevNote != null)
			prevNote.nextNote = this;

		x += PlayState.STRUM_X + 50;
		y -= 2000;
		this.strumTime = strumTime + (!debug ? ClientPrefs.data.noteOffset : 0);

		this.lane = lane;

		if (sustainNote)
			type = END;
		else if (lane > -1)
		{
			type = NOTE;
			x += swagWidth * (lane);
		}
		else if (debug)
			type = EVENT;

		antialiasing = ClientPrefs.data.antialiasing;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (strumTime > Conductor.songPosition - (Conductor.hitWindow) && strumTime < Conductor.songPosition + (Conductor.hitWindow))
				status = CAN_BE_HIT;
			else
				status = TOO_EARLY;

			if (strumTime < Conductor.songPosition - Conductor.hitWindow && status != WAS_HIT)
				status = TOO_LATE;
		}
		else
		{
			if (strumTime < Conductor.songPosition + (Conductor.hitWindow))
			{
				if ((type != NOTE && prevNote.status == WAS_HIT) || strumTime <= Conductor.songPosition)
					status = WAS_HIT;
			}
		}
	}
}
