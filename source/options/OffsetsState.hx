package options;

import Discord;
import flixel.util.FlxStringUtil;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.math.FlxPoint;

using StringTools;

class OffsetsState extends MusicBeatState
{
	var boyfriend:Character;
	var gf:Character;
	var camHUD:FlxCamera;
	var barPercent:Float = 0;
	var delayMin:Int = -500;
	var delayMax:Int = 500;
	var timeBar:FlxBar;
	var timeText:FlxText;
	var beatText:FlxText;
	var beatTween:FlxTween;

	override public function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		// Cameras
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.add(camHUD, false);

		#if desktop
		DiscordClient.changePresence("Offsets", null);
		#end

		var directoryBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.WHITE);
		directoryBar.scrollFactor.set(0, 0);
		directoryBar.origin.set(0, 0);
		directoryBar.scale.x = 1280;
		directoryBar.scale.y = 60;
		add(directoryBar);

		var directoryTitle:FlxText = new FlxText(0, 12, 0, "delay the audio", 36);
		directoryTitle.scrollFactor.set(0, 0);
		directoryTitle.setFormat(Paths.font('Minecrafter.ttf'), 36, 0xFF000000);
		directoryTitle.updateHitbox();
		directoryTitle.screenCenter(X);
		add(directoryTitle);
		directoryTitle.cameras = directoryBar.cameras = [camHUD];

		// Characters
		gf = new Character(350, 0, 'outlineGF', "shared");
		gf.scrollFactor.set(0.8, 0.8);
		add(gf);

		boyfriend = new Character(850, 300, 'outlineBF', "shared");
		add(boyfriend);

		beatText = new FlxText(140, 0, 0, 'Beat Hit!', 32);
		beatText.setFormat(Paths.font("Monocraft.ttf"), 32, FlxG.camera.bgColor, CENTER, OUTLINE, 0xffffffff);
		beatText.borderSize = 2.7;
		beatText.alpha = 0;
		beatText.acceleration.y = 250;
		beatText.moves = true;
		add(beatText);

		timeText = new FlxText(160, 600, 381, "", 32);
		timeText.setFormat(Paths.font("Monocraft.ttf"), 32, FlxG.camera.bgColor, CENTER, OUTLINE, 0xffffffff);
		timeText.scrollFactor.set();
		timeText.borderSize = 2.7;
		timeText.cameras = [camHUD];

		barPercent = ClientPrefs.data.noteOffset;
		updateNoteDelay();

		timeBar = new FlxBar(200, timeText.y + 9, LEFT_TO_RIGHT, 299, Std.int(timeText.height - 16), this, 'barPercent', delayMin, delayMax);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0x00000000, 0xFFFFFFFF);
		timeBar.numDivisions = 500;
		timeBar.cameras = [camHUD];

		add(timeBar);
		add(timeText);

		super.create();
	}

	var holdTime:Float = 0;

	override public function update(elapsed:Float)
	{
		if (controls.UI_LEFT_P || controls.UI_DOWN_P)
		{
			barPercent = Math.max(delayMin, Math.min(ClientPrefs.data.noteOffset - 1, delayMax));
			updateNoteDelay();
		}
		else if (controls.UI_RIGHT_P || controls.UI_UP_P)
		{
			barPercent = Math.max(delayMin, Math.min(ClientPrefs.data.noteOffset + 1, delayMax));
			updateNoteDelay();
		}

		var mult:Int = 1;
		if (controls.UI_LEFT || controls.UI_RIGHT)
		{
			holdTime += elapsed;
			if (controls.UI_LEFT)
				mult = -1;
		}

		if (controls.UI_LEFT_R || controls.UI_RIGHT_R)
			holdTime = 0;

		if (holdTime > 0.5)
		{
			barPercent += 100 * elapsed * mult;
			barPercent = Math.max(delayMin, Math.min(barPercent, delayMax));
			updateNoteDelay();
		}

		if (controls.RESET)
		{
			holdTime = 0;
			barPercent = 0;
			updateNoteDelay();
		}

		if (controls.BACK)
		{
			if (zoomTween != null)
				zoomTween.cancel();
			if (beatTween != null)
				beatTween.cancel();

			persistentUpdate = false;
			FlxG.switchState(() -> new options.OptionsState());
		}

		Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);
	}

	var zoomTween:FlxTween;
	var lastBeatHit:Int = -1;

	override public function beatHit()
	{
		super.beatHit();

		if (lastBeatHit == curBeat)
		{
			return;
		}

		boyfriend.dance(true);
		gf.dance();

		if (curBeat % 2 == 1)
		{
			FlxG.camera.zoom = 1.15;

			if (zoomTween != null)
				zoomTween.cancel();
			zoomTween = FlxTween.tween(FlxG.camera, {zoom: 1}, 120 / Conductor.bpm, {
				ease: FlxEase.circOut,
				onComplete: function(twn:FlxTween)
				{
					zoomTween = null;
				}
			});

			beatText.alpha = 1;
			beatText.y = 320;
			beatText.velocity.y = -150;
			if (beatTween != null)
				beatTween.cancel();
			beatTween = FlxTween.tween(beatText, {alpha: 0}, 1, {
				ease: FlxEase.sineIn,
				onComplete: function(twn:FlxTween)
				{
					beatTween = null;
				}
			});
		}

		lastBeatHit = curBeat;
	}

	function updateNoteDelay()
	{
		ClientPrefs.data.noteOffset = Math.round(barPercent);
		timeText.text = '[Offset: ' + prefix(Std.int(barPercent)) + 'ms]';
	}

	inline function prefix(num:Int):String
	{
		var numString:String = Std.string(num);
		return (numString.length >= 4) ? numString : "    ".substr(0, 4 - numString.length) + numString;
	}
}
