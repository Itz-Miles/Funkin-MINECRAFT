package;

import blockUI.LayerData;
import blockUI.Panel;
import flixel.tweens.FlxEase;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	var grpOptions:FlxTypedGroup<Alphabet>;
	var iconArray:Array<AttachedSprite> = [];
	var creditsStuff:Array<Array<String>> = [];

	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var descBox:FlxSprite;
	var header:Panel;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if desktop
		DiscordClient.changePresence("Credits", null);
		#end

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		var credits:Array<Array<String>> = [
			// Name - Icon name - Description - Link - BG Color

			[" Funkin' MINECRAFT "],

			[
				"It'z_Miles",
				'miles',
				"It'z_Miles is the director, composer, and developer of Funkin' MINECRAFT.",
				'https://twitter.com/Itz_MilesDev'
			],
			[
				"Idrees Hassan",
				"idrees",
				"Idrees Hassan is a veteran software dev who designed the Monocraft typeface & ligatures.",
				"https://idreesinc.com"
			],
			[" Music and Sound Effects"],

			[
				'Above',
				'disk_where_are_we_going',
				"Above was composed by It'z Miles",
				"https://youtu.be/BAfwkjhuv6U"
			],
			['Stalstruck', 'disk_stalstruck', "", "https://youtube.com",],

			[" Build Dependencies "],
			['BlockUI', 'haxeflixel', "", 'https://lib.haxe.org'],
			[
				'ParallaxLT',
				'haxeflixel',
				"ParallaxLT is a library that transforms sprites to mimic 3D graphics in Haxeflixel.",
				'https://lib.haxe.org/p/parallaxlt'
			],
			[
				'Haxeflixel',
				'haxeflixel',
				"Haxeflixel is a 2D game engine based on OpenFL that delivers cross-platform games.",
				'https://haxeflixel.com'
			],
			[
				'OpenFL',
				'openfl',
				"Open Flash Library is for creative expression on web, desktop, mobile, and consoles.",
				'https://www.openfl.org'
			],
			[
				'Lime',
				'lime',
				"Lime is a foundational Haxe framework for cross-platform software development.",
				'https://lime.openfl.org'
			],
			[
				'Haxe',
				'haxe',
				"Haxe is an open source toolkit for building tools and applications that target many mainstream platforms.",
				'https://haxe.org'
			],
			[" Production Tools "],
			['Mineimator', 'face', "", 'https://www.mineimator.com'],
			['Blender', 'face', "", 'https://www.blender.org'],
			['Reaper', 'face', "", 'https://www.reaper.fm'],
			['VsCode', 'face', "", 'https://code.visualstudio.com'],
			['PNGGauntlet', 'face', "", 'https://pnggauntlet.com'],
			[" Friday Night Funkin': Psych Engine "],
			[
				'Shadow Mario',
				'shadowmario',
				"Shadow Mario is the Main Programmer of Psych Engine.\n'WikiHow: How to handle fame'",
				'https://twitter.com/Shadow_Mario_'
			],
			[
				'SqirraRNG',
				'sqirra',
				"SqirraRNG is a game developer who designed the Crash Handler and Chart Editor's Waveform visualiser.",
				'https://twitter.com/sqirradotdev'
			],
			[
				'Github',
				'github',
				'dunno what to put here yet but there are contributors woah',
				'https://github.com/ShadowMario/FNF-PsychEngine/graphs/contributors'
			],

			[" The Friday Night Funkin' Crew "],
			[
				'ninjamuffin99',
				'ninjamuffin99',
				" Ninjamuffin is the main programmer of Friday Night Funkin'",
				'https://twitter.com/ninja_muffin99'
			],
			[
				'PhantomArcade',
				'phantomarcade',
				"Phantom Arcade is the main animator of Friday Night Funkin'",
				'https://twitter.com/PhantomArcade3K'
			],
			[
				'evilsk8r',
				'evilsk8r',
				"Evilsk9r is the main artist of Friday Night Funkin'",
				'https://twitter.com/evilsk8r'
			],
			[
				'kawaisprite',
				'kawaisprite',
				"Kawaisprite is the main composer of Friday Night Funkin'",
				'https://twitter.com/kawaisprite'
			],
			[
				'Github',
				'github',
				"Friday Night Funkin' has many contributions.",
				'https://github.com/FunkinCrew/Funkin/graphs/contributors'
			],
			[''],
			["..And how could I forget you?"],
			["The Player", 'face', "Thanks for playing Funkin' MINECRAFT!", '']

		];

		for (i in credits)
		{
			creditsStuff.push(i);
		}

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 320, creditsStuff[i][0], !isSelectable);
			optionText.distancePerItem.set(0, 150);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if (isSelectable)
				optionText.x -= 80;

			optionText.targetY = i;
			optionText.changeX = false;
			grpOptions.add(optionText);

			if (isSelectable)
			{
				var icon:AttachedSprite = new AttachedSprite('icons/' + creditsStuff[i][1], null, 'shared');
				icon.xAdd = optionText.width + 10;
				icon.setGraphicSize(150, 0);
				icon.updateHitbox();
				icon.yAdd = (optionText.height * 0.5) - (icon.height * 0.5);
				icon.sprTracker = optionText;
				iconArray.push(icon);
				add(icon);

				if (curSelected == -1)
					curSelected = i;
			}
		}

		descBox = new FlxSprite(50, 720).makeGraphic(1, 1, 0xFF000000);
		descBox.scale.set(1180, 140);
		descBox.origin.set(0, 0);
		descBox.alpha = 0.6;
		add(descBox);
		FlxTween.tween(descBox, {y: 530}, 1.1, {ease: FlxEase.elasticOut, startDelay: 0.6});

		descText = new FlxText(100, 720, 1080, "", 32);
		descText.setFormat(Paths.font("Monocraft.ttf"), 28, FlxColor.WHITE, CENTER);
		descText.scrollFactor.set();
		add(descText);
		FlxTween.tween(descText, {y: 550}, 1.1, {ease: FlxEase.elasticOut, startDelay: 0.6});

		header = new Panel(LayerData.HEADER);
		header.text = "credit the creators";
		header.runAcrossLayers();
		add(header);

		FlxG.camera.flash(FlxG.camera.bgColor, 0.4);

		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'), 0.3);
			header.runAcrossLayers(1);
			this.camera.fade(FlxG.camera.bgColor, 0.35, false, function()
			{
				if (colorTween != null)
				{
					colorTween.cancel();
				}

				FlxG.switchState(() -> new MainMenuState());
			}, true);
		}
		if (controls.ACCEPT)
		{
			CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.3);
		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		}
		while (unselectableCheck(curSelected));

		var iterator:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = iterator - curSelected;
			iterator++;

			if (!unselectableCheck(iterator - 1))
			{
				item.alpha = 0.6;
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
		}
		descText.text = creditsStuff[curSelected][2];
	}

	function unselectableCheck(num:Int):Bool
	{
		return creditsStuff[num].length <= 1;
	}
}
