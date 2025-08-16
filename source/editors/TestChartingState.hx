package editors;

import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import blockUI.Layer;
import blockUI.Panel;
import flixel.FlxG;

class TestChartingState extends MusicBeatState
{
	static final tabNames:Array<String> = ['song', 'note', 'event', 'ctrl', 'info'];

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
		}
	];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var uiBox:Panel = new Panel(box);
		add(uiBox);

		tabs = new Array<Panel>();

		var margin = 10;
		var tabWidth = (box[2].width - margin * 2 - (margin * (tabNames.length - 1))) / tabNames.length;

		for (i in 0...tabNames.length)
		{
			uiBox.addLayers([
				{
					x: box[2].x + margin + ((tabWidth + margin) * i),
					y: box[2].y + 50,
					width: tabWidth,
					height: 20,
					color: 0xff5f697a,
				},
				{
					x: box[2].x + margin + ((tabWidth + margin) * i),
					y: box[2].y + 10,
					width: tabWidth,
					height: 50,
					color: 0xFFcedae4,
					onPush: function(obj)
					{
						for (button in uiBox.buttons)
						{
							if (button.sprite != obj)
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
						/* hot potato
							obj.moves = uiBox.fields[i].moves = uiBox.sprites[box.length + i * 2].moves = true;
							obj.velocity.y = uiBox.fields[i].velocity.y = uiBox.sprites[box.length + i * 2].velocity.y  = Math.random() * -250;
							obj.velocity.x = uiBox.fields[i].velocity.x = uiBox.sprites[box.length + i * 2].velocity.x  = Math.random() * -50;
							obj.acceleration.y = uiBox.fields[i].acceleration.y  = uiBox.sprites[box.length + i * 2].acceleration.y = 300;
						 */

						FlxTween.completeTweensOf(uiBox.sprites[box.length + i * 2]);
						FlxTween.completeTweensOf(obj);
						FlxTween.completeTweensOf(uiBox.fields[i]);
						FlxTween.color(uiBox.sprites[box.length + i * 2], 0.1, uiBox.sprites[box.length + i * 2].color, 0xFF44BD44);
						FlxTween.color(obj, 0.1, obj.color, FlxColor.GREEN);
						FlxTween.color(uiBox.fields[i], 0.1, uiBox.fields[i].color, FlxColor.WHITE);
						FlxTween.tween(obj.offset, {y: -30}, 0.1);
						FlxTween.tween(uiBox.fields[i].offset, {y: -5}, 0.1);
					},
					onHover: function(obj)
					{
						FlxTween.completeTweensOf(uiBox.sprites[box.length + i * 2]);
						FlxTween.completeTweensOf(obj);
						FlxTween.completeTweensOf(uiBox.fields[i]);
						FlxTween.tween(obj.offset, {y: -23}, 0.1);
						FlxTween.tween(uiBox.fields[i].offset, {y: 2}, 0.1);
					},
					onRelease: function(obj)
					{
						tabs[i].visible = tabs[i].active = false;
						FlxTween.completeTweensOf(uiBox.sprites[box.length + i * 2]);
						FlxTween.completeTweensOf(obj);
						FlxTween.completeTweensOf(uiBox.fields[i]);
						FlxTween.color(uiBox.sprites[box.length + i * 2], 0.1, uiBox.sprites[box.length + i * 2].color, FlxColor.WHITE);
						FlxTween.color(obj, 0.1, obj.color, FlxColor.WHITE);
						FlxTween.color(uiBox.fields[i], 0.1, uiBox.fields[i].color, FlxColor.BLACK);
						FlxTween.tween(obj.offset, {y: -25}, 0.1);
						FlxTween.tween(uiBox.fields[i].offset, {y: 0}, 0.1);
					},
					_functions: [
						function(obj)
						{
							obj.color = FlxColor.WHITE;
							uiBox.fields[i].color = FlxColor.BLACK;
							FlxTween.tween(obj.offset, {y: -25}, 0.1);
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

			var tab:Panel = new Panel([
				{
					x: box[2].x + margin,
					y: box[2].y + 80,
					width: box[2].width - margin * 2,
					height: box[2].height - margin - 80,
					color: 0xFF353535
				}
			]);

			add(tab);
			tab.visible = false;
			tabs.push(tab);
		}

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

		for (tab in tabs)
		{
			tab.runAcrossLayers(0);
		}

		uiBox.runAcrossLayers(0);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls.BACK)
		{
			FlxG.sound.playMusic(Paths.music('where_are_we_going'));
			FlxG.switchState(() -> new FreeplayState());
		}
	}
}
