package states;

import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

class IntroState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	var credGroup:FlxGroup;
	var textGroup:FlxGroup;
	var logoSpr:FlxSprite;
	var introGF:Character;
	var pressedEnter:Bool = false;
	var gamepad:FlxGamepad;
	var paused:Bool = true;

	override public function create():Void
	{
		FlxAssets.FONT_DEFAULT = "assets/fonts/Monocraft.ttf";
		FlxG.game.focusLostFramerate = 60;
		FlxG.fixedTimestep = !ClientPrefs.data.variableTimestep;
		FlxG.camera.fade(#if !html5 0xFF0F0F0F #else 0xFF000000 #end, 1, true);
		// FlxTween.tween(FlxG.camera.bgColor, {alphaFloat: 1}, 3);
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];
		FlxObject.defaultMoves = false;
		gamepad = FlxG.gamepads.lastActive;

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		super.create();

		Level.reloadList();
		Story.reloadList();

		if (ClientPrefs.data.totems > 37)
			ClientPrefs.data.totems = 37; // ok?

		Highscore.load();

		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(Paths.music('where_are_we_going'), 0);

			FlxG.sound.music.fadeIn(4, 0, 1);
		}

		Conductor.bpm = 100;

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		introGF = new Character(550, 195, 'outlineGF', "shared");
		add(introGF);

		logoSpr = new FlxSprite(0, 720 * 0.4).loadGraphic(Paths.image('logos/sike engine', "shared"));
		logoSpr.visible = false;
		logoSpr.setGraphicSize(Std.int(1280 * 0.5));
		logoSpr.updateHitbox();
		logoSpr.antialiasing = ClientPrefs.data.antialiasing;
		logoSpr.screenCenter(X);
		logoSpr.x -= 250;
		logoSpr.y -= 150;
		add(logoSpr);

		createCoolText([' Built on '], -30);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.sound.music != null)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if (!pressedEnter)
		{
			if (FlxG.mouse.justPressed || Controls.ACCEPT)
				pressedEnter = true;

			#if mobile
			for (touch in FlxG.touches.list)
			{
				if (touch.justPressed)
				{
					pressedEnter = true;
				}
			}
			#end

			if (gamepad != null)
			{
				if (gamepad.justPressed.START)
					pressedEnter = true;

				#if switch
				if (gamepad.justPressed.B)
					pressedEnter = true;
				#end
			}

			if (pressedEnter && !ClientPrefs.data.firstIntro)
				endIntro();
		}
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0, ?size:Int = 48, ?scale:Float = 1.0)
	{
		for (i in 0...textArray.length)
		{
			var money:FlxText = new FlxText(0, 0, 0, textArray[i], size);
			money.setFormat(Paths.font("Monocraft.ttf"), size,
				FlxColor.fromRGBFloat(FlxG.camera.bgColor.redFloat * FlxG.camera.bgColor.alphaFloat,
					FlxG.camera.bgColor.greenFloat * FlxG.camera.bgColor.alphaFloat, FlxG.camera.bgColor.blueFloat * FlxG.camera.bgColor.alphaFloat),
				CENTER, OUTLINE, 0xffffffff);
			money.borderSize = size / 12;
			money.screenCenter(X);
			money.scale.y = scale;
			money.x -= 250;
			money.y += (i * 60) + 100 + offset;
			if (credGroup != null && textGroup != null)
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0, ?size:Int = 48)
	{
		if (textGroup != null && credGroup != null)
		{
			var coolText:FlxText = new FlxText(0, 0, 0, text, size);
			coolText.setFormat(Paths.font("Monocraft.ttf"), size,
				FlxColor.fromRGBFloat(FlxG.camera.bgColor.redFloat * FlxG.camera.bgColor.alphaFloat,
					FlxG.camera.bgColor.greenFloat * FlxG.camera.bgColor.alphaFloat, FlxG.camera.bgColor.blueFloat * FlxG.camera.bgColor.alphaFloat),
				CENTER, OUTLINE, 0xffffffff);
			coolText.borderSize = size / 12;
			coolText.screenCenter(X);
			coolText.x -= 250;
			coolText.y += (textGroup.length * 60) + 100 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	var sickBeats:Int = 0;

	public static var closedState:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		if (introGF != null)
		{
			introGF.dance();
		}

		if (!closedState)
		{
			FlxG.camera.zoom = 1.02;
			FlxTween.tween(FlxG.camera, {zoom: 1}, (60 / Conductor.bpm) * 0.5, {ease: FlxEase.quadInOut});
			sickBeats++;
			switch (sickBeats)
			{
				case 2:
					logoSpr.visible = true;
				case 6:
					logoSpr.visible = false;
					deleteCoolText();
				case 7:
					createCoolText([' Based on '], -30);
					logoSpr.loadGraphic(Paths.image('logos/logo_fnf', "shared"));
					logoSpr.setGraphicSize(Std.int(1280 / 3));
					logoSpr.updateHitbox();
					logoSpr.screenCenter(X);
					logoSpr.x -= 250;
					logoSpr.y += 50;
				case 8:
					logoSpr.visible = true;
				case 13:
					deleteCoolText();
					logoSpr.visible = false;
				case 15:
					createCoolText([" It'z Miles "], -15);
				case 16:
					addMoreText(' Presents:', 15);
				case 18:
					deleteCoolText();
					createCoolText([" Funkin'"], -15, 148, 1.3);
				case 19:
					addMoreText(' MINECRAFT ', 110, 112);
				case 21:
					endIntro();
			}
		}
	}

	function endIntro()
	{
		closedState = true;
		FlxTween.cancelTweensOf(FlxG.camera);
		FlxTween.tween(FlxG.camera, {zoom: 10}, 1, {ease: FlxEase.quadIn}); // torn between this & beat 22/0.5 duration
		FlxG.camera.fade(0xff82aafa, 1, false, function()
		{
			GameWorld.SKY_COLOR = 0xff82aafa;
			ClientPrefs.data.firstIntro = false;
			FlxG.save.data.firstIntro = false;
			FlxG.switchState(() -> new GameWorld());
		}, true);
	}
}
