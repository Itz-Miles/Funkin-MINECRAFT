package objects;

import flixel.util.FlxColor;
import openfl.Assets;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

enum InputDirection
{
	RIGHT;
	LEFT;
	UP;
	DOWN;
	NEUTRAL;
}

enum CharacterStatus
{
	ATTACKING;
	TAUNTING;
	SINGING;
	BUILDING;
	CRAFTING;
	IDLING;
	STUNNED;
	DEAD;
	SPECIAL;
}

typedef CharacterFile =
{
	var ?moves:Bool;
	var ?drag:Array<Int>;
	var ?velocity:Array<Int>;
	var ?maxVelocity:Array<Int>;
	var animations:Array<AnimArray>;
	var image:String;
	var ?namePlate:String;
	var ?color:String;
	var ?zoom:Float;
	var ?scroll_factor:Array<Float>;
	var ?ui_scale:Float;
	var ?scale:Float;
	var ?sing_duration:Float;
	var ?healthicon:String;
	var ?s_xy:Array<Float>;
	var ?c_xy:Array<Int>;
	var ?facing_right:Bool; // left img = false, right img = true
	var ?antialiasing:Bool;
	var ?health:Float;
	var ?rage:Float;
	var ?nerve:Float;
	var ?pride:Float;
	/*var ?hope:Float;*/
}

typedef AnimArray =
{
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	/**
	 * A list of the character files found in the filesystem.
	 */
	public static var charactersList:Array<String> = [];

	public var status(default, set):CharacterStatus = IDLING;

	function set_status(value:CharacterStatus)
	{
		switch (value)
		{
			case ATTACKING:
				FlxTween.color(this, 0.25, (color * 0xFFe6726a), intendedColor, {ease: FlxEase.quadInOut}); // change later
			case TAUNTING:
			case SINGING:
			case BUILDING:
			case CRAFTING:
			case IDLING:
			case STUNNED:
				FlxTween.color(this, 0.25, (color * 0xFFe6726a), intendedColor, {ease: FlxEase.quadInOut});
			case DEAD:
				origin.y = height * 2;
				y -= height * 0.5;
				FlxG.sound.play(Paths.sound('fnf_loss_sfx'), 1);
				FlxTween.angle(this, 0, 90, 1, {ease: FlxEase.quadInOut});
				color.alphaFloat = 1;
				FlxTween.color(this, 1, color, (color * 0xFFe6726a),
					{
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							kill();
						}
					});
			case SPECIAL:
		}
		return status = value;
	}

	/**
	 * The internal float used to track how long a status should be active for.
	 */
	var statusTimer(default, set):Float = 0;

	function set_statusTimer(value:Float)
	{
		if (value < 0)
			status = IDLING;
		return statusTimer = value;
	}

	/**
	 * The internal float used to determine how long the character SINGs for.
	 */
	var singDuration:Float = 0.4;

	var intendedColor:FlxColor;

	/**
	 * The character's health stat.
	 */
	public var health(default, set):Float = 20;

	function set_health(value:Float)
	{
		if (value <= 0)
		{
			if (isPlayer && ClientPrefs.data.totems > 0)
			{
				FlxG.sound.play(Paths.sound('pop'), 1);
				ClientPrefs.data.totems--;
				trace('You were saved by a totem! ${ClientPrefs.data.totems} totems left.');
				return health = 20;
			}
			status = DEAD;
		}

		return health = value;
	}

	/**
	 * The character's attack. Strong against nerve; weak against pride.
	 */
	public var rage:Float = 1;

	/**
	 * The character's energy. Strong against pride; weak against rage.
	 */
	public var nerve:Float = 1;

	/**
	 * The character's defense. Strong against rage; weak against nerve.
	 */
	public var pride:Float = 1;

	/**
	 * Stats may be different but the message is the same
	 */
	/**
	 * The map for the character's animation offsets.
	 */
	public var animOffsets:Map<String, Array<Int>>;

	public var cameraOffsets:Array<Int> = [0, 0];

	/**
	 * Whether the player can be controlled by inputs or scripting.
	 */
	public var isPlayer:Bool = false;

	/**
	 * The key for the character's currently loaded json/frame data.
	 */
	public var character(default, set):String = DEFAULT_CHARACTER;

	/**
	 * The animation suffix for the character's idle.
	 */
	public var idleSuffix(default, set):String = '';

	/**
	 * Wether to use "danceLeft" and "danceRight".
	 */
	public var danceIdle:Bool = false;

	public var idleFrequency:Int = 2;
	public var healthIcon:String = 'face';

	public var hasMissAnimations:Bool = false;

	var settingUp:Bool = true;

	public static var DEFAULT_CHARACTER:String = 'bf_arch';

	public var dancedLeft:Bool = false;
	public var zoom:Float = 1.0;

	override function set_x(value:Float)
	{
		return x = value;
	}

	override function set_y(value:Float)
	{
		return y = value;
	}

	public function new(x:Float, y:Float, ?character:String = 'bf_arch', ?library:String = "shared")
	{
		super(x, y);

		animOffsets = new Map();

		this.character = character;
	}

	function set_character(char:String)
	{
		switch (char)
		{
			default:
				var path:String = Paths.getPreloadPath('characters/${char}.json');
				if (!Assets.exists(path))
				{
					path = Paths.getPreloadPath('characters/${DEFAULT_CHARACTER}.json');
				}

				var json:CharacterFile = cast Json.parse(Assets.getText(path));

				frames = Paths.getSparrowAtlas(json.image, "shared");

				if (json.scale != null)
				{
					setGraphicSize(Std.int(width * json.scale));
					updateHitbox();
				}

				if (json.scroll_factor != null)
					scrollFactor.set(json.scroll_factor[0], json.scroll_factor[1]);

				if (x == 0 && y == 0 && json.s_xy != null)
					setPosition(json.s_xy[0], json.s_xy[1]);

				setFacingFlip(RIGHT, (json.facing_right == null ? false : !json.facing_right), false);
				setFacingFlip(LEFT, (json.facing_right == null ? true : json.facing_right), false);

				if (json.color != null)
					color = FlxColor.fromString(json.color);
				color.alphaFloat = 1;
				intendedColor = color;

				if (json.zoom != null)
					zoom = json.zoom;

				moves = false;
				if (json.moves != null)
					moves = json.moves;
				health = 20;
				if (json.health != null)
					health = json.health;
				if (json.rage != null)
					rage = json.rage;
				if (json.nerve != null)
					nerve = json.nerve;
				if (json.pride != null)
					pride = json.health;
				/*
					if (json.hope != null)
						hope = json.hope;
				 */

				if (json.c_xy != null)
					cameraOffsets = json.c_xy;

				if (json.healthicon != null)
					healthIcon = json.healthicon;

				if (json.sing_duration != null)
					singDuration = json.sing_duration;

				antialiasing = ClientPrefs.data.antialiasing;
				if (json.antialiasing != null)
				{
					antialiasing = json.antialiasing;
				}

				if (json.animations != null && json.animations.length > 0)
				{
					for (anim in json.animations)
					{
						anim.anim += '';
						anim.name += '';
						if (anim.indices != null && anim.indices.length > 0)
						{
							animation.addByIndices(anim.anim, anim.name, anim.indices, "", anim.fps, anim.loop);
						}
						else
						{
							animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);
						}

						if (anim.offsets != null && anim.offsets.length > 1)
						{
							addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
						}
					}
				}

				if (animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss') || animOffsets.exists('singUPmiss')
					|| animOffsets.exists('singRIGHTmiss'))
					hasMissAnimations = true;
				recalculateDanceIdle();
				dance();
		}
		return character = char;
	}

	function set_idleSuffix(suffix:String)
	{
		if (idleSuffix != suffix)
			recalculateDanceIdle();
		return idleSuffix = suffix;
	}

	override function update(elapsed:Float)
	{
		if (statusTimer > 0)
			statusTimer -= 1.0 * elapsed;
		super.update(elapsed);
	}

	public function attack()
	{
		status = ATTACKING;
		statusTimer = 0.25;
	}

	public function build()
	{
		status = BUILDING;
	}

	public function taunt()
	{
		status = TAUNTING;
	}

	public function craft()
	{
		status = CRAFTING;
	}

	public function sing(?duration:Float)
	{
		if (duration != null)
			statusTimer = duration;
		else
			statusTimer = singDuration;

		status = SINGING;
	}

	public function miss()
	{
		status = STUNNED;
	}

	public function jump()
	{
		y -= height;
	}

	public function beatHit(curBeat:Float):Void
	{
		if (status == IDLING)
		{
			if (curBeat % idleFrequency == 0)
				dance();
		}
		else if (status == STUNNED)
		{
			if (curBeat % 2 == 0)
				FlxTween.color(this, 0.25, (color * 0xff6a6ce6), intendedColor, {ease: FlxEase.quadInOut});
		}
	}

	public function sectionHit():Void
	{
	}

	public function dance(?force:Bool = true)
	{
		if (danceIdle)
		{
			dancedLeft = !dancedLeft;

			if (dancedLeft)
				playAnim('danceRight' + idleSuffix);
			else
				playAnim('danceLeft' + idleSuffix);
		}
		else if (animation.getByName('idle' + idleSuffix) != null)
		{
			playAnim('idle' + idleSuffix, force);
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0] * scale.x, daOffset[1] * scale.x);
		}
		else
			offset.set(0, 0);

		if (danceIdle)
		{
			if (AnimName == 'singLEFT')
			{
				dancedLeft = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				dancedLeft = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				dancedLeft = !dancedLeft;
			}
		}
	}

	function recalculateDanceIdle()
	{
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);

		if (settingUp)
		{
			idleFrequency = (danceIdle ? 1 : 2);
		}
		else if (lastDanceIdle != danceIdle)
		{
			var calc:Float = idleFrequency;
			if (danceIdle)
				calc /= 2;
			else
				calc *= 2;

			idleFrequency = Math.round(Math.max(calc, 1));
		}
		settingUp = false;
	}

	public function addOffset(name:String, x:Int = 0, y:Int = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function hey(time:Float):Void
	{
		if (Math.isNaN(time) || time <= 0)
			time = 0.6;
		playAnim('hey', true);
	}
}
