package editors;

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
		{
			x: 460,
			y: 660,
			width: 770,
			height: 10,
			color: 0xff000000
		},
		{
			x: 460,
			y: 50,
			width: 770,
			height: 610,
			color: 0xff353535
		},
		{
			x: 470,
			y: 60,
			width: 750,
			height: 590,
			color: 0xFF0f0f0f
		},
		{
			x: 470,
			y: 60,
			width: 750,
			height: 10,
			color: 0xff000000
		},
		{
			x: 50,
			y: 50,
			width: 360,
			height: 620,
			color: 0x70000000
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
		var margin = 10;
		var tabWidth = (box[2].width - margin * 2 - (margin * (tabNames.length - 1))) / tabNames.length;

		for (i in 0...tabNames.length)
		{
			uiBox.addLayer(
				{
					x: box[2].x + margin + ((tabWidth + margin) * i),
					y: box[2].y + 50,
					width: tabWidth,
					height: 20,
					color: 0xff5f697a,
				});

			uiBox.addLayer(
				{
					x: box[2].x + margin + ((tabWidth + margin) * i),
					y: box[2].y + 10,
					width: tabWidth,
					height: 50,
					color: 0xFFcedae4,
					onPush: function(obj)
					{
						for (i in 0...uiBox.buttons.length)
						{
							if (uiBox.buttons[i] != obj)
							{
								uiBox.buttonStates[i] = RELEASED;
								uiBox.onRelease[i]();
							}
						}

						FlxTween.completeTweensOf(obj);
						FlxTween.completeTweensOf(uiBox.fields[i]);
						FlxTween.color(obj, 0.1, obj.color, FlxColor.GREEN);
						FlxTween.color(uiBox.fields[i], 0.1, uiBox.fields[i].color, FlxColor.WHITE);
						FlxTween.tween(obj.offset, {y: -30}, 0.1);
						FlxTween.tween(uiBox.fields[i].offset, {y: -5}, 0.1);
					},
					onHover: function(obj)
					{
						FlxTween.completeTweensOf(obj);
						FlxTween.completeTweensOf(uiBox.fields[i]);
						FlxTween.tween(obj.offset, {y: -23}, 0.1);
						FlxTween.tween(uiBox.fields[i].offset, {y: 2}, 0.1);
					},
					onRelease: function(obj)
					{
						FlxTween.completeTweensOf(obj);
						FlxTween.completeTweensOf(uiBox.fields[i]);
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
				});

			uiBox.addLayer(
				{
					x: box[2].x + margin + ((tabWidth + margin) * i),
					y: box[2].y + 25,
					width: tabWidth,
					height: 0,
					color: 0xFFFFFFFF,
					text: tabNames[i],
					font: Paths.font("Minecrafter.ttf"),
					align: CENTER,
					size: Std.int(Math.min((tabWidth / tabNames[i].length), 28))
				});
		}
		uiBox.runAcrossLayers(0);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls.BACK)
		{
			FlxG.switchState(() -> new FreeplayState());
		}
	}
}
