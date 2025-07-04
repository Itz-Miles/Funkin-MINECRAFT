package;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.sound.FlxSound;
import WeekData;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	static var curSelected:Int = 0;

	var curDifficulty:Int = -1;

	static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreText:FlxText;
	var diffText:FlxText;
	var resetText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var grpSongs:FlxTypedGroup<Alphabet>;

	var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		Paths.clearUnusedMemory();

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Freeplay", null);
		#end

		for (i in 0...WeekData.weeksList.length)
		{
			if (weekIsLocked(WeekData.weeksList[i]))
				continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if (colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(400, 280, songs[i].songName, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			songText.changeX = false;
			songText.screenCenter(X);
			songText.x -= 80;
			songText.distancePerItem.set(0, 200);
			grpSongs.add(songText);

			if (songText.width > 980)
			{
				var textScale:Float = 980 / songText.width;
				songText.scale.x = textScale;
			}

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter, false, "shared");
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}
		WeekData.setDirectoryFromWeek();

		var scoreBG:FlxSprite = new FlxSprite(0, 720).makeGraphic(1, 1, 0xFF000000);
		scoreBG.scale.set(1280, 140);
		scoreBG.origin.set(0, 0);
		scoreBG.alpha = 0.6;
		add(scoreBG);
		FlxTween.tween(scoreBG, {y: 580}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.6});

		scoreText = new FlxText(0, 720, 1220, "", 48);
		scoreText.screenCenter(X);
		scoreText.setFormat(Paths.font("Monocraft.ttf"), 48, FlxColor.WHITE, CENTER);
		FlxTween.tween(scoreText, {y: 600}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.6});

		resetText = new FlxText(0, 720, 0, 'Press RESET to reset your score.', 24);
		resetText.setFormat(Paths.font("Monocraft.ttf"), 24, FlxColor.WHITE, CENTER);
		resetText.screenCenter(X);
		resetText.x -= resetText.width * 0.32;
		add(resetText);
		FlxTween.tween(resetText, {y: 600 + scoreText.height}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.6});

		diffText = new FlxText(resetText.x + resetText.width, 720, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);
		FlxTween.tween(diffText, {y: 600 + scoreText.height}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.6});

		add(scoreText);

		var directoryBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.WHITE);
		directoryBar.scrollFactor.set(0, 0);
		directoryBar.origin.set(0, 0);
		directoryBar.scale.x = 1280;
		directoryBar.scale.y = 0;
		add(directoryBar);
		FlxTween.tween(directoryBar, {"scale.y": 60}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.4});

		var directoryTitle:FlxText = new FlxText(0, -32, 0, "ignore the objective", 36);
		directoryTitle.scrollFactor.set(0, 0);
		directoryTitle.setFormat(Paths.font('Minecrafter.ttf'), 36, 0xFF000000);
		directoryTitle.updateHitbox();
		directoryTitle.screenCenter(X);
		add(directoryTitle);
		FlxTween.tween(directoryTitle, {y: 12}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.4});
		FlxG.camera.flash(FlxG.camera.bgColor, 0.4);

		if (curSelected >= songs.length)
			curSelected = 0;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		this.camera.fade(FlxG.camera.bgColor, 0.25, true);
		changeSelection();
		changeDiff();

		super.create();
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool
	{
		return false;
	}

	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT || FlxG.keys.justPressed.SEVEN;

		if (!accepted)
			if (FlxG.sound.music.volume < 0.7)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if (ratingSplit.length < 2)
		{ // No decimals, add an empty space
			ratingSplit.push('');
		}

		while (ratingSplit[1].length < 2)
		{ // Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';

		var shiftMult:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftMult = 3;

		if (songs.length > 1)
		{
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if (controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changeDiff();
				}
			}
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (upP || downP)
			changeDiff();

		if (controls.BACK)
		{
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'), 0.3);
			this.camera.fade(FlxG.camera.bgColor, 0.35, false, function()
			{
				FlxG.switchState(new MainMenuState());
			}, true);
		}

		if (accepted)
		{
			FlxG.camera.fade(FlxG.camera.bgColor, 0.25, false);
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var song:String = Highscore.formatSong(songLowercase, curDifficulty);
			trace(song);

			PlayState.SONG = Song.loadFromJson(song, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());

			if (FlxG.keys.justPressed.SEVEN)
			{
				new FlxTimer().start(0.25, function(tmr:FlxTimer)
				{
					LoadingState.loadAndSwitchState(new ChartingState());
				});
			}
			else
			{
				new FlxTimer().start(0.25, function(tmr:FlxTimer)
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			}

			FlxG.sound.music.volume = 0;
		}
		else if (controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.3);
		}
		super.update(elapsed);
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length - 1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		lastDifficultyName = Difficulty.getString(curDifficulty);
		_updateSongLastDifficulty();

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		diffText.text = 'Difficulty: <${Difficulty.getString(curDifficulty).toUpperCase()}>';
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.3);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var iterator:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = iterator - curSelected;
			iterator++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		PlayState.storyWeek = songs[curSelected].week;

		Difficulty.resetList();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if (diffStr != null)
			diffStr = diffStr.trim();

		if (diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if (diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if (diffs[i].length < 1)
						diffs.remove(diffs[i]);
				}
				--i;
			}

			if (diffs.length > 0 && diffs[0].length > 0)
				Difficulty.list = diffs;
		}

		if (songs[curSelected].lastDifficulty != null && Difficulty.list.contains(songs[curSelected].lastDifficulty))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(songs[curSelected].lastDifficulty)));
		else if (Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
		// trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if (newPos > -1)
		{
			curDifficulty = newPos;
		}
		_updateSongLastDifficulty();

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end
	}

	inline function _updateSongLastDifficulty()
	{
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = '';
		if (this.folder == null)
			this.folder = '';
	}
}
