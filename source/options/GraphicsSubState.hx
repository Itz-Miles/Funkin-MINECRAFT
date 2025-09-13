package options;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import options.Option;

class GraphicsSubState extends BaseOptionsMenu
{
	var boyfriend:Character = null;

	public function new()
	{
		title = 'compromize the graphics';
		rpcTitle = 'Graphics'; // for Discord Rich Presence

		boyfriend = new Character(840, 170, 'outlineBF');
		boyfriend.visible = false;

		var option:Option = new Option('Anti-Aliasing', 'Smoothens sprites to negate the effect of aliasing.', 'antialiasing', 'bool');
		option.onChange = onChangeAntiAliasing;
		addOption(option);
		/*
			var option:Option = new Option('ParallaxLT', 'Transforms sprites to mimic 3D graphics.', 'parallaxLT', 'bool');
			addOption(option);
		 */

		var option:Option = new Option('Post-Processing', "Blends and shades sprites for visual effects.", 'shaders', 'bool');
		addOption(option);

		var option:Option = new Option('Ambient Particles:', 'The percentage of ambient particles in the enviroment.', 'particlePercentage', 'percent');
		addOption(option);
		option.scrollSpeed = 0.5;
		option.minValue = 0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;

		#if !html5
		var option:Option = new Option('Framerate:', "The game's draw & update frequencies.", 'framerate', 'int');
		addOption(option);

		final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
		option.minValue = 24;
		option.maxValue = 1000;
		option.defaultValue = Std.int(FlxMath.bound(refreshRate, option.minValue, option.maxValue));
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		var option:Option = new Option('Variable Timestep', "The game loop's update fruequency is variable.", 'variableTimestep', 'bool');
		option.onChange = onChangeTimestep;
		addOption(option);

		#if !mobile
		var option:Option = new Option('Performance Display', "Displays the game's performance metrics.", 'showFPS', 'bool');
		addOption(option);
		option.onChange = onChangeFPSCounter;
		/*
			var option:Option = new Option('Build Information', "Displays the game's build information.", 'showBuildInfo', 'bool');
			addOption(option);
			option.onChange = onChangebuildInfo;
		 */

		var option:Option = new Option('Fullscreen', "The game's window envelops the entire screen.", 'fullscreen', 'bool');
		addOption(option);
		option.onChange = onChangeFullscreen;
		#end

		var option:Option = new Option('Use JsDelivr CDN', "Uses jsDelivr to load base game web assets.\nUses raw.githubusercontent.com otherwise.",
			'jsDelivrCDN', 'bool');
		addOption(option);

		super();
		insert(1, boyfriend);
	}

	override public function beatHit():Void
	{
		boyfriend.dance(true);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:FlxSprite = cast sprite;
			if (sprite != null && (sprite is FlxSprite) && !(sprite is FlxText))
			{
				sprite.antialiasing = ClientPrefs.data.antialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if (ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
	}

	function onChangeTimestep()
	{
		FlxG.fixedTimestep = !ClientPrefs.data.variableTimestep;
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if (Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
	}

	function onChangebuildInfo()
	{
		if (Main.buildInfo != null)
			Main.buildInfo.visible = ClientPrefs.data.showBuildInfo;
	}
	#end

	function onChangeFullscreen()
		FlxG.fullscreen = ClientPrefs.data.fullscreen;

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		boyfriend.visible = (curSelected == 0);
	}
}
