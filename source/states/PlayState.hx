package states;

import objects.Note.EventNote;
import parallax.ParallaxFG;
#if desktop
import Discord.DiscordClient;
#end
import Song.SongData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import openfl.utils.Assets as OpenFlAssets;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import ToolTip;
import parallax.ParallaxBG;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 50;

	var STRUM_Y = (ClientPrefs.data.downScroll ? 560 : 50);

	var songSpeedTween:FlxTween;
	var camSpeedTween:FlxTween;

	public var songSpeed(default, set):Float = 1;
	public var playerGroup:Array<Character>;
	public var opponentGroup:Array<Character>;
	public var neutralGroup:Array<Character>;

	static var stage:String = '';

	var bg:ParallaxBG;
	var fg:ParallaxFG;

	public static var SONG:SongData = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	// static var paused:Bool = false;
	public var vocals:FlxSound;

	var notes:FlxTypedGroup<Note>;
	var unspawnNotes:Array<Note> = [];
	var eventNotes:Array<EventNote> = [];

	public var totalRatings:Array<Dynamic> = ['?/10', '?'];

	public static var camZoomTarget:Float = 1;

	public var camSpeed:Float = 1;

	public var camTarget:FlxPoint;

	var camLerpPos:FlxObject;
	var camForced:Bool = false;

	var opponentStrums:Array<StrumNote>;
	var playerStrums:Array<StrumNote>;

	var curSong:String = "";

	var prideBar:FlxBar;
	var nerveBar:FlxBar;
	var rageBar:FlxBar;

	var songPercent:Float = 0;

	var timeBarBG:AttachedSprite;

	var timeBar:FlxBar;

	var generatedMusic:Bool = false;

	var endingSong:Bool = false;

	public var startingSong:Bool = false;

	var updateTime:Bool = true;

	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	var iconP1:HealthIcon;

	public var songScore:Int = 0;
	public var songMisses:Int = 0;

	var scoreTxt:FlxText;

	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;
	var toolTip:ToolTip;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;

	var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;

	var songLength:Float = 0;

	#if desktop
	// Discord RPC variables
	public var detailsText:String = "";
	#end

	public static var instance:PlayState;

	// Less laggy controls
	var keysArray:Array<Dynamic>;
	var controlArray:Array<String>;
	var camUI:FlxCamera;

	override public function create()
	{
		/*
			Paths.clearStoredMemory();
			Paths.clearUnusedMemory();
		 */

		instance = this;

		camUI = new FlxCamera();
		camUI.bgColor.alpha = 0;
		FlxG.cameras.add(camUI, false);

		keysArray = [
			ClientPrefs.keyBinds.get('note_left').copy(),
			ClientPrefs.keyBinds.get('note_down').copy(),
			ClientPrefs.keyBinds.get('note_up').copy(),
			ClientPrefs.keyBinds.get('note_right').copy()
		];

		controlArray = ['NOTE_LEFT', 'NOTE_DOWN', 'NOTE_UP', 'NOTE_RIGHT'];

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;

		#if desktop
		if (isStoryMode)
		{
			detailsText = "Story Mode: ";
		}
		else
		{
			detailsText = "Freeplay";
		}
		#end

		camTarget = new FlxPoint();
		camLerpPos = new FlxObject(0, 0, 1, 1);
		add(camLerpPos);

		stage = PlayState.SONG.stage;
		bg = new ParallaxBG(stage);
		add(bg);
		camLerpPos.setPosition(camTarget.x, camTarget.y);
		FlxG.camera.follow(camLerpPos, LOCKON, 1);
		FlxG.camera.focusOn(camTarget);
		FlxG.camera.zoom = camZoomTarget;

		playerGroup = new Array<Character>();
		opponentGroup = new Array<Character>();
		neutralGroup = new Array<Character>();

		for (string in SONG.neutrals)
		{
			var neutral:Character = new Character(0, 0, string);
			neutralGroup.push(neutral);
			add(neutral);
		}

		for (string in SONG.players)
		{
			var player:Character = new Character(0, 0, string);
			playerGroup.push(player);
			add(player);
		}

		for (string in SONG.opponents)
		{
			var opponent:Character = new Character(0, 0, string);
			opponentGroup.push(opponent);
			add(opponent);
		}

		fg = new ParallaxFG(stage);
		add(fg);

		Conductor.songPosition = -5000;

		var showTime:Bool = (ClientPrefs.data.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (1280 * 0.5) - 248, 19, 400, "", 30);
		timeTxt.setFormat(Paths.font("Monocraft.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 3;
		timeTxt.visible = showTime;
		timeTxt.cameras = [camUI];
		if (!ClientPrefs.data.downScroll)
			timeTxt.y = 720 - 43;

		if (ClientPrefs.data.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.name;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('playstate/bar', null, "shared");
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height * 0.25);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		timeBarBG.cameras = [camUI];
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800;
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		timeBar.cameras = [camUI];
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		if (ClientPrefs.data.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		opponentStrums = new Array<StrumNote>();
		playerStrums = new Array<StrumNote>();

		generateSong(SONG.name);

		eventPushedMap.clear();
		eventPushedMap = null;
		moveCameraSection(0);
		prideBar = new FlxBar(790, 620, RIGHT_TO_LEFT, 308, 20, playerGroup[0], 'health', 0, 20, true); // change this later
		prideBar.createFilledBar(FlxColor.fromRGB(0, 0, 0), FlxColor.fromRGB(0, 0, 255), true, FlxColor.BLACK);
		prideBar.updateBar();
		prideBar.scrollFactor.set();
		prideBar.cameras = [camUI];
		if (ClientPrefs.data.downScroll)
			prideBar.y = 0.13 * 720;
		add(prideBar);

		nerveBar = new FlxBar(790, prideBar.y - 25, RIGHT_TO_LEFT, 308, 20, playerGroup[0], 'health', 0, 20, true); // change this later
		nerveBar.createFilledBar(FlxColor.fromRGB(0, 0, 0), FlxColor.fromRGB(255, 255, 0), true, FlxColor.BLACK);
		nerveBar.updateBar();
		nerveBar.scrollFactor.set();
		nerveBar.cameras = [camUI];
		add(nerveBar);

		rageBar = new FlxBar(790, nerveBar.y - 25, RIGHT_TO_LEFT, 308, 20, playerGroup[0], 'health', 0, 20, true); // change this later
		rageBar.createFilledBar(FlxColor.fromRGB(0, 0, 0), FlxColor.fromRGB(255, 0, 0), true, FlxColor.BLACK);
		rageBar.updateBar();
		rageBar.scrollFactor.set();
		rageBar.cameras = [camUI];
		add(rageBar);

		iconP1 = new HealthIcon(playerGroup[0].healthIcon, true, "shared");
		iconP1.sprTracker = prideBar;
		iconP1.trackerOffset.set(-20, -iconP1.height * 0.5);
		iconP1.cameras = [camUI];
		add(iconP1);

		toolTip = new ToolTip(0, 0, null, ClientPrefs.data.downScroll, 3);
		toolTip.scrollFactor.set();
		toolTip.cameras = [camUI];
		toolTip.visible = false;

		scoreTxt = new FlxText(Note.swagWidth + 600, prideBar.y + 24, 0, "", 20);
		scoreTxt.setFormat(Paths.font("Monocraft.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 2.5;
		scoreTxt.cameras = [camUI];
		add(scoreTxt);

		startingSong = true;

		if (isStoryMode && !seenCutscene)
		{
			switch (Paths.formatToSongPath(curSong))
			{
				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}

		if (!Controls.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.hitWindow = ClientPrefs.data.hitWindow * 0.5;
		updateRating(null, false);
		Paths.clearUnusedMemory();

		super.create();
	}

	function set_songSpeed(value:Float):Float
	{
		if (generatedMusic)
		{
			var ratio:Float = value / songSpeed; // funny word huh
			for (note in notes)
				note.resizeByRatio(ratio);
			for (note in unspawnNotes)
				note.resizeByRatio(ratio);
		}
		songSpeed = value;
		return value;
	}

	public var noteJudges:Int;
	public var noteRatings:Float;

	public function updateRating(note:Note = null, bounce:Bool)
	{
		vocals.volume = 1;
		var noteDelta:Float;
		var noteRating:Array<Dynamic>;
		var score:Int = 400;
		if (note != null)
		{
			noteDelta = Math.abs(note.strumTime - Conductor.songPosition);
			noteRating = Conductor.judge(noteDelta);
			toolTip.visible = true;
			toolTip.targetSpr = playerStrums[note.lane];
			toolTip.text = noteRating[0];

			score = noteRating[4];
			noteRatings += noteRating[1];
			noteJudges++;
			songScore += score;
		}
		totalRatings = Conductor.getAverageRating();
		scoreTxt.text = 'Score:${songScore}|Misses:${songMisses}|Rating:${totalRatings[0]}${(totalRatings[0] != '?/10' ? '(${Highscore.floorDecimal(totalRatings[1] * 100, 2)}%)' : '')}';
		scoreTxt.x = prideBar.x + (prideBar.width * 0.5) - (scoreTxt.width * 0.5) + 56;

		if (bounce)
		{
			if (scoreTxtTween != null)
			{
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2,
				{
					onComplete: function(twn:FlxTween)
					{
						scoreTxtTween = null;
					}
				});
		}
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = unspawnNotes[i];
			if (daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = notes.members[i];
			if (daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function setSongTime(time:Float)
	{
		if (time < 0)
			time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
		}
		vocals.play();
		Conductor.songPosition = time;
	}

	public var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	function generateSong(dataPath:String):Void
	{
		songSpeed = SONG.speed;
		var songData = SONG;
		Conductor.bpm = songData.bpm;

		curSong = songData.name;

		if (SONG.needsVoices)
		{
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.name));
		}
		else
		{
			vocals = new FlxSound();
		}

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.name)));

		notes = new FlxTypedGroup<Note>();
		notes.cameras = [camUI];

		unspawnNotes = ChartParser.parseSongChart(SONG);
		unspawnNotes.sort(sortNotesByStrumTime);

		/**
		 * unfortunately due to how psych events currently work, we can't just move them to another class and except them to work as intended.
		 * they stay here for the time being until a way for them to be there without breaking is found
		 */

		var songName:String = Paths.formatToSongPath(SONG.name);

		var file:String = Paths.json(songName + '/events');

		if (OpenFlAssets.exists(file))
		{
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData)
			{ // Event Notes
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote =
						{strumTime: newEventNote[0] + ClientPrefs.data.noteOffset,
							event: newEventNote[1],
							value1: newEventNote[2],
							value2: newEventNote[3]
						};
					// subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (event in songData.events)
		{ // Event Notes
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote =
					{strumTime: newEventNote[0] + ClientPrefs.data.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
				// subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		if (eventNotes.length > 1)
		{ // No need to sort if there's a single one or none at all
			eventNotes.sort(sortEventNotesByStrumTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote)
	{
		switch (event.event)
		{
		}

		if (!eventPushedMap.exists(event.event))
		{
			eventPushedMap.set(event.event, true);
		}
	}

	var finishTimer:FlxTimer = null;

	public static var startOnTime:Float = 0;

	public function startCountdown():Void
	{
		if (startedCountdown)
		{
			return;
		}

		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);
		add(notes);
		add(toolTip);

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		if (startOnTime < 0)
			startOnTime = 0;

		if (startOnTime > 0)
		{
			clearNotesBefore(startOnTime);
			setSongTime(startOnTime - 350);
			return;
		}
		else
		{
			setSongTime(0);
			return;
		}
	}

	function startSong():Void
	{
		startingSong = false;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.name), 1, false);
		FlxG.sound.music.onComplete = onSongComplete;
		vocals.play();

		if (startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		songLength = FlxG.sound.music.length;
	}

	function sortNotesByStrumTime(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	// what
	function sortEventNotesByStrumTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function generateStaticArrows(player:Int):Void
	{
		var targetAlpha:Float = 1;

		for (i in 0...4)
		{
			var babyArrow:StrumNote = new StrumNote(STRUM_X, STRUM_Y, i, player);
			babyArrow.y -= 150;
			babyArrow.alpha = 0;
			babyArrow.scale.set(2, 2);
			babyArrow.cameras = [camUI];
			if (player == 1)
			{
				FlxTween.tween(babyArrow.scale, {x: Note.swagWidth / babyArrow.frameWidth, y: Note.swagWidth / babyArrow.frameWidth}, 1, {ease: FlxEase.sineOut, startDelay: 0.6 + (0.1 * i)});

				FlxTween.tween(babyArrow, {y: babyArrow.y + 150, alpha: targetAlpha}, 1, {ease: FlxEase.bounceOut, startDelay: 0.6 + (0.1 * i)});
				playerStrums.push(babyArrow);
				add(babyArrow);
			}
			else
			{
				FlxTween.tween(babyArrow.scale, {x: Note.swagWidth / babyArrow.frameWidth, y: Note.swagWidth / babyArrow.frameWidth}, 1, {ease: FlxEase.sineOut, startDelay: 0.9 - (0.1 * i)});
				FlxTween.tween(babyArrow, {y: babyArrow.y + 150, alpha: targetAlpha}, 1, {ease: FlxEase.bounceOut, startDelay: 0.9 - (0.1 * i)});

				opponentStrums.push(babyArrow);
				add(babyArrow);
			}
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}
		if (finishTimer != null && !finishTimer.finished)
			finishTimer.active = false;
		if (songSpeedTween != null)
			songSpeedTween.active = false;
		if (camSpeedTween != null)
			camSpeedTween.active = false;

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (FlxG.sound.music != null && !startingSong)
		{
			resyncVocals();
		}
		if (finishTimer != null && !finishTimer.finished)
			finishTimer.active = true;
		if (songSpeedTween != null)
			songSpeedTween.active = true;
		if (camSpeedTween != null)
			camSpeedTween.active = true;

		#if desktop
		DiscordClient.changePresence(detailsText, SONG.name, opponentGroup[0].character);
		#end

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (FlxG.sound.music != null && FlxG.state.subState == null && ClientPrefs.data.autoPause)
		{
			FlxG.sound.music.pause();
			vocals.pause();
			// openSubState(new PauseSubState());
		}
		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (finishTimer != null)
			return;
		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
		}
		vocals.play();
	}

	var startedCountdown:Bool = false;

	override public function update(elapsed:Float)
	{
		if (!inCutscene)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * camSpeed, 0, 1);
			camLerpPos.setPosition(FlxMath.lerp(camLerpPos.x, camTarget.x, lerpVal), FlxMath.lerp(camLerpPos.y, camTarget.y, lerpVal));
		}

		super.update(elapsed);

		if (playerGroup[0].status == DEAD)
		{
			camTarget.set(playerGroup[0].getMidpoint().x + playerGroup[0].cameraOffsets[0], playerGroup[0].getMidpoint().y + playerGroup[0].cameraOffsets[1]);
		}
		/*
			if (SONG.sections[curSection] != null && SONG.sections[curSection].mustHitSection)
			{
				camTarget.x += FlxG.mouse.deltaViewX;
				camTarget.y += FlxG.mouse.deltaViewY;
			}
		 */

		if (Controls.PAUSE && startedCountdown && !endingSong)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				// openSubState(new PauseSubState());
			}
		}

		if (!endingSong && !inCutscene && !isStoryMode)
		{
			if (FlxG.keys.justPressed.SEVEN)
				openSongEditor();
		}

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		if (playerGroup[0].health > 20)
			playerGroup[0].health = 20;

		if (prideBar.percent < 20)
		{
			iconP1.animation.curAnim.curFrame = 1;
		}
		else
		{
			iconP1.animation.curAnim.curFrame = 0;
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (updateTime)
			{ // move to beathit
				var curTime:Float = Conductor.songPosition - ClientPrefs.data.noteOffset;
				if (curTime < 0)
					curTime = 0;
				songPercent = (curTime / songLength);

				var songCalc:Float = (songLength - curTime);
				if (ClientPrefs.data.timeBarType == 'Time Elapsed')
					songCalc = curTime;

				var secondsTotal:Int = Math.floor(songCalc * 0.001);
				if (secondsTotal < 0)
					secondsTotal = 0;

				if (ClientPrefs.data.timeBarType != 'Song Name')
					timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
			}
		}

		FlxG.camera.zoom = FlxMath.lerp(camZoomTarget, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 2.4 * camSpeed), 0, 1));

		if (unspawnNotes[0] != null)
		{
			var time:Float = 2000;
			if (songSpeed < 1)
				time /= songSpeed;
			if (unspawnNotes[0].multSpeed < 1)
				time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:Array<StrumNote> = playerStrums;
				if (!daNote.mustPress)
					strumGroup = opponentStrums;

				var strumX:Float = strumGroup[daNote.lane].x;
				var strumY:Float = strumGroup[daNote.lane].y;
				var strumAlpha:Float = strumGroup[daNote.lane].alpha;

				strumAlpha *= daNote.multAlpha;

				if (ClientPrefs.data.downScroll)
				{ // Downscroll{
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
				}
				else
				{ // Upscroll
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
				}

				if (daNote.copyAlpha)
					daNote.alpha = strumAlpha;

				daNote.x = strumX + Note.swagWidth * 0.5 - daNote.width * 0.5; // doesnt need to be onupdate atm

				daNote.y = strumY + daNote.distance;

				if (ClientPrefs.data.downScroll && daNote.type != NOTE)
				{
					if (daNote.type == END)
					{
						daNote.y += 10.5 * (fakeCrochet * 0.2500) * 1.5 * songSpeed + (46 * (songSpeed - 1));
						daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
						daNote.y -= 19;
					}
					daNote.y += (Note.swagWidth * 0.5) - (60.5 * (songSpeed - 1));
					daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
				}

				if (!daNote.mustPress && daNote.status == WAS_HIT)
				{
					opponentNoteHit(daNote, opponentGroup[0]);
				}

				var center:Float = strumY + Note.swagWidth * 0.5;
				if (daNote.type != NOTE
					&& (!daNote.mustPress
						|| (daNote.status == WAS_HIT || (daNote.prevNote.status == WAS_HIT && daNote.status != CAN_BE_HIT))))
				{
					if (ClientPrefs.data.downScroll)
					{
						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// Kill extremely late notes and cause misses
				if (Conductor.songPosition > Conductor.hitWindow + daNote.strumTime)
				{
					if (daNote.mustPress && !endingSong)
					{
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();

		if (!inCutscene)
		{
			keys();
		}
	}

	function openSongEditor()
	{
		cancelMusicFadeTween();
		chartingMode = true;
		camUI.fade(FlxG.camera.bgColor, 0.25, false, function()
		{
			// FlxG.switchState(() -> new SongEditor());
		});
	}

	public function checkEventNote()
	{
		while (eventNotes.length > 0)
		{
			var leStrumTime:Float = eventNotes[0].strumTime;
			if (Conductor.songPosition < leStrumTime)
			{
				break;
			}

			var value1:String = '';
			if (eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if (eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String)
	{
		switch (eventName)
		{
			case 'Add Camera Zoom':
				if (FlxG.camera.zoom < 1.35 * camZoomTarget)
				{
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if (Math.isNaN(camZoom))
						camZoom = 0.015;
					if (Math.isNaN(hudZoom))
						hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 0;
				if (Math.isNaN(val2))
					val2 = 0;

				camForced = false;
				if (!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2)))
				{
					camTarget.x = val1;
					camTarget.y = val2;
					camForced = true;
				}

			case 'Set Player':
				var playerIndex:Null<Int> = Std.parseInt(value1);
				if (playerIndex != null && playerGroup[playerIndex] != null)
				{
					playerGroup[playerIndex].character = value2;
				}
				else
				{
					var char:Character = new Character(0, 0, value2);
					insertChar(char);
					playerGroup.push(char);
				}

			case 'Set Opponent':
				var opponentIndex:Null<Int> = Std.parseInt(value1);
				if (opponentIndex != null && playerGroup[opponentIndex] != null)
				{
					opponentGroup[opponentIndex].character = value2;
				}
				else
				{
					var char:Character = new Character(0, 0, value2);
					insertChar(char);
					opponentGroup.push(char);
				}
			case 'Set Neutral':
				var neutralIndex:Null<Int> = Std.parseInt(value1);
				if (neutralIndex != null && neutralGroup[neutralIndex] != null)
				{
					neutralGroup[neutralIndex].character = value2;
				}
				else
				{
					var char:Character = new Character(0, 0, value2);
					insertChar(char);
					neutralGroup.push(char);
				}

			case 'Camera Speed Tween':
				var args:Array<String> = value1.split(", ");
				var initialSpeed:Float = camSpeed;
				camSpeed = Std.parseFloat(args[0]);
				camSpeedTween = FlxTween.tween(this, {camSpeed: initialSpeed}, Std.parseFloat(args[1]),
					{
						ease: CoolUtil.easeFromString(value2),
						onComplete: function(twn:FlxTween)
						{
							camSpeedTween = null;
						}
					});

			case 'Camera Speed Set':
				camSpeed = Std.parseFloat(value1);

			case 'Screen Shake':
				var duration:Float = 0;
				var intensity:Float = 0;

				duration = Std.parseFloat(value1.trim());

				intensity = Std.parseFloat(value2.trim());
				if (Math.isNaN(duration))
					duration = 0;
				if (Math.isNaN(intensity))
					intensity = 0;

				if (duration > 0 && intensity != 0)
				{
					FlxG.camera.shake(intensity, duration);
				}

			case 'Change Scroll Speed':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 1;
				if (Math.isNaN(val2))
					val2 = 0;

				var newValue:Float = SONG.speed * val1;

				if (val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2,
						{
							ease: FlxEase.linear,
							onComplete: function(twn:FlxTween)
							{
								songSpeedTween = null;
							}
						});
				}
		}
	}

	function insertChar(char:Character):Void
	{
		insert(members.indexOf(fg), char);
	}

	function moveCameraSection(?id:Int = 0):Void
	{
		if (playerGroup[0].status == DEAD || SONG.sections[curSection] == null)
			return;

		if (neutralGroup[0] != null && SONG.sections[curSection].gfSection)
		{
			camTarget.set(neutralGroup[0].getMidpoint().x + neutralGroup[0].cameraOffsets[0], neutralGroup[0].getMidpoint().y + neutralGroup[0].cameraOffsets[1]);
			camZoomTarget = neutralGroup[0].zoom;
			return;
		}

		if (!SONG.sections[curSection].mustHitSection)
			moveCamera(true);
		else
			moveCamera(false);
	}

	public function moveCamera(isDad:Bool)
	{
		if (isDad)
		{
			camTarget.set(opponentGroup[0].getMidpoint().x + opponentGroup[0].cameraOffsets[0], opponentGroup[0].getMidpoint().y + opponentGroup[0].cameraOffsets[1]);
			camZoomTarget = opponentGroup[0].zoom;
		}
		else
		{
			camTarget.set(playerGroup[0].getMidpoint().x + playerGroup[0].cameraOffsets[0], playerGroup[0].getMidpoint().y + playerGroup[0].cameraOffsets[1]);
			camZoomTarget = playerGroup[0].zoom;
		}
	}

	function snapcamTargetToPos(x:Float, y:Float)
	{
		camTarget.set(x, y);
		camLerpPos.setPosition(x, y);
	}

	function onSongComplete()
	{
		finishSong(false);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; // In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if (ClientPrefs.data.noteOffset <= 0 || ignoreNoteOffset)
		{
			finishCallback();
		}
		else
		{
			finishTimer = new FlxTimer().start(ClientPrefs.data.noteOffset * 0.001, function(tmr:FlxTimer)
			{
				finishCallback();
			});
		}
	}

	public var transitioning = false;

	public function endSong():Void
	{
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		endingSong = true;
		inCutscene = false;
		updateTime = false;

		seenCutscene = false;

		if (!transitioning)
		{
			#if !switch
			var percent:Float = totalRatings[1];
			if (Math.isNaN(percent))
				percent = 0;
			Highscore.saveScore(SONG.name, songScore, storyDifficulty, percent);
			#end

			if (chartingMode)
			{
				openSongEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('where_are_we_going'));

					cancelMusicFadeTween();
					// FlxG.switchState(() -> new CreditsState());

					Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);

					FlxG.save.flush();

					changedDifficulty = false;
				}
				else
				{
					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]));

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0], PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					cancelMusicFadeTween();
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				cancelMusicFadeTween();
				// FlxG.switchState(() -> new FreeplayState());
				FlxG.sound.playMusic(Paths.music('where_are_we_going'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	public function killNotes()
	{
		while (notes.length > 0)
		{
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	function onKeyPress(event:KeyboardEvent):Void
	{
		if (subState == null)
		{
			var eventKey:FlxKey = event.keyCode;
			var key:Int = getKeyFromEvent(eventKey);

			if (startedCountdown && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || Controls.controllerMode))
			{
				if (/*!playerGroup[0].stunned &&*/ generatedMusic && !endingSong)
				{
					var lastTime:Float = Conductor.songPosition;
					Conductor.songPosition = FlxG.sound.music.time;

					var canMiss:Bool = false;

					var pressNotes:Array<Note> = [];
					var notesStopped:Bool = false;

					var sortedNotesList:Array<Note> = [];
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.status == CAN_BE_HIT && daNote.mustPress && daNote.type != SUS)
						{
							if (daNote.lane == key)
							{
								sortedNotesList.push(daNote);
							}
							canMiss = true;
						}
					});
					sortedNotesList.sort(sortHitNotes);

					if (sortedNotesList.length > 0)
					{
						for (epicNote in sortedNotesList)
						{
							for (doubleNote in pressNotes)
							{
								if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1)
								{
									doubleNote.kill();
									notes.remove(doubleNote, true);
									doubleNote.destroy();
								}
								else
								{
									notesStopped = true;
								}
							}

							if (!notesStopped)
							{
								playerNoteHit(epicNote, playerGroup[0]);
								pressNotes.push(epicNote);
							}
						}
					}
					Conductor.songPosition = lastTime;
				}

				playerStrums[key].pressed = true;
			}
		}
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	function onKeyRelease(event:KeyboardEvent):Void
	{
		if (subState == null)
		{
			var eventKey:FlxKey = event.keyCode;
			var key:Int = getKeyFromEvent(eventKey);
			if (startedCountdown && key > -1)
			{
				playerStrums[key].pressed = false;
			}
		}
	}

	function getKeyFromEvent(key:FlxKey):Int
	{
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	function keys():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (Controls.controllerMode)
		{
			var parsedArray:Array<Bool> = parseKeys('_P');
			if (parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if (parsedArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		if (startedCountdown && /*!playerGroup[0].stunned &&*/ generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.type != NOTE && parsedHoldArray[daNote.lane] && daNote.status == CAN_BE_HIT && daNote.mustPress)
				{
					playerNoteHit(daNote, playerGroup[0]);
				}
			});
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (Controls.controllerMode)
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if (parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if (parsedArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(Controls, controlArray[i] + suffix);
		}
		return ret;
	}

	function noteMiss(daNote:Note):Void
	{ // You didn't hit the key and let it go offscreen, also used by Hurt Notes

		playerGroup[0].health -= daNote.missHealth;
		if (playerGroup[0].health <= 0)
		{
			killNotes();
			camZoomTarget *= 1.5;
			FlxTween.tween(FlxG.sound.music, {pitch: 0}, 1.5,
				{
					ease: FlxEase.expoIn,
					onComplete: function(twn:FlxTween)
					{
						// openSubState(new PauseSubState());
					}
				});
		}

		songMisses++;
		vocals.volume = 0;
		songScore -= 200;
		updateRating(daNote, false);

		notes.forEachAlive(function(note:Note)
		{
			if (daNote != note
				&& daNote.mustPress
				&& daNote.lane == note.lane
				&& daNote.type == note.type
				&& Math.abs(daNote.strumTime - note.strumTime) < 1)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});

		if (neutralGroup[0].animOffsets.exists('sad'))
		{
			neutralGroup[0].playAnim('sad');
		}

		var char:Character = playerGroup[0];
		if (daNote.gfNote)
		{
			char = neutralGroup[0];
		}

		if (char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.lane))] + 'miss';
			char.playAnim(animToPlay, true);
		}
	}

	function opponentNoteHit(note:Note, opponent:Character):Void
	{
		var theAnimSuffix:String = note.animSuffix;
		var animToPlay:String;

		if (!note.noAnimation)
		{
			if (SONG.sections[curSection] != null)
			{
				if (SONG.sections[curSection].altAnim && !SONG.sections[curSection].gfSection)
				{
					theAnimSuffix = '-alt';
				}
			}

			animToPlay = singAnimations[Std.int(Math.abs(note.lane))] + theAnimSuffix;

			opponent.playAnim(animToPlay, true);
			// opponent.holdTimer = 0;
			if (!SONG.sections[curSection].mustHitSection && playerGroup[0].status != DEAD)
			{
				camTarget.set(opponent.getMidpoint().x, opponent.getMidpoint().y);
				camTarget.x += opponent.cameraOffsets[0];
				camTarget.y += opponent.cameraOffsets[1];
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if (note.type == SUS)
		{
			time += 0.15;
		}

		opponentStrums[note.lane].pressed = true;
		note.status == WAS_HIT;

		if (note.type == NOTE)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function playerNoteHit(note:Note, player:Character):Void
	{
		if (note.status != WAS_HIT)
		{
			if (ClientPrefs.data.hitsoundVolume > 0 && note.type == NOTE)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);
			}

			if (note.type == NOTE)
			{
				updateRating(note, true);
			}
			playerGroup[0].health += note.hitHealth;

			if (!note.noAnimation)
			{
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.lane))];

				player.playAnim(animToPlay + note.animSuffix, true);
				// player.holdTimer = 0;

				if (SONG.sections[curSection].mustHitSection && player.status != DEAD)
				{
					camTarget.set(player.getMidpoint().x, player.getMidpoint().y);
					camTarget.x += player.cameraOffsets[0];
					camTarget.y += player.cameraOffsets[1];
				}
			}

			note.status == WAS_HIT;
			vocals.volume = 1;

			if (note.type == NOTE)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	override function destroy()
	{
		if (!Controls.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		super.destroy();
	}

	public static function cancelMusicFadeTween()
	{
		if (FlxG.sound.music.fadeTween != null)
		{
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;

	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		if (curStep == lastStepHit)
		{
			return;
		}

		lastStepHit = curStep;
	}

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if (lastBeatHit >= curBeat)
		{
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.data.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

			if (PlayState.SONG.sections[Std.int(curStep / 16)] != null && !endingSong && !camForced && playerGroup[0].status != DEAD)
			{
				moveCameraSection(Std.int(curStep / 16));
				if (FlxG.camera.zoom < 1.35 * camZoomTarget && curBeat % 4 == 0)
				{
					FlxG.camera.zoom += 0.05;
				}
			}
		}

		iconP1.scale.set(1.2, 1.2);

		iconP1.updateHitbox();

		for (neutral in neutralGroup)
		{
			neutral.beatHit(curBeat);
		}

		for (opponent in opponentGroup)
		{
			opponent.beatHit(curBeat);
		}

		for (player in playerGroup)
		{
			player.beatHit(curBeat);
		}

		lastBeatHit = curBeat;
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.sections[curSection] != null)
		{
			if (generatedMusic && !endingSong && !camForced)
			{
				moveCameraSection();
			}

			if (FlxG.camera.zoom < 1.35 * camZoomTarget)
			{
				FlxG.camera.zoom += 0.05;
			}

			if (SONG.sections[curSection].changeBPM)
			{
				Conductor.bpm = SONG.sections[curSection].bpm;
			}
		}
	}
}
