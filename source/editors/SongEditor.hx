package editors;

import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import blockUI.Layer;
import blockUI.Panel;
import flixel.FlxG;

class SongEditor extends Menu
{
	public static var GRID_SIZE:Int = 40;
	static final tabNames:Array<String> = ['song', 'note', 'event', 'ctrl', 'info', 'auto'];

	// UI colors
	var BTN_RIM:Int = 0xff5f697a;
	var BTN_FACE:Int = 0xffcedae4;

	// margin
	static var margin = 10;

	// UI VARIABLES
	var songName:String = "stalstruck";
	var songAuthor:String = "It'z Miles";

	// PANELS
	var tabs:Array<Panel>;

	var box:Array<Layer> = [
		{ // bottom
			x: 510,
			y: 660,
			width: 720,
			height: 10,
			color: 0xff000000
		},
		{ // border
			x: 510,
			y: 50,
			width: 720,
			height: 610,
			color: 0xff353535
		},
		{ // content
			x: 520,
			y: 60,
			width: 700,
			height: 590,
			color: 0xFF0f0f0f
		},
		{ // content top shadow
			x: 520,
			y: 60,
			width: 700,
			height: 10,
			color: 0xff000000
		},
		{
			x: 520 + margin,
			y: 140,
			width: 700 - margin * 2,
			height: 520 - margin * 2,
			color: 0xFF454545
		}
	];

	var uiBox:Panel;

	override function create()
	{
		super.create();
		Paths.clearUnusedMemory();

		uiBox = new Panel(box);
		add(uiBox);

		tabs = new Array<Panel>();

		var tabWidth = (box[2].width - margin * 2 - (margin * (tabNames.length - 1))) / tabNames.length;

		for (i in 0...tabNames.length)
		{
			uiBox.addLayers([
				{
					x: box[2].x + margin + ((tabWidth + margin) * i),
					y: box[2].y + 50,
					width: tabWidth,
					height: 20,
					color: BTN_RIM,
				},
				{
					x: box[2].x + margin + ((tabWidth + margin) * i),
					y: box[2].y + 10,
					width: tabWidth,
					height: 50,
					color: BTN_FACE,
					onPush: function(obj)
					{
						for (button in uiBox.buttons)
						{
							if (button.sprite != obj.sprite)
							{
								if (button.state != RELEASED)
								{
									button.state = RELEASED;
									button.onRelease();
								}
							}
							else
							{
								tabs[i].visible = tabs[i].active = true;
							}
						}

						FlxTween.completeTweensOf(uiBox.sprites[box.length + i * 2]);
						FlxTween.completeTweensOf(obj);
						FlxTween.completeTweensOf(uiBox.fields[i]);
						FlxTween.color(uiBox.sprites[box.length + i * 2], 0.1, uiBox.sprites[box.length + i * 2].color, 0xFF44BD44);
						FlxTween.color(obj.sprite, 0.1, obj.sprite.color, FlxColor.GREEN);
						FlxTween.color(uiBox.fields[i], 0.1, uiBox.fields[i].color, FlxColor.WHITE);
						FlxTween.tween(obj.sprite.offset, {y: -30}, 0.1);
						FlxTween.tween(uiBox.fields[i].offset, {y: -5}, 0.1);
					},
					onHover: function(obj)
					{
						FlxTween.completeTweensOf(uiBox.sprites[box.length + i * 2]);
						FlxTween.completeTweensOf(obj);
						FlxTween.completeTweensOf(uiBox.fields[i]);
						FlxTween.tween(obj.sprite.offset, {y: -23}, 0.1);
						FlxTween.tween(uiBox.fields[i].offset, {y: 2}, 0.1);
					},
					onRelease: function(obj)
					{
						tabs[i].visible = tabs[i].active = false;
						FlxTween.completeTweensOf(uiBox.sprites[box.length + i * 2]);
						FlxTween.completeTweensOf(obj);
						FlxTween.completeTweensOf(uiBox.fields[i]);
						FlxTween.color(uiBox.sprites[box.length + i * 2], 0.1, uiBox.sprites[box.length + i * 2].color, FlxColor.WHITE);
						FlxTween.color(obj.sprite, 0.1, obj.sprite.color, FlxColor.WHITE);
						FlxTween.color(uiBox.fields[i], 0.1, uiBox.fields[i].color, FlxColor.BLACK);
						FlxTween.tween(obj.sprite.offset, {y: -25}, 0.1);
						FlxTween.tween(uiBox.fields[i].offset, {y: 0}, 0.1);
					},
					_functions: [
						function(obj)
						{
							obj.sprite.color = FlxColor.WHITE;
							uiBox.fields[i].color = FlxColor.BLACK;
							FlxTween.tween(obj.sprite.offset, {y: -25}, 0.1);
							FlxTween.tween(uiBox.fields[i].offset, {y: 0}, 0.1);
						},
					]
				},
				{
					x: box[2].x + margin + ((tabWidth + margin) * i),
					y: box[2].y + 25,
					width: tabWidth,
					height: 0,
					color: 0xFFFFFFFF,
					text: tabNames[i],
					font: Paths.font("Minecrafter.ttf"),
					align: CENTER,
					size: Std.int(Math.min((tabWidth / tabNames[i].length * 1.1), 28))
				}
			]);

			var tab:Panel = new Panel();

			add(tab);
			tab.visible = false;
			tabs.push(tab);
		}
		tabs[0].addLayers([
			{
				x: box[4].x + margin * 2,
				y: box[4].y + margin * 2,
				width: (box[4].width / 3) - margin,
				height: 36,
				text: songName,
				onChange: function(obj)
				{
					songName = obj.text;
					trace("Song name changed to: " + songName);
				},
				font: Paths.font("Monocraft.ttf"),
				color: 0xFFFFFFFF,
				size: 24
			},
			{
				x: box[4].x + margin * 2,
				y: box[4].y + margin * 5 + 36,
				width: (box[4].width / 3) - margin,
				height: 36,
				text: songAuthor,
				onChange: function(obj)
				{
					songAuthor = obj.text;
					trace("Song author changed to: " + songAuthor);
				},
				font: Paths.font("Monocraft.ttf"),
				color: 0xFFFFFFFF,
				size: 24
			},
		]);
		tabs[3].addLayer(
			{
				x: box[2].x + margin * 4,
				y: box[2].y + 100,
				width: box[2].width,
				height: box[2].height,
				color: 0xffffffff,
				font: Paths.font("Monocraft.ttf"),
				align: LEFT,
				text: "W/S, Up/Down, Wheel - Set Conductor's time
				A/D - Seek Previous/Next Section
				Left/Right - Change Selection Snap
				[ / ] - Change Playback Rate + ALT to Reset
				CRTL + Click - Select Arrow
				Z/X - Zoom in/out
				Shift - 4x Faster Actions
				Enter - Play your chart
				Q/E - Decrease/Increase Note Sustain Length
				Space - Stop/Resume song",
				size: 18
			});

		tabs[4].addLayer(
			{
				x: box[2].x + margin * 2,
				y: box[2].y + 90,
				width: box[2].width - margin * 2,
				height: box[2].height - margin * 2,
				color: 0xffffffff,
				font: Paths.font("Monocraft.ttf"),
				align: LEFT,
				text: "Time: 100.00 / 100.00
				Section: 50 / 100
				Beat: 200 / 400
				Step: 800 / 1600
				Beat Snap: 16th
				Zoom: 1.0x",
				size: 20,
			});
		// autosave panel, five long boxes with save data (dummy)

		for (i in 1...6)
		{
			tabs[5].addLayers([
				{
					x: box[2].x + margin * 2,
					y: box[2].y + 90 + ((box[2].height - 100) / 5) * (i - 1),
					width: box[2].width - margin * 5 - 100,
					height: (box[2].height - 100) / 5 - margin,
					color: 0xff505050
				},
				{
					x: box[2].x + margin * 4,
					y: box[2].y + 100 + ((box[2].height - 100) / 5) * (i - 1),
					width: box[2].width - margin * 5 - 100,
					height: (box[2].height - 100) / 5 - margin,
					color: 0xffdcdcdc,
					font: Paths.font("Monocraft.ttf"),
					align: LEFT,
					text: "Autosave Slot " + i + "\nSong: " + songName,
					size: 26
				},
				{
					x: box[2].x + box[2].width - margin * 2 - 100,
					y: box[2].y + 90 + ((box[2].height - 100) / 5) * (i - 1),
					width: 100,
					height: ((box[2].height - 100) / 5 - margin) / 2 - margin / 2,
					color: 0xff637a5f,
				},
				{
					x: box[2].x + box[2].width - margin * 2 - 100,
					y: box[2].y + 140 + ((box[2].height - 100) / 5) * (i - 1),
					width: 100,
					height: ((box[2].height - 100) / 5 - margin) / 2 - margin / 2,
					color: 0xffa83232,
				},
				{
					x: box[2].x + box[2].width - margin * 2 - 100,
					y: box[2].y + 90 + ((box[2].height - 100) / 5) * (i - 1),
					width: 100,
					height: ((box[2].height - 100) / 5 - margin) / 2 - margin / 2,
					color: 0xff44BD44,
					font: Paths.font("Monocraft.ttf"),
					align: CENTER,
					text: "Load",
					size: 20
				},
				{
					x: box[2].x + box[2].width - margin * 2 - 100,
					y: box[2].y + 140 + ((box[2].height - 100) / 5) * (i - 1),
					width: 100,
					height: ((box[2].height - 100) / 5 - margin) / 2 - margin / 2,
					color: 0xffFF4444,
					font: Paths.font("Monocraft.ttf"),
					align: CENTER,
					text: "Erase",
					size: 20
				}
			]);
		}
	}

	override public function refresh()
	{
		bg.alpha = 0.5;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		for (tab in tabs)
		{
			tab.runAcrossLayers(0);
		}

		uiBox.runAcrossLayers(0);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (Controls.BACK)
		{
			FlxG.sound.playMusic(Paths.music('where_are_we_going'));
			Menu.switchTo(ModEditor);
		}
	}
}
