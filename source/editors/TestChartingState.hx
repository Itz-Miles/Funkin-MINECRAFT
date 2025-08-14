package editors;

import blockUI.Layer;
import blockUI.Panel;
import flixel.FlxG;

class TestChartingState extends MusicBeatState
{
	static final tabNames:Array<String> = ['song', 'note', 'event', 'ctrl', 'info'];

	var layers:Array<Layer> = [
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

		var panel:Panel = new Panel(layers);
		add(panel);
		var margin = 10;
		var tabWidth = (layers[2].width - margin * 2 - (margin * (tabNames.length - 1))) / tabNames.length;

		for (i in 0...tabNames.length)
		{
			panel.addLayer(
				{
					x: layers[2].x + margin + ((tabWidth + margin) * i),
					y: layers[2].y + 50,
					width: tabWidth,
					height: 20,
					color: 0xff5f697a,
				});

			panel.addLayer(
				{
					x: layers[2].x + margin + ((tabWidth + margin) * i),
					y: layers[2].y + 10,
					width: tabWidth,
					height: 50,
					color: 0xFFcedae4,
					onHover: function(obj)
					{
						obj.offset.y = -30;
						panel.fields[i].offset.y = -5;
					},
					onRelease: function(obj)
					{
						obj.offset.y = -25;
						panel.fields[i].offset.y = 0;
					},
				});

			panel.addLayer(
				{
					x: layers[2].x + margin + ((tabWidth + margin) * i),
					y: layers[2].y + 25,
					width: tabWidth,
					height: 0,
					color: 0x00000000,
					text: tabNames[i],
					font: Paths.font("Minecrafter.ttf"),
					align: CENTER,
					size: Std.int(Math.min((tabWidth / tabNames[i].length), 25))
				});
		}
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
