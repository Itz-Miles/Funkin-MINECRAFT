package options;

import blockUI.LayerData;
import blockUI.Panel;
import openfl.display.BlendMode;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import InputFormatter;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

class ControlsSubState extends MusicBeatSubstate
{
	var curSelected:Int = 0;
	var curAlt:Bool = false;

	// Show on gamepad - Display name - Save file key - Rebind display name
	var options:Array<Dynamic> = [
		[true, 'MOVEMENT'],
		[true, 'Left', 'note_left', 'Left'],
		[true, 'Down', 'note_down', 'Down'],
		[true, 'Up', 'note_up', 'Up'],
		[true, 'Right', 'note_right', 'Right'],
		[true, 'Jump', 'jump', 'Jump'],
		[true, 'Taunt', 'taunt', 'Taunt'],
		[true, 'Attack', 'attack', 'Attack (button)'],
		[true],
		[true, 'UI'],
		[true, 'Left', 'ui_left', 'UI Left'],
		[true, 'Down', 'ui_down', 'UI Down'],
		[true, 'Up', 'ui_up', 'UI Up'],
		[true, 'Right', 'ui_right', 'UI Right'],
		[true],
		[true, 'Reset', 'reset', 'Reset'],
		[true, 'Accept', 'accept', 'Accept'],
		[true, 'Back', 'back', 'Back'],
		[true, 'Pause', 'pause', 'Pause'],
		[false],
		[false, 'VOLUME'],
		[false, 'Mute', 'volume_mute', 'Volume Mute'],
		[false, 'Up', 'volume_up', 'Volume Up'],
		[false, 'Down', 'volume_down', 'Volume Down'],
		[false]
	];
	var curOptions:Array<Int>;
	var curOptionsValid:Array<Int>;

	static var defaultKey:String = 'Reset to Default Keys';

	var grpDisplay:FlxTypedGroup<Alphabet>;
	var grpBlacks:FlxTypedGroup<AttachedSprite>;
	var grpOptions:FlxTypedGroup<Alphabet>;
	var grpBinds:FlxTypedGroup<Alphabet>;
	var selectSpr:AttachedSprite;

	var onKeyboardMode:Bool = true;

	var controllerSpr:FlxSprite;

	public function new()
	{
		super();

		options.push([true]);
		options.push([true, defaultKey]);

		grpDisplay = new FlxTypedGroup<Alphabet>();
		add(grpDisplay);
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);
		grpBlacks = new FlxTypedGroup<AttachedSprite>();
		add(grpBlacks);
		selectSpr = new AttachedSprite();
		selectSpr.makeGraphic(250, 78, FlxColor.WHITE);
		selectSpr.copyAlpha = false;
		selectSpr.alpha = 0.75;
		add(selectSpr);
		grpBinds = new FlxTypedGroup<Alphabet>();
		add(grpBinds);

		var header:Panel = new Panel(LayerData.HEADER);
		header.text = "bind your controls     ";
		header.onClick[0] = function()
		{
			close();
		};
		controllerSpr = new FlxSprite(845, 9).loadGraphic(Paths.image('settings/controller_type', "shared"), true, 18, 0);
		controllerSpr.antialiasing = false;
		controllerSpr.animation.add('keyboard', [0], 1, false);
		controllerSpr.animation.add('gamepad', [1], 1, false);
		controllerSpr.setGraphicSize(60);
		controllerSpr.updateHitbox();
		header.add(controllerSpr);

		header.runAcrossLayers(2);
		add(header);

		createTexts();
	}

	var lastID:Int = 0;

	function createTexts()
	{
		curOptions = [];
		curOptionsValid = [];
		grpDisplay.forEachAlive(function(text:Alphabet) text.destroy());
		grpBlacks.forEachAlive(function(black:AttachedSprite) black.destroy());
		grpOptions.forEachAlive(function(text:Alphabet) text.destroy());
		grpBinds.forEachAlive(function(text:Alphabet) text.destroy());
		grpDisplay.clear();
		grpBlacks.clear();
		grpOptions.clear();
		grpBinds.clear();

		var myID:Int = 0;
		for (i in 0...options.length)
		{
			var option:Array<Dynamic> = options[i];
			if (option[0] || onKeyboardMode)
			{
				if (option.length > 1)
				{
					var isCentered:Bool = (option.length < 3);
					var isDefaultKey:Bool = (option[1] == defaultKey);
					var isDisplayKey:Bool = (isCentered && !isDefaultKey);

					var text:Alphabet = new Alphabet(60, 375, option[1], !isDisplayKey);
					text.isMenuItem = true;
					text.changeX = false;
					text.distancePerItem.y = 60;
					text.targetY = myID;
					if (isDisplayKey)
						grpDisplay.add(text);
					else
					{
						grpOptions.add(text);
						curOptions.push(i);
						curOptionsValid.push(myID);
					}
					text.ID = myID;
					lastID = myID;

					if (isCentered)
						addCenteredText(text, option, myID);
					else
						addKeyText(text, option, myID);

					text.snapToPosition();
					text.y += 720 * 2;
				}
				myID++;
			}
		}
		updateText();
	}

	function addCenteredText(text:Alphabet, option:Array<Dynamic>, id:Int)
	{
		text.screenCenter(X);
		text.y -= 25;
		text.startPosition.y -= 25;
		if (text.text == defaultKey)
			text.startPosition.y -= 50;
	}

	function addKeyText(text:Alphabet, option:Array<Dynamic>, id:Int)
	{
		for (n in 0...2)
		{
			var textX:Float = 610 + n * 300;

			var key:String = null;
			if (onKeyboardMode)
			{
				var savKey:Array<Null<FlxKey>> = ClientPrefs.keyBinds.get(option[2]);
				key = InputFormatter.getKeyName((savKey[n] != null) ? savKey[n] : NONE);
			}
			else
			{
				var savKey:Array<Null<FlxGamepadInputID>> = ClientPrefs.gamepadBinds.get(option[2]);
				key = InputFormatter.getGamepadName((savKey[n] != null) ? savKey[n] : NONE);
			}

			var attach:Alphabet = new Alphabet(textX + 70, 375, key, false);
			attach.isMenuItem = true;
			attach.changeX = false;
			attach.distancePerItem.y = 60;
			attach.targetY = text.targetY;
			attach.ID = Math.floor(grpBinds.length * 0.5);
			attach.snapToPosition();
			attach.y += 720 * 2;
			grpBinds.add(attach);

			attach.scale.x = Math.min(1, 230 / attach.width);
			attach.updateHitbox();
			// attach.text = key;

			// spawn black bars at the right of the key name
			var black:AttachedSprite = new AttachedSprite();
			black.makeGraphic(1, 1, FlxColor.BLACK);
			black.setGraphicSize(250, 78);
			black.updateHitbox();
			black.alphaMult = 0.4;
			black.sprTracker = text;
			black.yAdd = -6;
			black.xAdd = textX;
			grpBlacks.add(black);
		}
	}

	function updateBind(num:Int, text:String)
	{
		grpBinds.members[num].text = text;
	}

	var binding:Bool = false;
	var holdingEsc:Float = 0;
	var bindingBlack:FlxSprite;
	var bindingText:Alphabet;
	var bindingText2:Alphabet;

	var timeForMoving:Float = 0.1;

	override function update(elapsed:Float)
	{
		if (timeForMoving > 0) // Fix controller bug
		{
			timeForMoving = Math.max(0, timeForMoving - elapsed);
			super.update(elapsed);
			return;
		}

		if (!binding)
		{
			if (FlxG.keys.justPressed.ESCAPE || FlxG.gamepads.anyJustPressed(B))
			{
				close();
				return;
			}
			if (FlxG.keys.justPressed.CONTROL
				|| FlxG.gamepads.anyJustPressed(LEFT_SHOULDER)
				|| FlxG.gamepads.anyJustPressed(RIGHT_SHOULDER))
				swapMode();

			if (FlxG.keys.justPressed.LEFT
				|| FlxG.keys.justPressed.RIGHT
				|| FlxG.gamepads.anyJustPressed(DPAD_LEFT)
				|| FlxG.gamepads.anyJustPressed(DPAD_RIGHT)
				|| FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_LEFT)
				|| FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_RIGHT))
				updateAlt(true);

			if (FlxG.keys.justPressed.UP
				|| FlxG.gamepads.anyJustPressed(DPAD_UP)
				|| FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_UP)
				|| FlxG.mouse.wheel > 0)
				updateText(-1);
			else if (FlxG.keys.justPressed.DOWN
				|| FlxG.gamepads.anyJustPressed(DPAD_DOWN)
				|| FlxG.gamepads.anyJustPressed(LEFT_STICK_DIGITAL_DOWN)
				|| FlxG.mouse.wheel < 0)
				updateText(1);

			if (FlxG.keys.justPressed.ENTER || FlxG.gamepads.anyJustPressed(START) || FlxG.gamepads.anyJustPressed(A))
			{
				if (options[curOptions[curSelected]][1] != defaultKey)
				{
					bindingBlack = new FlxSprite().makeGraphic(1, 1, FlxG.camera.bgColor);
					bindingBlack.scale.set(1280, 720);
					bindingBlack.updateHitbox();
					bindingBlack.alpha = 0;
					FlxTween.tween(bindingBlack, {alpha: 0.6}, 0.55, {ease: FlxEase.linear});
					add(bindingBlack);

					bindingText = new Alphabet(1280 * 0.5, 160, "Rebinding " + options[curOptions[curSelected]][3], false);
					bindingText.alignment = CENTER;
					bindingText.screenCenter(X);
					add(bindingText);

					bindingText2 = new Alphabet(1280 * 0.5, 340, "Hold ESC to Cancel\nHold Backspace to Delete", true);
					bindingText2.alignment = CENTER;
					bindingText2.screenCenter(X);
					add(bindingText2);

					binding = true;
					holdingEsc = 0;
					ClientPrefs.toggleVolumeKeys(false);
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.3);
				}
				else
				{
					// Reset to Default
					ClientPrefs.resetKeys(!onKeyboardMode);
					ClientPrefs.reloadVolumeKeys();
					createTexts();
					curSelected = 0;
					updateText();
					FlxG.sound.play(Paths.sound('cancelMenu'), 0.3);
				}
			}
		}
		else
		{
			var altNum:Int = curAlt ? 1 : 0;
			var curOption:Array<Dynamic> = options[curOptions[curSelected]];
			if (FlxG.keys.pressed.ESCAPE || FlxG.gamepads.anyPressed(B))
			{
				holdingEsc += elapsed;
				if (holdingEsc > 0.5)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'), 0.3);
					closeBinding();
				}
			}
			else if (FlxG.keys.pressed.BACKSPACE || FlxG.gamepads.anyPressed(BACK))
			{
				holdingEsc += elapsed;
				if (holdingEsc > 0.5)
				{
					ClientPrefs.keyBinds.get(curOption[2])[altNum] = NONE;
					ClientPrefs.clearInvalidKeys(curOption[2]);
					updateBind(Math.floor(curSelected * 2) + altNum, onKeyboardMode ? InputFormatter.getKeyName(NONE) : InputFormatter.getGamepadName(NONE));
					FlxG.sound.play(Paths.sound('cancelMenu'), 0.3);
					closeBinding();
				}
			}
			else
			{
				holdingEsc = 0;
				var changed:Bool = false;
				var curKeys:Array<FlxKey> = ClientPrefs.keyBinds.get(curOption[2]);
				var curButtons:Array<FlxGamepadInputID> = ClientPrefs.gamepadBinds.get(curOption[2]);

				if (onKeyboardMode)
				{
					if (FlxG.keys.justPressed.ANY || FlxG.keys.justReleased.ANY)
					{
						var keyPressed:Int = FlxG.keys.firstJustPressed();
						var keyReleased:Int = FlxG.keys.firstJustReleased();
						if (keyPressed > -1 && keyPressed != FlxKey.ESCAPE && keyPressed != FlxKey.BACKSPACE)
						{
							curKeys[altNum] = keyPressed;
							changed = true;
						}
						else if (keyReleased > -1 && (keyReleased == FlxKey.ESCAPE || keyReleased == FlxKey.BACKSPACE))
						{
							curKeys[altNum] = keyReleased;
							changed = true;
						}
					}
				}
				else if (FlxG.gamepads.anyJustPressed(ANY)
					|| FlxG.gamepads.anyJustPressed(LEFT_TRIGGER)
					|| FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER)
					|| FlxG.gamepads.anyJustReleased(ANY))
				{
					var keyPressed:Null<FlxGamepadInputID> = NONE;
					var keyReleased:Null<FlxGamepadInputID> = NONE;
					if (FlxG.gamepads.anyJustPressed(LEFT_TRIGGER))
						keyPressed = LEFT_TRIGGER; // it wasnt working for some reason
					else if (FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER))
						keyPressed = RIGHT_TRIGGER; // it wasnt working for some reason
					else
					{
						for (i in 0...FlxG.gamepads.numActiveGamepads)
						{
							var gamepad:FlxGamepad = FlxG.gamepads.getByID(i);
							if (gamepad != null)
							{
								keyPressed = gamepad.firstJustPressedID();
								keyReleased = gamepad.firstJustReleasedID();

								if (keyPressed == null)
									keyPressed = NONE;
								if (keyReleased == null)
									keyReleased = NONE;
								if (keyPressed != NONE || keyReleased != NONE)
									break;
							}
						}
					}

					if (keyPressed != NONE && keyPressed != FlxGamepadInputID.BACK && keyPressed != FlxGamepadInputID.B)
					{
						curButtons[altNum] = keyPressed;
						changed = true;
					}
					else if (keyReleased != NONE && (keyReleased == FlxGamepadInputID.BACK || keyReleased == FlxGamepadInputID.B))
					{
						curButtons[altNum] = keyReleased;
						changed = true;
					}
				}

				if (changed)
				{
					if (onKeyboardMode)
					{
						if (curKeys[altNum] == curKeys[1 - altNum])
							curKeys[1 - altNum] = FlxKey.NONE;
					}
					else
					{
						if (curButtons[altNum] == curButtons[1 - altNum])
							curButtons[1 - altNum] = FlxGamepadInputID.NONE;
					}

					var option:String = options[curOptions[curSelected]][2];
					ClientPrefs.clearInvalidKeys(option);
					for (n in 0...2)
					{
						var key:String = null;
						if (onKeyboardMode)
						{
							var savKey:Array<Null<FlxKey>> = ClientPrefs.keyBinds.get(option);
							key = InputFormatter.getKeyName(savKey[n] != null ? savKey[n] : NONE);
						}
						else
						{
							var savKey:Array<Null<FlxGamepadInputID>> = ClientPrefs.gamepadBinds.get(option);
							key = InputFormatter.getGamepadName(savKey[n] != null ? savKey[n] : NONE);
						}
						updateBind(Math.floor(curSelected * 2) + n, key);
					}
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.3);
					closeBinding();
				}
			}
		}
		super.update(elapsed);
	}

	function closeBinding()
	{
		binding = false;
		bindingBlack.destroy();
		remove(bindingBlack);

		bindingText.destroy();
		remove(bindingText);

		bindingText2.destroy();
		remove(bindingText2);
		ClientPrefs.reloadVolumeKeys();
	}

	function updateText(?move:Int = 0)
	{
		if (move != 0)
		{
			// var dir:Int = Math.round(move / Math.abs(move));
			curSelected += move;

			if (curSelected < 0)
				curSelected = curOptions.length - 1;
			else if (curSelected >= curOptions.length)
				curSelected = 0;
		}

		var num:Int = curOptionsValid[curSelected];
		var addNum:Int = 0;
		if (num < 3)
			addNum = 3 - num;
		else if (num > lastID - 4)
			addNum = (lastID - 4) - num;

		grpDisplay.forEachAlive(function(item:Alphabet)
		{
			item.targetY = item.ID - num - addNum;
		});

		grpOptions.forEachAlive(function(item:Alphabet)
		{
			item.targetY = item.ID - num - addNum;
			item.alpha = (item.ID - num == 0) ? 1 : 0.6;
		});
		grpBinds.forEachAlive(function(item:Alphabet)
		{
			var parent:Alphabet = grpOptions.members[item.ID];
			item.targetY = parent.targetY;
			item.alpha = parent.alpha;
		});

		updateAlt();
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.3);
	}

	function swapMode()
	{
		onKeyboardMode = !onKeyboardMode;

		curSelected = 0;
		curAlt = false;
		controllerSpr.animation.play(onKeyboardMode ? 'keyboard' : 'gamepad');
		createTexts();
	}

	function updateAlt(?doSwap:Bool = false)
	{
		if (doSwap)
		{
			curAlt = !curAlt;
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.3);
		}
		selectSpr.sprTracker = grpBlacks.members[Math.floor(curSelected * 2) + (curAlt ? 1 : 0)];
		selectSpr.visible = (selectSpr.sprTracker != null);
	}
}
