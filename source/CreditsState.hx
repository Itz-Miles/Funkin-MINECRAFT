package;

import flixel.tweens.FlxEase;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;

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

	var directoryBar:FlxSprite;
	var directoryTitle:FlxText;

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
			[" Compositions and Sound Effects"],

			[
				'Above',
				'disk_where_are_we_going',
				"descriptive text is gonna be here, \nand it's gonna be so cool",
				"https://youtu.be/BAfwkjhuv6U"
			],
			[
				'Stalstruck',
				'disk_stalstruck',
				"descriptive text is gonna be here, \nand it's gonna be so cool",
				"https://youtube.com",
			],
			[
				'song 2',
				'miles',
				"descriptive text is gonna be here, \nand it's gonna be so cool",
				"https://youtube.com",
			],
			[
				'song 3',
				'miles',
				"descriptive text is gonna be here, \nand it's gonna be so cool",
				"https://youtube.com",
			],
			[
				'song 4',
				'miles',
				"descriptive text is gonna be here, \nand it's gonna be so cool",
				"https://youtube.com",
			],
			[
				'song 5',
				'miles',
				"descriptive text is gonna be here, \nand it's gonna be so cool",
				"https://youtube.com",
			],
			[
				'song 6',
				'miles',
				"descriptive text is gonna be here, \nand it's gonna be so cool",
				"https://youtube.com",
			],
			[" Build Dependencies "],
			[
				'ParallaxLT',
				'flixel',
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
			[''],
			[" Creative Production Tools "],
			['Mineimator', 'mineimator', "", 'https://google.com'],
			['Blender', 'blender', "", 'https://google.com'],
			['Reaper', 'reaper', "", 'https://google.com'],
			['GIMP', 'gimp', "", 'https://google.com'],
			['VsCode', 'vscode', "", 'https://google.com'],
			['PNGGauntlet', 'gauntlet', "", 'https://google.com'],
			['Shotcut', 'shotcut', "", 'https://google.com'],
			[""],
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
				"Programmer of Friday Night Funkin'",
				'https://twitter.com/ninja_muffin99'
			],
			[
				'PhantomArcade',
				'phantomarcade',
				"Animator of Friday Night Funkin'",
				'https://twitter.com/PhantomArcade3K'
			],
			[
				'evilsk8r',
				'evilsk8r',
				"Artist of Friday Night Funkin'",
				'https://twitter.com/evilsk8r'
			],
			[
				'kawaisprite',
				'kawaisprite',
				"Composer of Friday Night Funkin'",
				'https://twitter.com/kawaisprite'
			],
			[
				'Github',
				'github',
				"Contributions",
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
			var optionText:Alphabet = new Alphabet(0, 280, creditsStuff[i][0], !isSelectable);
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

		descBox = new FlxSprite(0, 720).makeGraphic(1, 1, 0xFF000000);
		descBox.scale.set(1280, 140);
		descBox.origin.set(0, 0);
		descBox.alpha = 0.6;
		add(descBox);
		FlxTween.tween(descBox, {y: 580}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.6});

		descText = new FlxText(50, 720, 1180, "", 32);
		descText.setFormat(Paths.font("Monocraft.ttf"), 32, FlxColor.WHITE, CENTER);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);
		FlxTween.tween(descText, {y: 600}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.6});

		directoryBar = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.WHITE);
		directoryBar.scrollFactor.set(0, 0);
		directoryBar.origin.set(0, 0);
		directoryBar.scale.x = 1280;
		directoryBar.scale.y = 0;
		add(directoryBar);
		FlxTween.tween(directoryBar, {"scale.y": 60}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.4});

		directoryTitle = new FlxText(0, -32, 0, "credit the creators", 36);
		directoryTitle.scrollFactor.set(0, 0);
		directoryTitle.setFormat(Paths.font('Minecrafter.ttf'), 36, 0xFF000000);
		directoryTitle.updateHitbox();
		directoryTitle.screenCenter(X);
		add(directoryTitle);
		FlxTween.tween(directoryTitle, {y: 12}, 1.1, {ease: FlxEase.quintOut, startDelay: 0.4});
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
