package editors;

import objects.Character.CharacterFile;
import flixel.util.FlxTimer;
import flixel.addons.ui.FlxUIDropDownMenu;
#if desktop
import Discord.DiscordClient;
#end
import flash.geom.Rectangle;
import haxe.Json;
import haxe.io.Bytes;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUISlider;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import lime.media.AudioBuffer;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

@:access(flixel.sound.FlxSound._sound)
@:access(openfl.media.Sound.__buffer)
class ChartingState extends MusicBeatState
{
	public var ignoreWarnings = false;

	var undos = [];
	var redos = [];
	var eventStuff:Array<Dynamic> = [
		['', "Nothing. Yep, that's right."],
		['Character Action', "Value 1: Character to act. \n Value 2: action + arguments"],
		['muteMusic', 'Value 1:\nmute = off, amplify = on'],
		[
			'Set GF Speed',
			"Sets GF head bopping speed,\nValue 1: 1 = Normal speed,\n2 = 1/2 speed, 4 = 1/4 speed etc.\nUsed on Fresh during the beatbox parts.\n\nWarning: Value must be integer!"
		],
		[
			'Add Camera Zoom',
			"Adds camera zoom. \nValue 1: Camera zoom add (Default: 0.015)\nValue 2: UI zoom add (Default: 0.03)\nLeave the values blank if you want to use Default."
		],
		[
			'Camera Follow Pos',
			"Value 1: X\nValue 2: Y\n\nThe camera won't change the follow point\nafter using this, for getting it back\nto normal, leave both values blank."
		],
		[
			'Camera Speed Tween',
			"Tweens the cameraSpeed variable from a desired value.\nValue 1: the value and duration.\n Value 2: the tweening ease."
		],
		[
			'Screen Shake',
			"Value 1: Camera shake\nValue 2: HUD shake\n\nEvery value works as the following example: \"1, 0.05\".\nThe first number (1) is the duration.\nThe second number (0.05) is the intensity."
		],
		[
			'Set Player',
			"Sets/creates the specified member of the players group.\nValue 1: The member index\nValue 2: The character file to load"
		],
		[
			'Set Opponent',
			"Sets/creates the specified member of the opponents group.\nValue 1: The member index\nValue 2: The character file to load"
		],
		[
			'Set Neutral',
			"Sets/creates the specified member of the neutral group.\nValue 1: The member index\nValue 2: The character file to load"
		],
		[
			'Change Scroll Speed',
			"Value 1: Scroll Speed Multiplier (1 is default)\nValue 2: Time it takes to change fully in seconds."
		]
	];

	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	public static var goToPlayState:Bool = false;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	public static var curSec:Int = 0;

	public static var lastSection:Int = 0;
	private static var lastSong:String = '';

	var bpmTxt:FlxText;

	var camPos:FlxObject;
	var strumLine:FlxSprite;
	var quant:AttachedSprite;
	var strumLineNotes:FlxTypedGroup<StrumNote>;
	var curSong:String = 'Test';
	var amountSteps:Int = 0;
	var groupUI:FlxGroup;

	var highlight:FlxSprite;

	public static var GRID_SIZE:Int = 40;

	var CAM_OFFSET:Int = 360;

	var dummyArrow:FlxSprite;

	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedEventType:FlxTypedGroup<FlxText>;

	var nextRenderedSustains:FlxTypedGroup<FlxSprite>;
	var nextRenderedNotes:FlxTypedGroup<Note>;

	var gridBG:FlxSprite;
	var nextGridBG:FlxSprite;

	var daquantspot = 0;
	var curEventSelected:Int = 0;
	var curUndoIndex = 0;
	var curRedoIndex = 0;
	var _song:SwagSong;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic> = null;

	var playbackSpeed:Float = 1;

	var vocals:FlxSound = null;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var value1InputText:FlxUIInputText;
	var value2InputText:FlxUIInputText;
	var currentSongName:String;

	var zoomTxt:String = "Zoom: 1x";

	var zoomList:Array<Float> = [0.25, 0.5, 1, 2, 3, 4, 6, 8, 12, 16, 24];
	var curZoom:Int = 2;

	private var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	private var blockPressWhileTypingOnStepper:Array<FlxUINumericStepper> = [];
	private var blockPressWhileScrolling:Array<FlxUIDropDownMenu> = [];

	var waveformSprite:FlxSprite;
	var gridLayer:FlxTypedGroup<FlxSprite>;

	public static var quantization:Int = 16;
	public static var curQuant = 3;

	public var quantizations:Array<Int> = [4, 8, 12, 16, 20, 24, 32, 48, 64, 96, 192];

	var text:String = "";

	public static var vortex:Bool = false;

	public var mouseQuant:Bool = false;

	override function create()
	{
		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			Difficulty.resetList();
			_song =
				{
					name: 'stalstruck',
					sections: [],
					events: [],
					bpm: 159.0,
					needsVoices: false,
					arrowSkin: '',
					players: ['bf'],
					opponents: ['dad'],
					neutrals: ['gf'],
					speed: 1,
					stage: 'arch'
				};
			addSection();
			PlayState.SONG = _song;
		}

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Chart Editor", StringTools.replace(_song.name, '-', ' '));
		#end

		vortex = FlxG.save.data.chart_vortex;
		ignoreWarnings = FlxG.save.data.ignoreWarnings;

		gridLayer = new FlxTypedGroup<FlxSprite>();
		add(gridLayer);

		waveformSprite = new FlxSprite(GRID_SIZE, 0).makeGraphic(1, 1, 0x00FFFFFF);
		add(waveformSprite);

		var eventIcon:FlxSprite = new FlxSprite(-GRID_SIZE - 5, -90).loadGraphic(Paths.image('eventArrow'));
		eventIcon.antialiasing = ClientPrefs.data.antialiasing;
		leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('face');
		eventIcon.scrollFactor.set(1, 1);
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		eventIcon.setGraphicSize(30, 30);
		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(eventIcon);
		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(GRID_SIZE + 10, -100);
		rightIcon.setPosition(GRID_SIZE * 5.2, -100);

		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedEventType = new FlxTypedGroup<FlxText>();

		nextRenderedSustains = new FlxTypedGroup<FlxSprite>();
		nextRenderedNotes = new FlxTypedGroup<Note>();

		updateJsonData();
		currentSongName = Paths.formatToSongPath(_song.name);
		loadSong();
		reloadGridLayer();
		Conductor.bpm = _song.bpm;
		Conductor.mapBPMChanges(_song);
		if (curSec >= _song.sections.length)
			curSec = _song.sections.length - 1;

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(GRID_SIZE * 9), 4);
		add(strumLine);

		quant = new AttachedSprite('chart editor/chart_quant', 'chart_quant', "shared");
		quant.animation.addByPrefix('q', 'chart_quant', 0, false);
		quant.animation.play('q', true, false, 0);
		quant.sprTracker = strumLine;
		quant.xAdd = -32;
		quant.yAdd = 8;
		add(quant);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		for (i in 0...8)
		{
			var note:StrumNote = new StrumNote(GRID_SIZE * (i + 1), strumLine.y, i % 4, 0);
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.pressed = false;
			strumLineNotes.add(note);
			note.scrollFactor.set(1, 1);
		}
		add(strumLineNotes);

		camPos = new FlxObject(0, 0, 1, 1);
		camPos.setPosition(strumLine.x + CAM_OFFSET, strumLine.y);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		dummyArrow.antialiasing = ClientPrefs.data.antialiasing;
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Events", label: 'Events'},
			{name: "Controls", label: 'Controls'},
			{name: "Charting", label: 'Charting'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(360, 670);
		UI_box.x = 640 + GRID_SIZE * 0.5;
		UI_box.y = 25;
		UI_box.scrollFactor.set();
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addEventsUI();
		addChartingUI();
		addControlsUI();
		updateHeads();
		updateWaveform();
		// UI_box.selected_tab = 4;

		add(curRenderedSustains);
		add(curRenderedNotes);
		add(curRenderedEventType);
		add(nextRenderedSustains);
		add(nextRenderedNotes);

		if (lastSong != currentSongName)
		{
			changeSection();
		}
		lastSong = currentSongName;

		bpmTxt = new FlxText(UI_box.x + UI_box.width + 50, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		FlxG.camera.fade(FlxG.camera.bgColor, 0.25, true);

		updateGrid();
		super.create();
	}

	var check_mute_inst:FlxUICheckBox = null;
	var check_mute_vocals:FlxUICheckBox = null;
	var check_vortex:FlxUICheckBox = null;
	var check_warnings:FlxUICheckBox = null;
	var playSoundBf:FlxUICheckBox = null;
	var playSoundDad:FlxUICheckBox = null;
	var UI_songTitle:FlxUIInputText;
	var stageDropDown:FlxUIDropDownMenu;
	#if FLX_PITCH
	var sliderRate:FlxUISlider;
	#end

	function addSongUI():Void
	{
		UI_songTitle = new FlxUIInputText(10, 10, 70, _song.name, 8);
		blockPressWhileTypingOn.push(UI_songTitle);

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			// trace('CHECKED!');
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + 90, saveButton.y, "Reload Audio", function()
		{
			currentSongName = Paths.formatToSongPath(UI_songTitle.text);
			updateJsonData();
			loadSong();
			updateWaveform();
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, function()
			{
				loadJson(_song.name.toLowerCase());
			}, null, ignoreWarnings));
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'Load Autosave', function()
		{
			PlayState.SONG = Song.parseJSON(FlxG.save.data.autosave);
			FlxG.resetState();
		});

		var loadEventJson:FlxButton = new FlxButton(loadAutosaveBtn.x, loadAutosaveBtn.y + 30, 'Load Events', function()
		{
			var songName:String = Paths.formatToSongPath(_song.name);
			var file:String = Paths.json(songName + '/events');

			if (OpenFlAssets.exists(file))
			{
				clearEvents();
				var events:SwagSong = Song.loadFromJson('events', songName);
				_song.events = events.events;
				changeSection(curSec);
			}
		});

		var saveEvents:FlxButton = new FlxButton(110, reloadSongJson.y, 'Save Events', function()
		{
			saveEvents();
		});

		var clear_events:FlxButton = new FlxButton(reloadSong.x, 270, 'Clear events', function()
		{
			openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, clearEvents, null, ignoreWarnings));
		});
		clear_events.color = FlxColor.RED;
		clear_events.label.color = FlxColor.WHITE;

		var clear_notes:FlxButton = new FlxButton(clear_events.x, clear_events.y + 30, 'Clear notes', function()
		{
			openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, function()
			{
				for (sec in 0..._song.sections.length)
				{
					_song.sections[sec].notes = [];
				}
				updateGrid();
			}, null, ignoreWarnings));
		});
		clear_notes.color = FlxColor.RED;
		clear_notes.label.color = FlxColor.WHITE;

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 70, 1, 1, 1, 400, 3);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';
		blockPressWhileTypingOnStepper.push(stepperBPM);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, stepperBPM.y + 35, 0.1, 1, 0.1, 10, 2);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';
		blockPressWhileTypingOnStepper.push(stepperSpeed);

		noteSkinInputText = new FlxUIInputText(10, 280, 150, _song.arrowSkin != null ? _song.arrowSkin : '', 8);
		blockPressWhileTypingOn.push(noteSkinInputText);

		var reloadNotesButton:FlxButton = new FlxButton(noteSkinInputText.x + 5, noteSkinInputText.y + 20, 'Change Notes', function()
		{
			_song.arrowSkin = noteSkinInputText.text;
			updateGrid();
		});

		var tempArray:Array<String> = [];
		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		for (character in characters)
		{
			if (character.trim().length > 0)
				tempArray.push(character);
		}
		tempArray = [];

		var player1DropDown = new FlxUIDropDownMenu(10, stepperSpeed.y + 45, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true),
			function(character:String)
			{
				_song.players[0] = characters[Std.parseInt(character)];
				updateJsonData();
				updateHeads();
			});
		player1DropDown.selectedLabel = _song.players[0];
		blockPressWhileScrolling.push(player1DropDown);

		var gfVersionDropDown = new FlxUIDropDownMenu(player1DropDown.x, player1DropDown.y + 40, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true),
			function(character:String)
			{
				_song.neutrals[0] = characters[Std.parseInt(character)];
				updateJsonData();
				updateHeads();
			});
		gfVersionDropDown.selectedLabel = _song.neutrals[0];
		blockPressWhileScrolling.push(gfVersionDropDown);

		var player2DropDown = new FlxUIDropDownMenu(player1DropDown.x, gfVersionDropDown.y + 40, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true),
			function(character:String)
			{
				_song.opponents[0] = characters[Std.parseInt(character)];
				updateJsonData();
				updateHeads();
			});
		player2DropDown.selectedLabel = _song.opponents[0];
		blockPressWhileScrolling.push(player2DropDown);

		var directories:Array<String> = [Paths.getPreloadPath('stages/')];
		var stageFile:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));
		var stages:Array<String> = [];
		for (stage in stageFile)
		{
			if (stage.trim().length > 0)
			{
				stages.push(stage);
			}
			tempArray.push(stage);
		}

		if (stages.length < 1)
			stages.push('arch');

		stageDropDown = new FlxUIDropDownMenu(player1DropDown.x + 140, player1DropDown.y, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true),
			function(character:String)
			{
				_song.stage = stages[Std.parseInt(character)];
			});
		stageDropDown.selectedLabel = _song.stage;
		blockPressWhileScrolling.push(stageDropDown);

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(clear_events);
		tab_group_song.add(clear_notes);
		tab_group_song.add(saveButton);
		tab_group_song.add(saveEvents);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(loadEventJson);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(reloadNotesButton);
		tab_group_song.add(noteSkinInputText);
		tab_group_song.add(new FlxText(noteSkinInputText.x, noteSkinInputText.y - 15, 0, 'Note Texture:'));
		tab_group_song.add(new FlxText(stepperBPM.x, stepperBPM.y - 15, 0, 'Song BPM:'));
		tab_group_song.add(new FlxText(stepperSpeed.x, stepperSpeed.y - 15, 0, 'Song Speed:'));
		tab_group_song.add(new FlxText(player2DropDown.x, player2DropDown.y - 15, 0, 'Opponent:'));
		tab_group_song.add(new FlxText(gfVersionDropDown.x, gfVersionDropDown.y - 15, 0, 'Girlfriend:'));
		tab_group_song.add(new FlxText(player1DropDown.x, player1DropDown.y - 15, 0, 'Boyfriend:'));
		tab_group_song.add(new FlxText(stageDropDown.x, stageDropDown.y - 15, 0, 'Stage:'));
		tab_group_song.add(player2DropDown);
		tab_group_song.add(gfVersionDropDown);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(stageDropDown);

		UI_box.addGroup(tab_group_song);

		FlxG.camera.follow(camPos);
	}

	var stepperBeats:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_gfSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	var sectionToCopy:Int = 0;
	var notesCopied:Array<Dynamic>;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		check_mustHitSection = new FlxUICheckBox(10, 15, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = _song.sections[curSec].mustHitSection;

		check_gfSection = new FlxUICheckBox(10, check_mustHitSection.y + 22, null, null, "GF section", 100);
		check_gfSection.name = 'check_gf';
		check_gfSection.checked = _song.sections[curSec].gfSection;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(check_gfSection.x + 120, check_gfSection.y, null, null, "Alt Animation", 100);
		check_altAnim.checked = _song.sections[curSec].altAnim;

		stepperBeats = new FlxUINumericStepper(10, 100, 1, 4, 1, 7, 2);
		stepperBeats.value = getSectionBeats();
		stepperBeats.name = 'section_beats';
		blockPressWhileTypingOnStepper.push(stepperBeats);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, stepperBeats.y + 30, null, null, 'Change BPM', 100);
		check_changeBPM.checked = _song.sections[curSec].changeBPM;
		check_changeBPM.name = 'check_changeBPM';

		stepperSectionBPM = new FlxUINumericStepper(10, check_changeBPM.y + 20, 1, Conductor.bpm, 0, 999, 1);
		if (check_changeBPM.checked)
		{
			stepperSectionBPM.value = _song.sections[curSec].bpm;
		}
		else
		{
			stepperSectionBPM.value = Conductor.bpm;
		}
		stepperSectionBPM.name = 'section_bpm';
		blockPressWhileTypingOnStepper.push(stepperSectionBPM);

		var check_eventsSec:FlxUICheckBox = null;
		var check_notesSec:FlxUICheckBox = null;
		var copyButton:FlxButton = new FlxButton(10, 190, "Copy Section", function()
		{
			notesCopied = [];
			sectionToCopy = curSec;
			for (i in 0..._song.sections[curSec].notes.length)
			{
				var note:Array<Dynamic> = _song.sections[curSec].notes[i];
				notesCopied.push(note);
			}

			var startThing:Float = sectionStartTime();
			var endThing:Float = sectionStartTime(1);
			for (event in _song.events)
			{
				var strumTime:Float = event[0];
				if (endThing > event[0] && event[0] >= startThing)
				{
					var copiedEventArray:Array<Dynamic> = [];
					for (i in 0...event[1].length)
					{
						var eventToPush:Array<Dynamic> = event[1][i];
						copiedEventArray.push([eventToPush[0], eventToPush[1], eventToPush[2]]);
					}
					notesCopied.push([strumTime, -1, copiedEventArray]);
				}
			}
		});

		var pasteButton:FlxButton = new FlxButton(copyButton.x + 100, copyButton.y, "Paste Section", function()
		{
			if (notesCopied == null || notesCopied.length < 1)
			{
				return;
			}

			var addToTime:Float = Conductor.stepCrochet * (getSectionBeats() * 4 * (curSec - sectionToCopy));
			// trace('Time to add: ' + addToTime);

			for (note in notesCopied)
			{
				var copiedNote:Array<Dynamic> = [];
				var newStrumTime:Float = note[0] + addToTime;
				if (note[1] < 0)
				{
					if (check_eventsSec.checked)
					{
						var copiedEventArray:Array<Dynamic> = [];
						for (i in 0...note[2].length)
						{
							var eventToPush:Array<Dynamic> = note[2][i];
							copiedEventArray.push([eventToPush[0], eventToPush[1], eventToPush[2]]);
						}
						_song.events.push([newStrumTime, copiedEventArray]);
					}
				}
				else
				{
					if (check_notesSec.checked)
					{
						if (note[4] != null)
							copiedNote = [newStrumTime, note[1], note[2], note[3], note[4]];
						else
							copiedNote = [newStrumTime, note[1], note[2], note[3]];

						_song.sections[curSec].notes.push(copiedNote);
					}
				}
			}
			updateGrid();
		});

		var clearSectionButton:FlxButton = new FlxButton(pasteButton.x + 100, pasteButton.y, "Clear", function()
		{
			if (check_notesSec.checked)
			{
				_song.sections[curSec].notes = [];
			}

			if (check_eventsSec.checked)
			{
				var i:Int = _song.events.length - 1;
				var startThing:Float = sectionStartTime();
				var endThing:Float = sectionStartTime(1);
				while (i > -1)
				{
					var event:Array<Dynamic> = _song.events[i];
					if (event != null && endThing > event[0] && event[0] >= startThing)
					{
						_song.events.remove(event);
					}
					--i;
				}
			}
			updateGrid();
			updateNoteUI();
		});
		clearSectionButton.color = FlxColor.RED;
		clearSectionButton.label.color = FlxColor.WHITE;

		check_notesSec = new FlxUICheckBox(10, clearSectionButton.y + 25, null, null, "Notes", 100);
		check_notesSec.checked = true;
		check_eventsSec = new FlxUICheckBox(check_notesSec.x + 100, check_notesSec.y, null, null, "Events", 100);
		check_eventsSec.checked = true;

		var swapSection:FlxButton = new FlxButton(10, check_notesSec.y + 40, "Swap section", function()
		{
			for (i in 0..._song.sections[curSec].notes.length)
			{
				var note:Array<Dynamic> = _song.sections[curSec].notes[i];
				note[1] = (note[1] + 4) % 8;
				_song.sections[curSec].notes[i] = note;
			}
			updateGrid();
		});

		var stepperCopy:FlxUINumericStepper = null;
		var copyLastButton:FlxButton = new FlxButton(10, swapSection.y + 30, "Copy last section", function()
		{
			var value:Int = Std.int(stepperCopy.value);
			if (value == 0)
				return;

			var daSec = FlxMath.maxInt(curSec, value);

			for (note in _song.sections[daSec - value].notes)
			{
				var strum = note[0] + Conductor.stepCrochet * (getSectionBeats(daSec) * 4 * value);

				var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];
				_song.sections[daSec].notes.push(copiedNote);
			}

			var startThing:Float = sectionStartTime(-value);
			var endThing:Float = sectionStartTime(-value + 1);
			for (event in _song.events)
			{
				var strumTime:Float = event[0];
				if (endThing > event[0] && event[0] >= startThing)
				{
					strumTime += Conductor.stepCrochet * (getSectionBeats(daSec) * 4 * value);
					var copiedEventArray:Array<Dynamic> = [];
					for (i in 0...event[1].length)
					{
						var eventToPush:Array<Dynamic> = event[1][i];
						copiedEventArray.push([eventToPush[0], eventToPush[1], eventToPush[2]]);
					}
					_song.events.push([strumTime, copiedEventArray]);
				}
			}
			updateGrid();
		});
		copyLastButton.setGraphicSize(80, 30);
		copyLastButton.updateHitbox();

		stepperCopy = new FlxUINumericStepper(copyLastButton.x + 100, copyLastButton.y, 1, 1, -999, 999, 0);
		blockPressWhileTypingOnStepper.push(stepperCopy);

		var duetButton:FlxButton = new FlxButton(10, copyLastButton.y + 45, "Duet Notes", function()
		{
			var duetNotes:Array<Array<Dynamic>> = [];
			for (note in _song.sections[curSec].notes)
			{
				var boob = note[1];
				if (boob > 3)
				{
					boob -= 4;
				}
				else
				{
					boob += 4;
				}

				var copiedNote:Array<Dynamic> = [note[0], boob, note[2], note[3]];
				duetNotes.push(copiedNote);
			}

			for (i in duetNotes)
			{
				_song.sections[curSec].notes.push(i);
			}

			updateGrid();
		});
		var mirrorButton:FlxButton = new FlxButton(duetButton.x + 100, duetButton.y, "Mirror Notes", function()
		{
			var duetNotes:Array<Array<Dynamic>> = [];
			for (note in _song.sections[curSec].notes)
			{
				var boob = note[1] % 4;
				boob = 3 - boob;
				if (note[1] > 3)
					boob += 4;

				note[1] = boob;
				var copiedNote:Array<Dynamic> = [note[0], boob, note[2], note[3]];
				// duetNotes.push(copiedNote);
			}

			for (i in duetNotes)
			{
				// _song.sections[curSec].notes.push(i);
			}

			updateGrid();
		});

		tab_group_section.add(new FlxText(stepperBeats.x, stepperBeats.y - 15, 0, 'Beats per Section:'));
		tab_group_section.add(stepperBeats);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_gfSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(pasteButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(check_notesSec);
		tab_group_section.add(check_eventsSec);
		tab_group_section.add(swapSection);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(copyLastButton);
		tab_group_section.add(duetButton);
		tab_group_section.add(mirrorButton);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;
	var strumTimeInputText:FlxUIInputText; // I wanted to use a stepper but we can't scale these as far as i know :(
	var currentType:Int = 0;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 25, Conductor.stepCrochet * 0.5, 0, 0, Conductor.stepCrochet * 64);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';
		blockPressWhileTypingOnStepper.push(stepperSusLength);

		strumTimeInputText = new FlxUIInputText(10, 65, 180, "0");
		tab_group_note.add(strumTimeInputText);
		blockPressWhileTypingOn.push(strumTimeInputText);

		tab_group_note.add(new FlxText(10, 10, 0, 'Sustain length:'));
		tab_group_note.add(new FlxText(10, 50, 0, 'Strum time (in miliseconds):'));
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(strumTimeInputText);

		UI_box.addGroup(tab_group_note);
	}

	var eventDropDown:FlxUIDropDownMenu;
	var descText:FlxText;
	var selectedEventText:FlxText;

	function addEventsUI():Void
	{
		var tab_group_event = new FlxUI(null, UI_box);
		tab_group_event.name = 'Events';

		descText = new FlxText(20, 200, 0, eventStuff[0][0]);

		var leEvents:Array<String> = [];
		for (i in 0...eventStuff.length)
		{
			leEvents.push(eventStuff[i][0]);
		}

		var text:FlxText = new FlxText(20, 30, 0, "Event:");
		tab_group_event.add(text);
		eventDropDown = new FlxUIDropDownMenu(20, 50, FlxUIDropDownMenu.makeStrIdLabelArray(leEvents, true), function(pressed:String)
		{
			var selectedEvent:Int = Std.parseInt(pressed);
			descText.text = eventStuff[selectedEvent][1];
			if (curSelectedNote != null && eventStuff != null)
			{
				if (curSelectedNote != null && curSelectedNote[2] == null)
				{
					curSelectedNote[1][curEventSelected][0] = eventStuff[selectedEvent][0];
				}
				updateGrid();
			}
		});
		blockPressWhileScrolling.push(eventDropDown);

		var text:FlxText = new FlxText(20, 90, 0, "Value 1:");
		tab_group_event.add(text);
		value1InputText = new FlxUIInputText(20, 110, 100, "");
		blockPressWhileTypingOn.push(value1InputText);

		var text:FlxText = new FlxText(20, 130, 0, "Value 2:");
		tab_group_event.add(text);
		value2InputText = new FlxUIInputText(20, 150, 100, "");
		blockPressWhileTypingOn.push(value2InputText);

		// New event buttons
		var removeButton:FlxButton = new FlxButton(eventDropDown.x + eventDropDown.width + 10, eventDropDown.y, '-', function()
		{
			if (curSelectedNote != null && curSelectedNote[2] == null) // Is event note
			{
				if (curSelectedNote[1].length < 2)
				{
					_song.events.remove(curSelectedNote);
					curSelectedNote = null;
				}
				else
				{
					curSelectedNote[1].remove(curSelectedNote[1][curEventSelected]);
				}

				var eventsGroup:Array<Dynamic>;
				--curEventSelected;
				if (curEventSelected < 0)
					curEventSelected = 0;
				else if (curSelectedNote != null && curEventSelected >= (eventsGroup = curSelectedNote[1]).length)
					curEventSelected = eventsGroup.length - 1;

				changeEventSelected();
				updateGrid();
			}
		});
		removeButton.setGraphicSize(Std.int(removeButton.height), Std.int(removeButton.height));
		removeButton.updateHitbox();
		removeButton.color = FlxColor.RED;
		removeButton.label.color = FlxColor.WHITE;
		removeButton.label.size = 12;
		setAllLabelsOffset(removeButton, -30, 0);
		tab_group_event.add(removeButton);

		var addButton:FlxButton = new FlxButton(removeButton.x + removeButton.width + 10, removeButton.y, '+', function()
		{
			if (curSelectedNote != null && curSelectedNote[2] == null) // Is event note
			{
				var eventsGroup:Array<Dynamic> = curSelectedNote[1];
				eventsGroup.push(['', '', '']);

				changeEventSelected(1);
				updateGrid();
			}
		});
		addButton.setGraphicSize(Std.int(removeButton.width), Std.int(removeButton.height));
		addButton.updateHitbox();
		addButton.color = FlxColor.GREEN;
		addButton.label.color = FlxColor.WHITE;
		addButton.label.size = 12;
		setAllLabelsOffset(addButton, -30, 0);
		tab_group_event.add(addButton);

		var moveLeftButton:FlxButton = new FlxButton(addButton.x + addButton.width + 20, addButton.y, '<', function()
		{
			changeEventSelected(-1);
		});
		moveLeftButton.setGraphicSize(Std.int(addButton.width), Std.int(addButton.height));
		moveLeftButton.updateHitbox();
		moveLeftButton.label.size = 12;
		setAllLabelsOffset(moveLeftButton, -30, 0);
		tab_group_event.add(moveLeftButton);

		var moveRightButton:FlxButton = new FlxButton(moveLeftButton.x + moveLeftButton.width + 10, moveLeftButton.y, '>', function()
		{
			changeEventSelected(1);
		});
		moveRightButton.setGraphicSize(Std.int(moveLeftButton.width), Std.int(moveLeftButton.height));
		moveRightButton.updateHitbox();
		moveRightButton.label.size = 12;
		setAllLabelsOffset(moveRightButton, -30, 0);
		tab_group_event.add(moveRightButton);

		selectedEventText = new FlxText(addButton.x - 100, addButton.y + addButton.height + 6, (moveRightButton.x - addButton.x) + 186, 'Selected Event: None');
		selectedEventText.alignment = CENTER;
		tab_group_event.add(selectedEventText);

		tab_group_event.add(descText);
		tab_group_event.add(value1InputText);
		tab_group_event.add(value2InputText);
		tab_group_event.add(eventDropDown);

		UI_box.addGroup(tab_group_event);
	}

	function changeEventSelected(change:Int = 0)
	{
		if (curSelectedNote != null && curSelectedNote[2] == null) // Is event note
		{
			curEventSelected += change;
			if (curEventSelected < 0)
				curEventSelected = Std.int(curSelectedNote[1].length) - 1;
			else if (curEventSelected >= curSelectedNote[1].length)
				curEventSelected = 0;
			selectedEventText.text = 'Selected Event: ' + (curEventSelected + 1) + ' / ' + curSelectedNote[1].length;
		}
		else
		{
			curEventSelected = 0;
			selectedEventText.text = 'Selected Event: None';
		}
		updateNoteUI();
	}

	function setAllLabelsOffset(button:FlxButton, x:Float, y:Float)
	{
		for (point in button.labelOffsets)
		{
			point.set(x, y);
		}
	}

	var metronome:FlxUICheckBox;
	var mouseScrollingQuant:FlxUICheckBox;
	var metronomeStepper:FlxUINumericStepper;
	var metronomeOffsetStepper:FlxUINumericStepper;
	var disableAutoScrolling:FlxUICheckBox;
	#if desktop
	var waveformUseInstrumental:FlxUICheckBox;
	var waveformUseVoices:FlxUICheckBox;
	#end
	var instVolume:FlxUINumericStepper;
	var voicesVolume:FlxUINumericStepper;

	function addChartingUI()
	{
		var tab_group_chart = new FlxUI(null, UI_box);
		tab_group_chart.name = 'Charting';

		#if desktop
		if (FlxG.save.data.chart_waveformInst == null)
			FlxG.save.data.chart_waveformInst = false;
		if (FlxG.save.data.chart_waveformVoices == null)
			FlxG.save.data.chart_waveformVoices = false;

		waveformUseInstrumental = new FlxUICheckBox(10, 90, null, null, "Waveform for Instrumental", 100);
		waveformUseInstrumental.checked = FlxG.save.data.chart_waveformInst;
		waveformUseInstrumental.callback = function()
		{
			waveformUseVoices.checked = false;
			FlxG.save.data.chart_waveformVoices = false;
			FlxG.save.data.chart_waveformInst = waveformUseInstrumental.checked;
			updateWaveform();
		};

		waveformUseVoices = new FlxUICheckBox(waveformUseInstrumental.x + 100, waveformUseInstrumental.y, null, null, "Waveform\n(Main Vocals)", 85);
		waveformUseVoices.checked = FlxG.save.data.chart_waveformVoices && !waveformUseInstrumental.checked;
		waveformUseVoices.callback = function()
		{
			waveformUseInstrumental.checked = false;
			FlxG.save.data.chart_waveformInst = false;
			FlxG.save.data.chart_waveformVoices = waveformUseVoices.checked;
			updateWaveform();
		};
		#end

		check_mute_inst = new FlxUICheckBox(10, 280, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = instVolume.value;
			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};
		mouseScrollingQuant = new FlxUICheckBox(10, 190, null, null, "Mouse Scrolling Quantization", 100);
		if (FlxG.save.data.mouseScrollingQuant == null)
			FlxG.save.data.mouseScrollingQuant = false;
		mouseScrollingQuant.checked = FlxG.save.data.mouseScrollingQuant;

		mouseScrollingQuant.callback = function()
		{
			FlxG.save.data.mouseScrollingQuant = mouseScrollingQuant.checked;
			mouseQuant = FlxG.save.data.mouseScrollingQuant;
		};

		check_vortex = new FlxUICheckBox(10, 160, null, null, "Vortex Editor (BETA)", 100);
		if (FlxG.save.data.chart_vortex == null)
			FlxG.save.data.chart_vortex = false;
		check_vortex.checked = FlxG.save.data.chart_vortex;

		check_vortex.callback = function()
		{
			FlxG.save.data.chart_vortex = check_vortex.checked;
			vortex = FlxG.save.data.chart_vortex;
			reloadGridLayer();
		};

		check_warnings = new FlxUICheckBox(10, 120, null, null, "Ignore Progress Warnings", 100);
		if (FlxG.save.data.ignoreWarnings == null)
			FlxG.save.data.ignoreWarnings = false;
		check_warnings.checked = FlxG.save.data.ignoreWarnings;

		check_warnings.callback = function()
		{
			FlxG.save.data.ignoreWarnings = check_warnings.checked;
			ignoreWarnings = FlxG.save.data.ignoreWarnings;
		};

		check_mute_vocals = new FlxUICheckBox(check_mute_inst.x, check_mute_inst.y + 30, null, null, "Mute Main Vocals (in editor)", 100);
		check_mute_vocals.checked = false;
		check_mute_vocals.callback = function()
		{
			var vol:Float = voicesVolume.value;
			if (check_mute_vocals.checked)
				vol = 0;

			if (vocals != null)
				vocals.volume = vol;
		};

		playSoundBf = new FlxUICheckBox(check_mute_inst.x, check_mute_vocals.y + 30, null, null, 'Play Sound (Boyfriend notes)', 100, function()
		{
			FlxG.save.data.chart_playSoundBf = playSoundBf.checked;
		});
		if (FlxG.save.data.chart_playSoundBf == null)
			FlxG.save.data.chart_playSoundBf = false;
		playSoundBf.checked = FlxG.save.data.chart_playSoundBf;

		playSoundDad = new FlxUICheckBox(check_mute_inst.x + 120, playSoundBf.y, null, null, 'Play Sound (Opponent notes)', 100, function()
		{
			FlxG.save.data.chart_playSoundDad = playSoundDad.checked;
		});
		if (FlxG.save.data.chart_playSoundDad == null)
			FlxG.save.data.chart_playSoundDad = false;
		playSoundDad.checked = FlxG.save.data.chart_playSoundDad;

		metronome = new FlxUICheckBox(10, 15, null, null, "Metronome Enabled", 100, function()
		{
			FlxG.save.data.chart_metronome = metronome.checked;
		});
		if (FlxG.save.data.chart_metronome == null)
			FlxG.save.data.chart_metronome = false;
		metronome.checked = FlxG.save.data.chart_metronome;

		metronomeStepper = new FlxUINumericStepper(15, 55, 5, _song.bpm, 1, 1500, 1);
		metronomeOffsetStepper = new FlxUINumericStepper(metronomeStepper.x + 100, metronomeStepper.y, 25, 0, 0, 1000, 1);
		blockPressWhileTypingOnStepper.push(metronomeStepper);
		blockPressWhileTypingOnStepper.push(metronomeOffsetStepper);

		disableAutoScrolling = new FlxUICheckBox(metronome.x + 120, metronome.y, null, null, "Disable Autoscroll (Not Recommended)", 120, function()
		{
			FlxG.save.data.chart_noAutoScroll = disableAutoScrolling.checked;
		});
		if (FlxG.save.data.chart_noAutoScroll == null)
			FlxG.save.data.chart_noAutoScroll = false;
		disableAutoScrolling.checked = FlxG.save.data.chart_noAutoScroll;

		instVolume = new FlxUINumericStepper(metronomeStepper.x, 250, 0.1, 1, 0, 1, 1);
		instVolume.value = FlxG.sound.music.volume;
		instVolume.name = 'inst_volume';
		blockPressWhileTypingOnStepper.push(instVolume);

		voicesVolume = new FlxUINumericStepper(instVolume.x + 100, instVolume.y, 0.1, 1, 0, 1, 1);
		voicesVolume.value = vocals.volume;
		voicesVolume.name = 'voices_volume';
		blockPressWhileTypingOnStepper.push(voicesVolume);

		#if FLX_PITCH
		sliderRate = new FlxUISlider(this, 'playbackSpeed', 120, 120, 0.5, 3, 150, null, 5, FlxColor.WHITE, FlxColor.BLACK);
		sliderRate.nameLabel.text = 'Playback Rate';
		tab_group_chart.add(sliderRate);
		#end

		tab_group_chart.add(new FlxText(metronomeStepper.x, metronomeStepper.y - 15, 0, 'BPM:'));
		tab_group_chart.add(new FlxText(metronomeOffsetStepper.x, metronomeOffsetStepper.y - 15, 0, 'Offset (ms):'));
		tab_group_chart.add(new FlxText(instVolume.x, instVolume.y - 15, 0, 'Inst Volume'));
		tab_group_chart.add(new FlxText(voicesVolume.x, voicesVolume.y - 15, 0, 'Voices Volume'));
		tab_group_chart.add(metronome);
		tab_group_chart.add(disableAutoScrolling);
		tab_group_chart.add(metronomeStepper);
		tab_group_chart.add(metronomeOffsetStepper);
		#if desktop
		tab_group_chart.add(waveformUseInstrumental);
		tab_group_chart.add(waveformUseVoices);
		#end
		tab_group_chart.add(instVolume);
		tab_group_chart.add(voicesVolume);
		tab_group_chart.add(check_mute_inst);
		tab_group_chart.add(check_mute_vocals);
		tab_group_chart.add(check_vortex);
		tab_group_chart.add(mouseScrollingQuant);
		tab_group_chart.add(check_warnings);
		tab_group_chart.add(playSoundBf);
		tab_group_chart.add(playSoundDad);
		UI_box.addGroup(tab_group_chart);
	}

	var noteSkinInputText:FlxUIInputText;

	function addControlsUI()
	{
		var tab_group_controls = new FlxUI(null, UI_box);
		tab_group_controls.name = 'Controls';
		text = "W/S, Up/Down, Mouse Wheel - Set Conductor's strum time
		\nA/D - Go to the previous/next section
		\nLeft/Right - Change Selection Snap"
			+ #if FLX_PITCH "\n[ / ] - Change Song Playback Rate
		\nALT + Left [ / ] - Reset Song Playback Rate"
			+ #end "\nHold Shift to move 4x faster
		\nHold Control and click on an arrow to select it
		\nZ/X - Zoom in/out
		\nEnter - Play your chart
		\nQ/E - Decrease/Increase Note Sustain Length
		\nSpace - Stop/Resume song";

		var tips:FlxText = new FlxText(8, 8, 350, text, 14);
		tips.setFormat(Paths.font("Monocraft.ttf"), 14, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tips.borderSize = 2;
		tips.scrollFactor.set();
		tab_group_controls.add(tips);
		UI_box.addGroup(tab_group_controls);
	}

	function loadSong():Void
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = new FlxSound();
		try
		{
			var file:Dynamic = Paths.voices(currentSongName);
			if ((Std.isOfType(file, Sound) || OpenFlAssets.exists(file)) && file != null)
			{
				vocals.loadEmbedded(file);
				vocals.autoDestroy = false;
				FlxG.sound.list.add(vocals);
			}
		}
		catch (e:Dynamic)
		{
		}
		generateSong();
		FlxG.sound.music.pause();
		Conductor.songPosition = sectionStartTime();
		FlxG.sound.music.time = Conductor.songPosition;

		var curTime:Float = 0;
		// trace(_song.sections.length);
		if (_song.sections.length <= 1) // First load ever
		{
			trace('first load ever!!');
			while (curTime < FlxG.sound.music.length)
			{
				addSection();
				curTime += (60 / _song.bpm) * 4000;
			}
		}
	}

	var playtesting:Bool = false;
	var playtestingTime:Float = 0;
	var playtestingOnComplete:Void->Void = null;

	override function closeSubState()
	{
		if (playtesting)
		{
			FlxG.sound.music.pause();
			FlxG.sound.music.time = playtestingTime;
			FlxG.sound.music.onComplete = playtestingOnComplete;
			if (instVolume != null)
				FlxG.sound.music.volume = instVolume.value;
			if (check_mute_inst != null && check_mute_inst.checked)
				FlxG.sound.music.volume = 0;

			if (vocals != null)
			{
				vocals.pause();
				vocals.time = playtestingTime;
				if (voicesVolume != null)
					vocals.volume = voicesVolume.value;
				if (check_mute_vocals != null && check_mute_vocals.checked)
					vocals.volume = 0;
			}

			#if desktop
			// Updating Discord Rich Presence
			DiscordClient.changePresence("Chart Editor", StringTools.replace(_song.name, '-', ' '));
			#end
		}
		super.closeSubState();
	}

	function generateSong()
	{
		FlxG.sound.playMusic(Paths.inst(currentSongName), 0.6 /*, false*/);
		FlxG.sound.music.autoDestroy = false;
		if (instVolume != null)
			FlxG.sound.music.volume = instVolume.value;
		if (check_mute_inst != null && check_mute_inst.checked)
			FlxG.sound.music.volume = 0;

		FlxG.sound.music.onComplete = function()
		{
			FlxG.sound.music.pause();
			Conductor.songPosition = 0;
			if (vocals != null)
			{
				vocals.pause();
				vocals.time = 0;
			}
			changeSection();
			curSec = 0;
			updateGrid();
			updateSectionUI();
			if (vocals != null)
				vocals.play();
		};
	}

	function generateUI():Void
	{
		while (groupUI.members.length > 0)
		{
			groupUI.remove(groupUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		groupUI.add(title);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.sections[curSec].mustHitSection = check.checked;

					updateGrid();
					updateHeads();

				case 'GF section':
					_song.sections[curSec].gfSection = check.checked;

					updateGrid();
					updateHeads();

				case 'Change BPM':
					_song.sections[curSec].changeBPM = check.checked;
					FlxG.log.add('changed bpm');
				case "Alt Animation":
					_song.sections[curSec].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			// FlxG.log.add(wname);
			switch (wname)
			{
				case 'section_beats':
					_song.sections[curSec].beats = nums.value;
					reloadGridLayer();

				case 'song_speed':
					_song.speed = nums.value;

				case 'song_bpm':
					_song.bpm = nums.value;
					Conductor.mapBPMChanges(_song);
					Conductor.bpm = nums.value;
					stepperSusLength.stepSize = Math.ceil(Conductor.stepCrochet / 2);
					updateGrid();

				case 'note_susLength':
					if (curSelectedNote != null && curSelectedNote[2] != null)
					{
						curSelectedNote[2] = nums.value;
						updateGrid();
					}

				case 'section_bpm':
					_song.sections[curSec].bpm = nums.value;
					updateGrid();

				case 'inst_volume':
					FlxG.sound.music.volume = nums.value;
					if (check_mute_inst.checked)
						FlxG.sound.music.volume = 0;

				case 'voices_volume':
					vocals.volume = nums.value;
					if (check_mute_vocals.checked)
						vocals.volume = 0;
			}
		}
		else if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText))
		{
			if (sender == noteSkinInputText)
			{
				_song.arrowSkin = noteSkinInputText.text;
			}
			else if (curSelectedNote != null)
			{
				if (sender == value1InputText)
				{
					if (curSelectedNote[1][curEventSelected] != null)
					{
						curSelectedNote[1][curEventSelected][1] = value1InputText.text;
						updateGrid();
					}
				}
				else if (sender == value2InputText)
				{
					if (curSelectedNote[1][curEventSelected] != null)
					{
						curSelectedNote[1][curEventSelected][2] = value2InputText.text;
						updateGrid();
					}
				}
				else if (sender == strumTimeInputText)
				{
					var value:Float = Std.parseFloat(strumTimeInputText.text);
					if (Math.isNaN(value))
						value = 0;
					curSelectedNote[0] = value;
					updateGrid();
				}
			}
		}
		else if (id == FlxUISlider.CHANGE_EVENT && (sender is FlxUISlider))
		{
			switch (sender)
			{
				case 'playbackSpeed':
					playbackSpeed = #if FLX_PITCH Std.int(sliderRate.value) #else 1.0 #end;
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	function sectionStartTime(add:Int = 0):Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSec + add)
		{
			if (_song.sections[i] != null)
			{
				if (_song.sections[i].changeBPM)
				{
					daBPM = _song.sections[i].bpm;
				}
				daPos += getSectionBeats(i) * (1000 * 60 / daBPM);
			}
		}
		return daPos;
	}

	var lastConductorPos:Float;
	var colorSine:Float = 0;

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		if (FlxG.sound.music.time < 0)
		{
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
		}
		else if (FlxG.sound.music.time > FlxG.sound.music.length)
		{
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
		_song.name = UI_songTitle.text;

		strumLineUpdateY();
		for (i in 0...8)
		{
			strumLineNotes.members[i].y = strumLine.y;
		}

		camPos.y = strumLine.y;
		if (!disableAutoScrolling.checked)
		{
			if (Math.ceil(strumLine.y) >= gridBG.height)
			{
				if (_song.sections[curSec + 1] == null)
				{
					addSection();
				}

				changeSection(curSec + 1, false);
			}
			else if (strumLine.y < -10)
			{
				changeSection(curSec - 1, false);
			}
		}
		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * getSectionBeats() * 4) * zoomList[curZoom])
		{
			dummyArrow.visible = true;
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
			{
				var gridmult = GRID_SIZE / (quantization / 16);
				dummyArrow.y = Math.floor(FlxG.mouse.y / gridmult) * gridmult;
			}
		}
		else
		{
			dummyArrow.visible = false;
		}

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEachAlive(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else if (FlxG.keys.pressed.ALT)
						{
							selectNote(note);
							updateGrid();
						}
						else
						{
							// trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * getSectionBeats() * 4) * zoomList[curZoom])
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn)
		{
			if (inputText.hasFocus)
			{
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;
				break;
			}
		}

		if (!blockInput)
		{
			for (stepper in blockPressWhileTypingOnStepper)
			{
				@:privateAccess
				var leText:FlxUIInputText = cast(stepper.text_field, FlxUIInputText);
				if (leText.hasFocus)
				{
					FlxG.sound.muteKeys = [];
					FlxG.sound.volumeDownKeys = [];
					FlxG.sound.volumeUpKeys = [];
					blockInput = true;
					break;
				}
			}
		}

		if (!blockInput)
		{
			FlxG.sound.muteKeys = IntroState.muteKeys;
			FlxG.sound.volumeDownKeys = IntroState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = IntroState.volumeUpKeys;
			for (dropDownMenu in blockPressWhileScrolling)
			{
				if (dropDownMenu.dropPanel.visible)
				{
					blockInput = true;
					break;
				}
			}
		}

		if (!blockInput)
		{
			if (FlxG.keys.justPressed.ENTER)
			{
				autosaveSong();
				PlayState.SONG = _song;
				LoadingState.stage = _song.stage;
				FlxG.sound.music.stop();
				if (vocals != null)
					vocals.stop();
				FlxG.camera.fade(FlxG.camera.bgColor, 0.25, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			}

			if (curSelectedNote != null && curSelectedNote[1] > -1)
			{
				if (FlxG.keys.justPressed.E)
				{
					changeNoteSustain(Conductor.stepCrochet);
				}
				if (FlxG.keys.justPressed.Q)
				{
					changeNoteSustain(-Conductor.stepCrochet);
				}
			}

			if (FlxG.keys.justPressed.BACKSPACE)
			{
				// Protect against lost data when quickly leaving the chart editor.
				autosaveSong();
				PlayState.chartingMode = false;
				FlxG.switchState(() -> new FreeplayState());
				FlxG.sound.playMusic(Paths.music('where_are_we_going'));
				return;
			}

			if (FlxG.keys.justPressed.Z && FlxG.keys.pressed.CONTROL)
			{
				undo();
			}

			if (FlxG.keys.justPressed.Z && curZoom > 0 && !FlxG.keys.pressed.CONTROL)
			{
				--curZoom;
				updateZoom();
			}
			if (FlxG.keys.justPressed.X && curZoom < zoomList.length - 1)
			{
				curZoom++;
				updateZoom();
			}

			if (FlxG.keys.justPressed.TAB)
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					UI_box.selected_tab -= 1;
					if (UI_box.selected_tab < 0)
						UI_box.selected_tab = 5;
				}
				else
				{
					UI_box.selected_tab += 1;
					if (UI_box.selected_tab >= 5)
						UI_box.selected_tab = 0;
				}
			}

			if (FlxG.keys.justPressed.SPACE)
			{
				if (vocals != null)
					vocals.play();
				pauseAndSetVocalsTime();
				if (!FlxG.sound.music.playing)
				{
					FlxG.sound.music.play();
					if (vocals != null)
						vocals.play();
				}
				else
					FlxG.sound.music.pause();
			}

			if (!FlxG.keys.pressed.ALT && FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				if (!mouseQuant)
					FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.8);
				else
				{
					var time:Float = FlxG.sound.music.time;
					var beat:Float = curDecBeat;
					var snap:Float = quantization * 0.25;
					var increase:Float = 1 / snap;
					if (FlxG.mouse.wheel > 0)
					{
						var quant:Float = Conductor.quantize(beat, snap) - increase;
						FlxG.sound.music.time = Conductor.beatToSeconds(quant);
					}
					else
					{
						var quant:Float = Conductor.quantize(beat, snap) + increase;
						FlxG.sound.music.time = Conductor.beatToSeconds(quant);
					}
				}
				pauseAndSetVocalsTime();
			}

			// ARROW VORTEX

			if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
			{
				FlxG.sound.music.pause();

				var holdingShift:Float = 1;
				if (FlxG.keys.pressed.CONTROL)
					holdingShift = 0.25;
				else if (FlxG.keys.pressed.SHIFT)
					holdingShift = 4;

				var daTime:Float = 700 * FlxG.elapsed * holdingShift;

				FlxG.sound.music.time += daTime * (FlxG.keys.pressed.W ? -1 : 1);

				pauseAndSetVocalsTime();
			}

			if (!vortex)
			{
				if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
				{
					FlxG.sound.music.pause();
					updateCurStep();
					var time:Float = FlxG.sound.music.time;
					var beat:Float = curDecBeat;
					var snap:Float = quantization * 0.25;
					var increase:Float = 1 / snap;
					if (FlxG.keys.pressed.UP)
					{
						var quant:Float = Conductor.quantize(beat, snap) - increase; // (Math.floor((beat+snap) / snap) * snap);
						FlxG.sound.music.time = Conductor.beatToSeconds(quant);
					}
					else
					{
						var quant:Float = Conductor.quantize(beat, snap) + increase; // (Math.floor((beat+snap) / snap) * snap);
						FlxG.sound.music.time = Conductor.beatToSeconds(quant);
					}
				}
			}

			var style = currentType;

			if (FlxG.keys.pressed.SHIFT)
			{
				style = 3;
			}

			var conductorTime = Conductor.songPosition; // + sectionStartTime();Conductor.songPosition / Conductor.stepCrochet;

			// AWW YOU MADE IT SEXY <3333 THX SHADMAR

			if (!blockInput)
			{
				if (FlxG.keys.justPressed.RIGHT)
				{
					curQuant++;
					if (curQuant > quantizations.length - 1)
						curQuant = 0;

					quantization = quantizations[curQuant];
				}

				if (FlxG.keys.justPressed.LEFT)
				{
					curQuant--;
					if (curQuant < 0)
						curQuant = quantizations.length - 1;

					quantization = quantizations[curQuant];
				}
				quant.animation.play('q', true, false, curQuant);
			}
			if (vortex && !blockInput)
			{
				var controlArray:Array<Bool> = [
					 FlxG.keys.justPressed.ONE, FlxG.keys.justPressed.TWO, FlxG.keys.justPressed.THREE, FlxG.keys.justPressed.FOUR,
					FlxG.keys.justPressed.FIVE, FlxG.keys.justPressed.SIX, FlxG.keys.justPressed.SEVEN, FlxG.keys.justPressed.EIGHT
				];

				if (controlArray.contains(true))
				{
					for (i in 0...controlArray.length)
					{
						if (controlArray[i])
							doANoteThing(conductorTime, i, style);
					}
				}

				var feces:Float;
				if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
				{
					FlxG.sound.music.pause();

					updateCurStep();
					// FlxG.sound.music.time = (Math.round(curStep/quants[curQuant])*quants[curQuant]) * Conductor.stepCrochet;

					// (Math.floor((curStep+quants[curQuant]*1.5/(quants[curQuant]/2))/quants[curQuant])*quants[curQuant]) * Conductor.stepCrochet;//snap into quantization
					var time:Float = FlxG.sound.music.time;
					var beat:Float = curDecBeat;
					var snap:Float = quantization * 0.25;
					var increase:Float = 1 / snap;
					if (FlxG.keys.pressed.UP)
					{
						var quant:Float = Conductor.quantize(beat, snap) - increase;
						feces = Conductor.beatToSeconds(quant);
					}
					else
					{
						var quant:Float = Conductor.quantize(beat, snap) + increase; // (Math.floor((beat+snap) / snap) * snap);
						feces = Conductor.beatToSeconds(quant);
					}
					FlxTween.tween(FlxG.sound.music, {time: feces}, 0.1, {ease: FlxEase.circOut});
					pauseAndSetVocalsTime();

					var dastrum = 0;

					if (curSelectedNote != null)
					{
						dastrum = curSelectedNote[0];
					}

					var secStart:Float = sectionStartTime();
					var datime = (feces - secStart) - (dastrum - secStart); // idk math find out why it doesn't work on any other section other than 0
					if (curSelectedNote != null)
					{
						var controlArray:Array<Bool> = [
							 FlxG.keys.pressed.ONE, FlxG.keys.pressed.TWO, FlxG.keys.pressed.THREE, FlxG.keys.pressed.FOUR,
							FlxG.keys.pressed.FIVE, FlxG.keys.pressed.SIX, FlxG.keys.pressed.SEVEN, FlxG.keys.pressed.EIGHT
						];

						if (controlArray.contains(true))
						{
							for (i in 0...controlArray.length)
							{
								if (controlArray[i])
									if (curSelectedNote[1] == i)
										curSelectedNote[2] += datime - curSelectedNote[2] - Conductor.stepCrochet;
							}
							updateGrid();
							updateNoteUI();
						}
					}
				}
			}
			var shiftThing:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;

			if (FlxG.keys.justPressed.D)
				changeSection(curSec + shiftThing);
			if (FlxG.keys.justPressed.A)
			{
				if (curSec <= 0)
				{
					changeSection(_song.sections.length - 1);
				}
				else
				{
					changeSection(curSec - shiftThing);
				}
			}
		}
		else if (FlxG.keys.justPressed.ENTER)
		{
			for (i in 0...blockPressWhileTypingOn.length)
			{
				if (blockPressWhileTypingOn[i].hasFocus)
				{
					blockPressWhileTypingOn[i].hasFocus = false;
				}
			}
		}

		strumLineNotes.visible = quant.visible = vortex;

		if (FlxG.sound.music.time < 0)
		{
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
		}
		else if (FlxG.sound.music.time > FlxG.sound.music.length)
		{
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
		strumLineUpdateY();
		camPos.y = strumLine.y;
		for (i in 0...8)
		{
			strumLineNotes.members[i].y = strumLine.y;
			strumLineNotes.members[i].alpha = FlxG.sound.music.playing ? 1 : 0.35;
		}

		#if FLX_PITCH
		// PLAYBACK SPEED CONTROLS //
		var holdingShift = FlxG.keys.pressed.SHIFT;
		var holdingLB = FlxG.keys.pressed.LBRACKET;
		var holdingRB = FlxG.keys.pressed.RBRACKET;
		var pressedLB = FlxG.keys.justPressed.LBRACKET;
		var pressedRB = FlxG.keys.justPressed.RBRACKET;

		if (!holdingShift && pressedLB || holdingShift && holdingLB)
			playbackSpeed -= 0.01;
		if (!holdingShift && pressedRB || holdingShift && holdingRB)
			playbackSpeed += 0.01;
		if (FlxG.keys.pressed.ALT && (pressedLB || pressedRB || holdingLB || holdingRB))
			playbackSpeed = 1;
		//

		if (playbackSpeed <= 0.5)
			playbackSpeed = 0.5;
		if (playbackSpeed >= 3)
			playbackSpeed = 3;

		FlxG.sound.music.pitch = playbackSpeed;
		vocals.pitch = playbackSpeed;
		#end

		bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition * 0.001, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length * 0.001, 2))
			+ "\n\nSection: "
			+ curSec
			+ "\n\nBeat: "
			+ Std.string(curDecBeat).substring(0, 4)
			+ "\n\nStep: "
			+ curStep
			+ "\n\nBeat Snap: "
			+ quantization
			+ "th"
			+ "\n\n"
			+ zoomTxt;

		var playedSound:Array<Bool> = [false, false, false, false];
		curRenderedNotes.forEachAlive(function(note:Note)
		{
			note.alpha = 1;
			if (curSelectedNote != null)
			{
				var laneToCheck:Int = note.lane;
				if (laneToCheck > -1 && note.mustPress != _song.sections[curSec].mustHitSection)
					laneToCheck += 4;

				if (curSelectedNote[0] == note.strumTime
					&& ((curSelectedNote[2] == null && laneToCheck < 0)
						|| (curSelectedNote[2] != null && curSelectedNote[1] == laneToCheck)))
				{
					colorSine += elapsed;
					var colorVal:Float = 0.7 + Math.sin(Math.PI * colorSine) * 0.3;
					note.color = FlxColor.fromRGBFloat(colorVal, colorVal, colorVal,
						0.999); // Alpha can't be 100% or the color won't be updated for some reason, guess i will die
				}
			}

			if (note.strumTime <= Conductor.songPosition)
			{
				note.alpha = 0.4;
				if (note.strumTime > lastConductorPos && FlxG.sound.music.playing && note.lane > -1)
				{
					var data:Int = note.lane % 4;
					var laneToCheck:Int = note.lane;
					if (laneToCheck > -1 && note.mustPress != _song.sections[curSec].mustHitSection)
						laneToCheck += 4;
					strumLineNotes.members[laneToCheck].pressed = true;
					if (!playedSound[data])
					{
						if ((playSoundBf.checked && note.mustPress) || (playSoundDad.checked && !note.mustPress))
						{
							FlxG.sound.play(Paths.sound('hitsound')).pan = note.lane < 4 ? -0.3 : 0.3; // does the panning even work atm?
							playedSound[data] = true;
						}

						data = note.lane;
						if (note.mustPress != _song.sections[curSec].mustHitSection)
						{
							data += 4;
						}
					}
				}
			}
		});

		if (metronome.checked && lastConductorPos != Conductor.songPosition)
		{
			var metroInterval:Float = 60 / metronomeStepper.value;
			var metroStep:Int = Math.floor(((Conductor.songPosition + metronomeOffsetStepper.value) / metroInterval) * 0.001);
			var lastMetroStep:Int = Math.floor(((lastConductorPos + metronomeOffsetStepper.value) / metroInterval) * 0.001);
			if (metroStep != lastMetroStep)
			{
				FlxG.sound.play(Paths.sound('Metronome_Tick'));
				// trace('Ticked');
			}
		}
		lastConductorPos = Conductor.songPosition;
		super.update(elapsed);
	}

	function pauseAndSetVocalsTime()
	{
		if (vocals != null)
		{
			vocals.pause();
			vocals.time = FlxG.sound.music.time;
		}
	}

	function updateZoom()
	{
		zoomTxt = 'Zoom: ${zoomList[curZoom]}x';
		reloadGridLayer();
	}

	var lastSecBeats:Float = 0;
	var lastSecBeatsNext:Float = 0;
	var columns:Int = 9;

	function reloadGridLayer()
	{
		gridLayer.clear();
		gridBG = FlxGridOverlay.create(1, 1, columns, Std.int(getSectionBeats() * 4 * zoomList[curZoom]));
		gridBG.antialiasing = false;
		gridBG.scale.set(GRID_SIZE, GRID_SIZE);
		gridBG.updateHitbox();

		#if desktop
		if (FlxG.save.data.chart_waveformInst || FlxG.save.data.chart_waveformVoices || FlxG.save.data.chart_waveformOppVoices)
		{
			updateWaveform();
		}
		#end

		var leHeight:Int = Std.int(gridBG.height);
		var foundNextSec:Bool = false;
		if (sectionStartTime(1) <= FlxG.sound.music.length)
		{
			nextGridBG = FlxGridOverlay.create(1, 1, columns, Std.int(getSectionBeats(curSec + 1) * 4 * zoomList[curZoom]));
			nextGridBG.antialiasing = false;
			nextGridBG.scale.set(GRID_SIZE, GRID_SIZE);
			nextGridBG.updateHitbox();
			leHeight = Std.int(gridBG.height + nextGridBG.height);
			foundNextSec = true;
		}
		else
			nextGridBG = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
		nextGridBG.y = gridBG.height;

		gridLayer.add(nextGridBG);
		gridLayer.add(gridBG);

		if (foundNextSec)
		{
			var gridBlack:FlxSprite = new FlxSprite(0, gridBG.height).makeGraphic(1, 1, FlxColor.BLACK);
			gridBlack.setGraphicSize(Std.int(GRID_SIZE * 9), Std.int(nextGridBG.height));
			gridBlack.updateHitbox();
			gridBlack.antialiasing = false;
			gridBlack.alpha = 0.4;
			gridLayer.add(gridBlack);
		}

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width - (GRID_SIZE * 4)).makeGraphic(1, 1, FlxColor.BLACK);
		gridBlackLine.setGraphicSize(2, leHeight);
		gridBlackLine.updateHitbox();
		gridBlackLine.antialiasing = false;
		gridLayer.add(gridBlackLine);

		for (i in 1...Std.int(getSectionBeats()))
		{
			var beatsep:FlxSprite = new FlxSprite(gridBG.x, (GRID_SIZE * (4 * zoomList[curZoom])) * i).makeGraphic(1, 1, 0x44FF0000);
			beatsep.scale.x = gridBG.width;
			beatsep.updateHitbox();
			if (vortex)
				gridLayer.add(beatsep);
		}

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + GRID_SIZE).makeGraphic(1, 1, FlxColor.BLACK);
		gridBlackLine.setGraphicSize(2, leHeight);
		gridBlackLine.updateHitbox();
		gridBlackLine.antialiasing = false;
		gridLayer.add(gridBlackLine);
		updateGrid();

		lastSecBeats = getSectionBeats();
		if (sectionStartTime(1) > FlxG.sound.music.length)
			lastSecBeatsNext = 0;
		else
			getSectionBeats(curSec + 1);
	}

	function strumLineUpdateY()
	{
		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) / zoomList[curZoom] % (Conductor.stepCrochet * 16)) / (getSectionBeats() * 0.25);
	}

	var waveformPrinted:Bool = true;
	var wavData:Array<Array<Array<Float>>> = [[[0], [0]], [[0], [0]]];
	var lastWaveformHeight:Int = 0;

	function updateWaveform()
	{
		#if desktop
		if (waveformPrinted)
		{
			var width:Int = Std.int(GRID_SIZE * 8);
			var height:Int = Std.int(gridBG.height);
			if (lastWaveformHeight != height && waveformSprite.pixels != null)
			{
				waveformSprite.pixels.dispose();
				waveformSprite.pixels.disposeImage();
				waveformSprite.makeGraphic(width, height, 0x00FFFFFF);
				lastWaveformHeight = height;
			}
			waveformSprite.pixels.fillRect(new Rectangle(0, 0, width, height), 0x00FFFFFF);
		}
		waveformPrinted = false;

		if (!FlxG.save.data.chart_waveformInst && !FlxG.save.data.chart_waveformVoices)
		{
			// trace('Epic fail on the waveform lol');
			return;
		}

		wavData[0][0] = [];
		wavData[0][1] = [];
		wavData[1][0] = [];
		wavData[1][1] = [];

		var steps:Int = Math.round(getSectionBeats() * 4);
		var st:Float = sectionStartTime();
		var et:Float = st + (Conductor.stepCrochet * steps);

		var sound:FlxSound = FlxG.sound.music;
		if (FlxG.save.data.chart_waveformVoices)
			sound = vocals;

		if (sound != null && sound._sound != null && sound._sound.__buffer != null)
		{
			var bytes:Bytes = sound._sound.__buffer.data.toBytes();

			wavData = waveformData(sound._sound.__buffer, bytes, st, et, 1, wavData, Std.int(gridBG.height));
		}

		// Draws
		var gSize:Int = Std.int(GRID_SIZE * 8);
		var hSize:Int = Std.int(gSize * 0.5);
		var size:Float = 1;

		var leftLength:Int = (wavData[0][0].length > wavData[0][1].length ? wavData[0][0].length : wavData[0][1].length);
		var rightLength:Int = (wavData[1][0].length > wavData[1][1].length ? wavData[1][0].length : wavData[1][1].length);

		var length:Int = leftLength > rightLength ? leftLength : rightLength;

		for (index in 0...length)
		{
			var lmin:Float = FlxMath.bound(((index < wavData[0][0].length && index >= 0) ? wavData[0][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			var lmax:Float = FlxMath.bound(((index < wavData[0][1].length && index >= 0) ? wavData[0][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			var rmin:Float = FlxMath.bound(((index < wavData[1][0].length && index >= 0) ? wavData[1][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			var rmax:Float = FlxMath.bound(((index < wavData[1][1].length && index >= 0) ? wavData[1][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			waveformSprite.pixels.fillRect(new Rectangle(hSize - (lmin + rmin), index * size, (lmin + rmin) + (lmax + rmax), size), FlxColor.BLUE);
		}

		waveformPrinted = true;
		#end
	}

	function waveformData(buffer:AudioBuffer, bytes:Bytes, time:Float, endTime:Float, multiply:Float = 1, ?array:Array<Array<Array<Float>>>,
			?steps:Float):Array<Array<Array<Float>>>
	{
		#if (lime_cffi && !macro)
		if (buffer == null || buffer.data == null)
			return [[[0], [0]], [[0], [0]]];

		var khz:Float = (buffer.sampleRate * 0.001);
		var channels:Int = buffer.channels;

		var index:Int = Std.int(time * khz);

		var samples:Float = ((endTime - time) * khz);

		if (steps == null)
			steps = 1280;

		var samplesPerRow:Float = samples / steps;
		var samplesPerRowI:Int = Std.int(samplesPerRow);

		var gotIndex:Int = 0;

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var rows:Float = 0;

		var simpleSample:Bool = true; // samples > 17200;
		var v1:Bool = false;

		if (array == null)
			array = [[[0], [0]], [[0], [0]]];

		while (index < (bytes.length - 1))
		{
			if (index >= 0)
			{
				var byte:Int = bytes.getUInt16(index * channels * 2);

				if (byte > 65535 * 0.5)
					byte -= 65535;

				var sample:Float = (byte / 65535);

				if (sample > 0)
					if (sample > lmax)
						lmax = sample;
					else if (sample < 0)
						if (sample < lmin)
							lmin = sample;

				if (channels >= 2)
				{
					byte = bytes.getUInt16((index * channels * 2) + 2);

					if (byte > 65535 * 0.5)
						byte -= 65535;

					sample = (byte / 65535);

					if (sample > 0)
					{
						if (sample > rmax)
							rmax = sample;
					}
					else if (sample < 0)
					{
						if (sample < rmin)
							rmin = sample;
					}
				}
			}

			v1 = samplesPerRowI > 0 ? (index % samplesPerRowI == 0) : false;
			while (simpleSample ? v1 : rows >= samplesPerRow)
			{
				v1 = false;
				rows -= samplesPerRow;

				gotIndex++;

				var lRMin:Float = Math.abs(lmin) * multiply;
				var lRMax:Float = lmax * multiply;

				var rRMin:Float = Math.abs(rmin) * multiply;
				var rRMax:Float = rmax * multiply;

				if (gotIndex > array[0][0].length)
					array[0][0].push(lRMin);
				else
					array[0][0][gotIndex - 1] = array[0][0][gotIndex - 1] + lRMin;

				if (gotIndex > array[0][1].length)
					array[0][1].push(lRMax);
				else
					array[0][1][gotIndex - 1] = array[0][1][gotIndex - 1] + lRMax;

				if (channels >= 2)
				{
					if (gotIndex > array[1][0].length)
						array[1][0].push(rRMin);
					else
						array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + rRMin;

					if (gotIndex > array[1][1].length)
						array[1][1].push(rRMax);
					else
						array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + rRMax;
				}
				else
				{
					if (gotIndex > array[1][0].length)
						array[1][0].push(lRMin);
					else
						array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + lRMin;

					if (gotIndex > array[1][1].length)
						array[1][1].push(lRMax);
					else
						array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + lRMax;
				}

				lmin = 0;
				lmax = 0;

				rmin = 0;
				rmax = 0;
			}

			index++;
			rows++;
			if (gotIndex > steps)
				break;
		}

		return array;
		#else
		return [[[0], [0]], [[0], [0]]];
		#end
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += Math.ceil(value);
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps(add:Float = 0):Int
	{
		var lastChange:BPMChangeEvent =
			{
				stepTime: 0,
				songTime: 0,
				bpm: 0
			}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime + add) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		// Basically old changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSec = 0;
		}

		pauseAndSetVocalsTime();
		updateCurStep();

		updateGrid();
		updateSectionUI();
		updateWaveform();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		var waveformChanged:Bool = false;
		if (_song.sections[sec] != null)
		{
			curSec = sec;
			if (updateMusic)
			{
				FlxG.sound.music.pause();

				FlxG.sound.music.time = sectionStartTime();
				pauseAndSetVocalsTime();
				updateCurStep();
			}

			var blah1:Float = getSectionBeats();
			var blah2:Float = getSectionBeats(curSec + 1);
			if (sectionStartTime(1) > FlxG.sound.music.length)
				blah2 = 0;

			if (blah1 != lastSecBeats || blah2 != lastSecBeatsNext)
			{
				reloadGridLayer();
				waveformChanged = true;
			}
			else
			{
				updateGrid();
			}
			updateSectionUI();
		}
		else
		{
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
		if (!waveformChanged)
			updateWaveform();
	}

	function updateSectionUI():Void
	{
		var sec = _song.sections[curSec];

		stepperBeats.value = getSectionBeats();
		check_mustHitSection.checked = sec.mustHitSection;
		check_gfSection.checked = sec.gfSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	var characterData:Dynamic =
		{
			iconP1: null,
			iconP2: null
		};

	function updateJsonData():Void
	{
		var data:CharacterFile = loadCharacterFile(_song.players[0]);
		characterData.iconP1 = !characterFailed ? data.healthicon : 'face';

		var data2:CharacterFile = loadCharacterFile(_song.opponents[0]);
		characterData.iconP2 = !characterFailed ? data2.healthicon : 'face';
	}

	function updateHeads():Void
	{
		if (_song.sections[curSec].mustHitSection)
		{
			leftIcon.changeIcon(characterData.iconP1);
			rightIcon.changeIcon(characterData.iconP2);
			if (_song.sections[curSec].gfSection)
				leftIcon.changeIcon('gf');
		}
		else
		{
			leftIcon.changeIcon(characterData.iconP2);
			rightIcon.changeIcon(characterData.iconP1);
			if (_song.sections[curSec].gfSection)
				leftIcon.changeIcon('gf');
		}
	}

	var characterFailed:Bool = false;

	function loadCharacterFile(char:String):CharacterFile
	{
		characterFailed = false;
		var characterPath:String = 'characters/' + char + '.json';
		var path:String = Paths.getPreloadPath(characterPath);
		if (!OpenFlAssets.exists(path))
		{
			trace(path);
			path = Paths.getPreloadPath('characters/' + Character.DEFAULT_CHARACTER +
				'.json'); // If a character couldn't be found, change him to BF just to prevent a crash
			characterFailed = true;
		}

		var rawJson = OpenFlAssets.getText(path);
		return cast Json.parse(rawJson);
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				stepperSusLength.value = curSelectedNote[2];
			}
			else
			{
				eventDropDown.selectedLabel = curSelectedNote[1][curEventSelected][0];
				var selected:Int = Std.parseInt(eventDropDown.selectedId);
				if (selected > 0 && selected < eventStuff.length)
				{
					descText.text = eventStuff[selected][1];
				}
				value1InputText.text = curSelectedNote[1][curEventSelected][1];
				value2InputText.text = curSelectedNote[1][curEventSelected][2];
			}
			strumTimeInputText.text = '' + curSelectedNote[0];
		}
	}

	function updateGrid():Void
	{
		curRenderedNotes.forEachAlive(function(spr:Note) spr.destroy());
		curRenderedNotes.clear();
		curRenderedSustains.forEachAlive(function(spr:FlxSprite) spr.destroy());
		curRenderedSustains.clear();
		curRenderedEventType.forEachAlive(function(spr:FlxText) spr.destroy());
		curRenderedEventType.clear();
		nextRenderedNotes.forEachAlive(function(spr:Note) spr.destroy());
		nextRenderedNotes.clear();
		nextRenderedSustains.forEachAlive(function(spr:FlxSprite) spr.destroy());
		nextRenderedSustains.clear();

		if (_song.sections[curSec].changeBPM && _song.sections[curSec].bpm > 0)
		{
			Conductor.bpm = _song.sections[curSec].bpm;
			// trace('BPM of this section:');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSec)
				if (_song.sections[i].changeBPM)
					daBPM = _song.sections[i].bpm;
			Conductor.bpm = daBPM;
		}

		// CURRENT SECTION
		var beats:Float = getSectionBeats();
		for (i in _song.sections[curSec].notes)
		{
			var note:Note = setuplane(i, false);
			curRenderedNotes.add(note);
			if (note.sustainLength > 0)
			{
				curRenderedSustains.add(setupSusNote(note, beats));
			}

			note.mustPress = _song.sections[curSec].mustHitSection;
			if (i[1] > 3)
				note.mustPress = !note.mustPress;
		}

		// CURRENT EVENTS
		var startThing:Float = sectionStartTime();
		var endThing:Float = sectionStartTime(1);
		for (i in _song.events)
		{
			if (endThing > i[0] && i[0] >= startThing)
			{
				var note:Note = setuplane(i, false);
				curRenderedNotes.add(note);

				var text:String = 'Event: ' + note.eventName + ' (' + Math.floor(note.strumTime) + ' ms)' + '\nValue 1: ' + note.eventVal1 + '\nValue 2: '
					+ note.eventVal2;
				if (note.eventLength > 1)
					text = note.eventLength + ' Events:\n' + note.eventName;

				var daText:AttachedFlxText = new AttachedFlxText(0, 0, 400, text, 12);
				daText.setFormat(Paths.font("Monocraft.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
				daText.xAdd = -410;
				daText.borderSize = 1;
				if (note.eventLength > 1)
					daText.yAdd += 8;
				daText.sprTracker = note;
				curRenderedEventType.add(daText);
				// trace('test: ' + i[0], 'startThing: ' + startThing, 'endThing: ' + endThing);
			}
		}

		// NEXT SECTION
		var beats:Float = getSectionBeats(1);
		if (curSec < _song.sections.length - 1)
		{
			for (i in _song.sections[curSec + 1].notes)
			{
				var note:Note = setuplane(i, true);
				note.alpha = 0.6;
				nextRenderedNotes.add(note);
				if (note.sustainLength > 0)
				{
					nextRenderedSustains.add(setupSusNote(note, beats));
				}
			}
		}

		// NEXT EVENTS
		var startThing:Float = sectionStartTime(1);
		var endThing:Float = sectionStartTime(2);
		for (i in _song.events)
		{
			if (endThing > i[0] && i[0] >= startThing)
			{
				var note:Note = setuplane(i, true);
				note.alpha = 0.6;
				nextRenderedNotes.add(note);
			}
		}
	}

	function setuplane(i:Array<Dynamic>, isNextSection:Bool):Note
	{
		var daNoteInfo = i[1];
		var daStrumTime = i[0];
		var daSus:Dynamic = i[2];

		var note:Note = new Note(daStrumTime, daNoteInfo % 4, null, null, true);
		if (daSus != null)
		{ // Common note
			if (i.length > 3 && (i[3] == null || i[3].length < 1))
			{
				i.remove(i[3]);
			}
			note.sustainLength = daSus;
		}
		else
		{ // Event note
			note.type = EVENT;
			note.eventName = getEventName(i[1]);
			note.eventLength = i[1].length;
			if (i[1].length < 2)
			{
				note.eventVal1 = i[1][0][1];
				note.eventVal2 = i[1][0][2];
			}
			note.lane = -1;
			daNoteInfo = -1;
		}

		note.setGraphicSize(GRID_SIZE, GRID_SIZE);
		note.updateHitbox();
		note.x = Math.floor(daNoteInfo * GRID_SIZE) + GRID_SIZE;
		if (isNextSection && _song.sections[curSec].mustHitSection != _song.sections[curSec + 1].mustHitSection)
		{
			if (daNoteInfo > 3)
			{
				note.x -= GRID_SIZE * 4;
			}
			else if (daSus != null)
			{
				note.x += GRID_SIZE * 4;
			}
		}

		var beats:Float = getSectionBeats(isNextSection ? 1 : 0);
		note.y = getYfromStrumNotes(daStrumTime - sectionStartTime(), beats);
		// if(isNextSection) note.y += gridBG.height;
		if (note.y < -150)
			note.y = -150;
		return note;
	}

	function getEventName(names:Array<Dynamic>):String
	{
		var retStr:String = '';
		var addedOne:Bool = false;
		for (i in 0...names.length)
		{
			if (addedOne)
				retStr += ', ';
			retStr += names[i][0];
			addedOne = true;
		}
		return retStr;
	}

	function setupSusNote(note:Note, beats:Float):FlxSprite
	{
		var height:Int = Math.floor(FlxMath.remapToRange(note.sustainLength, 0, Conductor.stepCrochet * 16, 0, GRID_SIZE * 16 * zoomList[curZoom])
			+ (GRID_SIZE * zoomList[curZoom])
			- GRID_SIZE * 0.5);
		var minHeight:Int = Std.int((GRID_SIZE * zoomList[curZoom] * 0.5) + GRID_SIZE * 0.5);
		if (height < minHeight)
			height = minHeight;
		if (height < 1)
			height = 1; // Prevents error of invalid height

		var spr:FlxSprite = new FlxSprite(note.x + (GRID_SIZE * 0.5) - 4, note.y + GRID_SIZE * 0.5).makeGraphic(8, height);
		return spr;
	}

	function addSection(beats:Float = 4):Void
	{
		var sec:SwagSection =
			{
				beats: beats,
				bpm: _song.bpm,
				changeBPM: false,
				mustHitSection: true,
				gfSection: false,
				notes: [],
				characterGroup: 0,
				altAnim: false
			};

		_song.sections.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var laneToCheck:Int = note.lane;

		if (laneToCheck > -1)
		{
			if (note.mustPress != _song.sections[curSec].mustHitSection)
				laneToCheck += 4;
			for (i in _song.sections[curSec].notes)
			{
				if (i != curSelectedNote && i.length > 2 && i[0] == note.strumTime && i[1] == laneToCheck)
				{
					curSelectedNote = i;
					break;
				}
			}
		}
		else
		{
			for (i in _song.events)
			{
				if (i != curSelectedNote && i[0] == note.strumTime)
				{
					curSelectedNote = i;
					curEventSelected = Std.int(curSelectedNote[1].length) - 1;
					break;
				}
			}
		}
		changeEventSelected();

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		var laneToCheck:Int = note.lane;
		if (laneToCheck > -1 && note.mustPress != _song.sections[curSec].mustHitSection)
			laneToCheck += 4;

		if (note.lane > -1) // Normal Notes
		{
			for (i in _song.sections[curSec].notes)
			{
				if (i[0] == note.strumTime && i[1] == laneToCheck)
				{
					if (i == curSelectedNote)
						curSelectedNote = null;
					// FlxG.log.add('FOUND EVIL NOTE');
					_song.sections[curSec].notes.remove(i);
					break;
				}
			}
		}
		else // Events
		{
			for (i in _song.events)
			{
				if (i[0] == note.strumTime)
				{
					if (i == curSelectedNote)
					{
						curSelectedNote = null;
						changeEventSelected();
					}
					// FlxG.log.add('FOUND EVIL EVENT');
					_song.events.remove(i);
					break;
				}
			}
		}

		updateGrid();
	}

	public function doANoteThing(cs, d, style)
	{
		var delnote = false;
		if (strumLineNotes.members[d].overlaps(curRenderedNotes))
		{
			curRenderedNotes.forEachAlive(function(note:Note)
			{
				if (note.overlapsPoint(new FlxPoint(strumLineNotes.members[d].x + 1, strumLine.y + 1)) && note.lane == d % 4)
				{
					// trace('tryin to delete note...');
					if (!delnote)
						deleteNote(note);
					delnote = true;
				}
			});
		}

		if (!delnote)
		{
			addNote(cs, d, style);
		}
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.sections.length)
		{
			_song.sections[daSection].notes = [];
		}

		updateGrid();
	}

	function addNote(strum:Null<Float> = null, data:Null<Int> = null, type:Null<Int> = null):Void
	{
		// curUndoIndex++;
		// var newsong = _song.sections;
		//	undos.push(newsong);
		var noteStrum = getStrumTime(dummyArrow.y * (getSectionBeats() * 0.25), false) + sectionStartTime();
		var lane = Math.floor((FlxG.mouse.x - GRID_SIZE) / GRID_SIZE);
		var noteSus = 0;
		var daAlt = false;
		var daType = currentType;

		if (strum != null)
			noteStrum = strum;
		if (data != null)
			lane = data;
		if (type != null)
			daType = type;

		if (lane > -1)
		{
			_song.sections[curSec].notes.push([noteStrum, lane, noteSus]);
			curSelectedNote = _song.sections[curSec].notes[_song.sections[curSec].notes.length - 1];
		}
		else
		{
			var event = eventStuff[Std.parseInt(eventDropDown.selectedId)][0];
			var text1 = value1InputText.text;
			var text2 = value2InputText.text;
			_song.events.push([noteStrum, [[event, text1, text2]]]);
			curSelectedNote = _song.events[_song.events.length - 1];
			curEventSelected = 0;
		}
		changeEventSelected();

		if (FlxG.keys.pressed.CONTROL && lane > -1)
		{
			_song.sections[curSec].notes.push([noteStrum, (lane + 4) % 8, noteSus]);
		}

		// trace(lane + ', ' + noteStrum + ', ' + curSec);
		strumTimeInputText.text = '' + curSelectedNote[0];

		updateGrid();
		updateNoteUI();
	}

	// will figure this out l8r
	function redo()
	{
		// _song = redos[curRedoIndex];
	}

	function undo()
	{
		// redos.push(_song);
		undos.pop();
		// _song.sections = undos[undos.length - 1];
		///trace(_song.sections);
		// updateGrid();
	}

	function getStrumTime(yPos:Float, doZoomCalc:Bool = true):Float
	{
		var leZoom:Float = zoomList[curZoom];
		if (!doZoomCalc)
			leZoom = 1;
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height * leZoom, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float, doZoomCalc:Bool = true):Float
	{
		var leZoom:Float = zoomList[curZoom];
		if (!doZoomCalc)
			leZoom = 1;
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height * leZoom);
	}

	function getYfromStrumNotes(strumTime:Float, beats:Float):Float
	{
		var value:Float = strumTime / (beats * 4 * Conductor.stepCrochet);
		return GRID_SIZE * beats * 4 * zoomList[curZoom] * value + gridBG.y;
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.sections)
		{
			noteData.push(i.notes);
		}

		return noteData;
	}

	var missingText:FlxText;
	var missingTextTimer:FlxTimer;

	function loadJson(song:String):Void
	{
		try
		{
			if (Difficulty.getString() != Difficulty.getDefault())
			{
				if (Difficulty.getString() == null)
				{
					PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
				}
				else
				{
					PlayState.SONG = Song.loadFromJson(song.toLowerCase() + "-" + Difficulty.getString(), song.toLowerCase());
				}
			}
			else
				PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
			FlxG.resetState();
		}
		catch (e)
		{
			trace('ERROR! $e');

			var errorStr:String = e.toString();
			if (errorStr.startsWith('[lime.utils.Assets] ERROR:'))
				errorStr = 'Missing file: '
					+ errorStr.substring(errorStr.indexOf(Paths.formatToSongPath(PlayState.SONG.name)), errorStr.length - 1); // Missing chart

			if (missingText == null)
			{
				missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
				missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				missingText.scrollFactor.set();
				add(missingText);
			}
			else
				missingTextTimer.cancel();

			missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
			missingText.screenCenter(Y);

			missingTextTimer = new FlxTimer().start(5, function(tmr:FlxTimer)
			{
				remove(missingText);
				missingText.destroy();
			});
			FlxG.sound.play(Paths.sound('cancelMenu'), 0.3);
		}
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = haxe.Json.stringify(
			{
				"song": _song
			});
		FlxG.save.flush();
	}

	function clearEvents()
	{
		_song.events = [];
		updateGrid();
	}

	private function saveLevel()
	{
		if (_song.events != null && _song.events.length > 1)
			_song.events.sort(sortByTime);
		var json =
			{
				"song": _song
			};

		var data:String = haxe.Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), Paths.formatToSongPath(_song.name) + ".json");
		}
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	private function saveEvents()
	{
		if (_song.events != null && _song.events.length > 1)
			_song.events.sort(sortByTime);
		var eventsSong:Dynamic =
			{
				events: _song.events
			};
		var json =
			{
				"song": eventsSong
			}

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "events.json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	function getSectionBeats(?section:Null<Int> = null)
	{
		if (section == null)
			section = curSec;
		var val:Null<Float> = null;

		if (_song.sections[section] != null)
			val = _song.sections[section].beats;
		return val != null ? val : 4;
	}
}

class AttachedFlxText extends FlxText
{
	public var sprTracker:FlxSprite;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
	{
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
		{
			setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
			angle = sprTracker.angle;
			alpha = sprTracker.alpha;
		}
	}
}
