package options;
import options.Option;

import flixel.FlxG;

class GameplaySubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'determine your gameplay';
		rpcTitle = 'Gameplay';

		var option:Option = new Option('Auto Pause', "The game is supended when its window isn't focused.", 'autoPause', 'bool');
		addOption(option);
		option.onChange = onChangeAutoPause;

		var option:Option = new Option('Downscroll', // Name
			'Notes scroll downwards from the top of the screen.', // Description
			'downScroll', // Save data variable name
			'bool'); // Variable type
		addOption(option);

		var option:Option = new Option('HUD Opacity:', "The HUD's transparency.", 'hudAlpha', 'percent');
		option.scrollSpeed = 0.5;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.01;
		option.decimals = 2;
		addOption(option);

		var option:Option = new Option('Hud Bar:', "The HUD stat to display.", 'timeBarType', 'string', ['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Hit Window:', 'The window you have in milliseconds for htting a note.', 'hitWindow', 'float');
		option.displayFormat = '%vms';
		option.scrollSpeed = 50;
		option.minValue = 16.6;
		option.maxValue = 166.7;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Hit Sound:', 'Plays a tick sound at the specified volume for hitting a note.', 'hitsoundVolume', 'percent');
		addOption(option);
		option.scrollSpeed = 0.5;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;
		
		#if !html5
		var option:Option = new Option('Check for Updates', 'On Release builds, turn this on to check for updates when you start the game.',
			'checkForUpdates', 'bool');
		addOption(option);
		#end

		super();
	}

	function onChangeHitsoundVolume()
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);

	function onChangeAutoPause()
		FlxG.autoPause = ClientPrefs.data.autoPause;
}
