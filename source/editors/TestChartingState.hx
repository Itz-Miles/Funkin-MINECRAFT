package editors;

import blockUI.Layer;
import blockUI.Panel;
import flixel.FlxG;

class TestChartingState extends MusicBeatState
{
	static final tabNames:Array<String> = ['song', 'note', 'ctrl'];

	var panelLayers:Array<Layer> = [
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

		var panel:Panel = new Panel(panelLayers);
		add(panel);

		for (i in 0...tabNames.length)
		{
			panel.addLayer(
				{
					x: 480 + (100 * i) + (10 * i),
					y: 70,
					width: 100,
					height: 50,
					color: 0xFFd1d1d1,
				});

			panel.addLayer(
				{
					x: 480 + (100 * i) + (10 * i),
					y: 85,
					width: 100,
					height: 0,
					color: 0x00000000,
					text: tabNames[i],
					font: Paths.font("Minecrafter.ttf"),
					align: CENTER,
					size: Std.int(100 / tabNames[i].length)
				});
		}
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			FlxG.switchState(() -> new FreeplayState());
		}
	}
}
