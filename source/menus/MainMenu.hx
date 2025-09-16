package menus;

import blockUI.Panel.LayerObject;
#if desktop
import Discord.DiscordClient;
#end
import flixel.math.FlxMath;

class MainMenu extends Menu
{
	var sideBar:Array<Panel> = [];
	var menuBF:Character;
	var menuGF:Character;
	var camFollow:FlxObject;
	var loadedWeeks:Array<WeekData> = [];

	var backed:Bool = false;

	static var labels:Array<String> = ['story mode', 'freeplay', 'settings', 'modpacks', 'credits'];
	public static var curSelection(default, set):Int = 0;
	static var selected:Bool = true;

	override function create()
	{
		Conductor.bpm = 100;

		WeekData.reloadWeekFiles(true);

		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (Menu.previous != Menu.TITLE)
			FlxG.camera.fade(FlxG.camera.bgColor, 0.5, true);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuBF = new Character(660, 180, 'bf_arch', "shared");
		menuBF.scrollFactor.set(0.565789474, 0.565789474);
		add(menuBF);

		menuGF = new Character(410, 222, 'menuGF', "shared");
		menuGF.color = 0x7D7D7B;
		menuGF.scrollFactor.set(0.27741228, 0.27741228);
		add(menuGF);

		for (i in 0...labels.length)
		{
			sideBar.push(new Panel([
				{
					_functions: [
						function(obj)
						{
							obj.sprite.setPosition(-380, 140 + (i * 94) + (i * 10));
							obj.sprite.alpha = 0;
							sideBar[i].fields[0].alpha = 0;
							FlxTween.tween(sideBar[i].fields[0], {alpha: curSelection == i ? 1 : 0.4}, 1.3, {ease: FlxEase.elasticOut, startDelay: 0.4 + (i * 0.1)});

							FlxTween.tween(obj.sprite, {alpha: 1, x: 58}, 1.3,
								{ease: FlxEase.elasticOut,
									startDelay: 0.4 + (i * 0.1),
									onComplete: function(_)
									{
										selected = false;
									}
								});
						},
						function(obj)
						{
							FlxTween.tween(obj.sprite, {alpha: 0, x: -326}, 0.8, {ease: FlxEase.backIn, startDelay: 0.4 - (i * 0.1)});
						},
						function(obj)
						{
							FlxTween.completeTweensOf(obj.sprite);
							if (curSelection != i)
								FlxTween.tween(obj.sprite, {alpha: 0, x: -80}, 0.5, {ease: FlxEase.quintOut});
							else
								FlxTween.tween(obj.sprite, {alpha: 0, x: 180}, 1, {ease: FlxEase.quintIn});
						}
					]
				}
			]));

			sideBar[i].addLayers(LayerData.createButton(labels[i], 0, 0, 340, 84, 6, 12, 0xD32E2E2E, 0x00000000, 0x00000000, function(obj)
			{
				select();
			}, function(obj)
			{
				curSelection = i;
				for (b in 0...sideBar.length)
				{
					if (b != i)
						sideBar[b].buttons[0].onRelease();
				}
				obj.next.sprite.alpha = 1;
			}, function(obj)
			{
				obj.next.sprite.alpha = 0.5;
			}));

			add(sideBar[i]);
		}

		header = new Panel(LayerData.HEADER);
		header.text = "select a submenu";
		add(header);
	}

	override public function refresh()
	{
		selected = true;
		Paths.clearUnusedMemory();
		FlxG.camera.follow(camFollow, NO_DEAD_ZONE, 0.07);

		header.runAcrossLayers(0);

		for (i in 0...sideBar.length)
			sideBar[i].runAcrossLayers(0);

		sideBar[curSelection].buttons[0].onHover();
	}

	@:noCompletion
	static function set_curSelection(value:Int):Int
	{
		if (value > labels.length - 1)
			value = 0;
		if (value < 0)
			value = labels.length - 1;

		if (!selected)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.3);
		}
		return curSelection = value;
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}

		if (!selected)
		{
			if (Controls.UI_UP_P)
			{
				curSelection--;

				sideBar[curSelection].buttons[0].onHover();
			}
			else if (Controls.UI_DOWN_P)
			{
				curSelection++;

				sideBar[curSelection].buttons[0].onHover();
			}

			if (Controls.ACCEPT)
			{
				sideBar[curSelection].buttons[0].onHover();
				sideBar[curSelection].buttons[0].onClick();
			}

			if (Controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.3);
				selected = true;
				backed = true;

				FlxTween.completeTweensOf(header);
				header.runAcrossLayers(1);

				for (i in 0...sideBar.length)
					sideBar[i].runAcrossLayers(1);

				new FlxTimer().start(1.5, function(tmr:FlxTimer)
				{
					selected = false;
					backed = false;
					GameWorld.switchMenu(Menu.TITLE);
				});
			}
		}
		if (backed)
		{
			camFollow.x = 640;
			camFollow.y = 360;
		}
		else
		{
			camFollow.x = 640 + 0.2 * (FlxMath.bound(FlxG.mouse.viewX, 0, 1280) - 640);
			camFollow.y = 360 + 0.2 * (FlxMath.bound(FlxG.mouse.viewY, 0, 720) - 360);
		}
		super.update(elapsed);
	}

	override function beatHit(?curBeat:Int)
	{
		super.beatHit();

		menuGF.dance();
		menuBF.dance(true);
	}

	function select()
	{
		if (selected)
			return;

		selected = true;

		menuGF.hey(1);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.3);

		FlxTween.completeTweensOf(header);
		header.runAcrossLayers(1);

		for (i in 0...sideBar.length)
			sideBar[i].runAcrossLayers(2);

		new FlxTimer().start(0.25, function(tmr:FlxTimer)
		{
			sideBar[curSelection].buttons[0].onHover();
		});

		new FlxTimer().start(1.1, function(tmr:FlxTimer)
		{
			selected = false;
			switch (curSelection)
			{
				case 0:
					GameWorld.switchMenu(Menu.STORY);
				case 1:
					GameWorld.switchMenu(Menu.STORY);
				case 2:
					GameWorld.switchMenu(Menu.STORY);
				case 3:
					GameWorld.switchMenu(Menu.STORY);
				case 4:
					GameWorld.switchMenu(Menu.STORY);
			}
		});
	}
}
