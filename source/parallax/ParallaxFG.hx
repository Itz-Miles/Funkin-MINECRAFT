package parallax;

import flixel.FlxBasic;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;

/**
 * This FlxGroup contains the foreground elements of a Parallax stage.
 */
class ParallaxFG extends FlxTypedGroup<FlxBasic>
{
	/**
	 * X position of the upper left corner of this group in world space.
	 */
	public var x(default, set):Float = 0;

	/** 
	 * Y position of the upper left corner of this group in world space.
	 */
	public var y(default, set):Float = 0;

	public function new(stage:String = 'aero_archways', scrollMult:Float = 1.0)
	{
		super();
		switch (stage)
		{
			case 'aero_archways':
				if (ClientPrefs.data.particlePercentage > 0)
				{
					var particles:Int = Std.int(ClientPrefs.data.particlePercentage * 200);
					var dustEmitter:FlxEmitter;

					dustEmitter = new FlxEmitter(0, 0, particles);
					dustEmitter.width = FlxG.width;
					dustEmitter.height = FlxG.height;
					dustEmitter.launchMode = SQUARE;
					dustEmitter.alpha.active = false;
					dustEmitter.scale.active = false;
					dustEmitter.angle.active = false;
					dustEmitter.acceleration.active = false;
					dustEmitter.angularAcceleration.active = false;
					dustEmitter.angularVelocity.active = false;
					dustEmitter.angularDrag.active = false;
					dustEmitter.elasticity.active = false;
					dustEmitter.color.active = false;
					dustEmitter.velocity.set(-10, 80, -10, 10);
					dustEmitter.lifespan.set(0);

					for (i in 0...particles)
					{
						var p:FlxParticle = new FlxParticle();
						p.makeGraphic(6, 6, 0xb9ffe6b0);
						p.moves = true;
						p.alpha = Math.random();
						p.scrollFactor.set(p.alpha * scrollMult, p.alpha * scrollMult);
						p.scale.set(p.alpha, p.alpha);
						p.alpha *= 0.7;
						dustEmitter.add(p);
					}

					add(dustEmitter);
					for (i in 0...particles)
						dustEmitter.emitParticle();
					dustEmitter.start(false, 0.1); // add percentage later
				}
				if (ClientPrefs.data.shaders)
				{
					var rays:FlxSprite = new FlxSprite(50, -30, Paths.image('rays', "levels/" + stage));
					rays.scrollFactor.set(0.7 * scrollMult, 0.7 * scrollMult);
					rays.blend = ADD;
					rays.scale.set(1.4, 1.4);
					rays.alpha = 0.3;
					add(rays);
				}

				setPosition(-130, -70);

			case 'camp':
			case 'forge':
			case 'gates':
			case 'rift':
				FlxG.camera.bgColor = 0xff5a0707;
			case 'ruins':
				FlxG.camera.bgColor = 0xff898336;
		}
	}

	public function set_x(value:Float):Float
	{
		for (member in members)
		{
			if (member != null)
			{
				if (Std.isOfType(member, FlxSprite))
				{
					var sprite:FlxSprite = cast member;
					sprite.x -= x;
					sprite.x += value;
				}
				else if (Std.isOfType(member, FlxEmitter))
				{
					var emitter:FlxEmitter = cast member;
					emitter.x -= x;
					emitter.x = value;
				}
			}
		}
		return x = value;
	}

	public function set_y(value:Float):Float
	{
		for (member in members)
		{
			if (member != null)
			{
				if (Std.isOfType(member, FlxSprite))
				{
					var sprite:FlxSprite = cast member;
					sprite.y -= y;
					sprite.y = value;
				}
				else if (Std.isOfType(member, FlxEmitter))
				{
					var emitter:FlxEmitter = cast member;
					emitter.y -= y;
					emitter.y = value;
				}
			}
		}
		return y = value;
	}

	/**
	 * Helper function to set the coordinates of this group.
	 * Handy since it only requires one line of code.
	 *
	 * @param   x   The new x position
	 * @param   y   The new y position
	 */
	public function setPosition(x = 0.0, y = 0.0):Void
	{
		this.x = x;
		this.y = y;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
