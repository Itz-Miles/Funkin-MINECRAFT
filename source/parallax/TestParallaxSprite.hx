#if (flixel >= "5.3.1")
package parallax;

import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.geom.Matrix;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.FlxObject;
import flixel.math.FlxPoint;

/** An enum that determines what transformations are made to the sprite.
 * @param HORIZONTAL   Skews on the x axis, and scales on the y axis.
 * @param VERTICAL     Scales on the x axis, and skews on the y axis.
 */
@enum
enum Direction
{
	HORIZONTAL;
	VERTICAL;
}

/** An enum that determines what happens when this sprite is moved or resized.
 * @param POINT_ONE   `x` and `y` are followed by `x2` and `y2`.
 * @param POINT_TWO   `x2` and `y2` are followed by `x` and `y`.
 * @param NONE        The two positions move indepentendtly of each other.
 */
enum Anchor
{
	POINT_ONE;
	POINT_TWO;
	NONE;
}

/**
 * The FlxParallaxSprite is a FlxSprite extension that performs linear transformations to mimic 3D graphics.
 * @author Itz-Miles
 */
class TestParallaxSprite extends FlxSprite
{
	@:noCompletion
	override function set_x(value:Float):Float
	{
		if (anchor == POINT_ONE)
			x2 -= x - value;
		return x = value;
	}

	@:noCompletion
	override function set_y(value:Float):Float
	{
		if (anchor == POINT_ONE)
			x2 -= x - value;
		return y = value;
	}

	/**
	 * X position of the bottom left corner of this object in world space.
	 */
	public var x2(default, set):Float = 0;

	/**
	 * Y position of the bottom left corner of this object in world space.
	 */
	public var y2(default, set):Float = 0;

	@:noCompletion
	function set_x2(value:Float):Float
	{
		if (anchor == POINT_TWO)
			x -= x2 - value;
		return x2 = value;
	}

	@:noCompletion
	function set_y2(value:Float):Float
	{
		if (anchor == POINT_TWO)
			@:bypassAccessor y -= y2 - value;
		return y2 = value;
	}

	override function set_width(value:Float):Float
	{
		if (anchor == POINT_ONE)
			x2 = x + value;
		if (anchor == POINT_TWO)
			x = x2 - value;
		return width = value;
	}

	override function get_width():Float
	{
		return width = x2 - x;
	}

	override function set_height(value:Float):Float
	{
		y2 = y + value;
		return height = value;
	}

	override function get_height():Float
	{
		return y2 - y;
	}

	/**
	 * Controls how much the bottom left corner of this object is affected by camera scrolling. `0` = no movement (e.g. a background layer),
	 * `1` = same movement speed as the foreground. Default value is `(1,1)`,
	 * except for UI elements like `FlxButton` where it's `(0,0)`.
	 */
	public var scrollFactor2(default, null):FlxPoint;

	/** An enum instance that determines what happens when this sprite is moved or resized.
	 * @param POINT_ONE		`x` and `y` are followed by `x2` and `y2`.
	 * @param POINT_TWO		`x2` and `y2` are followed by `x` and `y`.
	 * @param NONE			The two positions move indepentendtly of eachother.
	 */
	public var anchor:Anchor = POINT_ONE;

	/** An enum instance that determines what transformations are made to the sprite.
	 * @param HORIZONTAL	Skews on the x axis, and scales on the y axis.
	 * @param VERTICAL      Scales on the x axis, and skews on the y axis.
	**/
	public var direction:Direction = HORIZONTAL;

	/**
	 * Internal FlxPoint used to store the screen coordinates of `x` and `y`
	 */
	var _scroll:FlxPoint;

	/**
	 * Internal FlxPoint used to store the screen coordinates of `x2` and `y2`
	 */
	var _scroll2:FlxPoint;

	/**
	 * Creates a FlxParallaxSprite at specified position with a specified graphic.
	 * @param graphic		The graphic to load (uses haxeflixel's default if null)
	 * @param   X			The FlxParallaxSprite's initial X position.
	 * @param   Y			The FlxParllaxSprite's initial Y position.
	 */
	public function new(x:Float = 0, y:Float = 0, graphic:FlxGraphicAsset)
	{
		super(x, y, graphic);
	}

	override function initVars():Void
	{
		scrollFactor2 = FlxPoint.get(1.1, 1.1);
		_scroll = FlxPoint.get();
		_scroll2 = FlxPoint.get();
		super.initVars();
	}

	/**
	 * Sets the sprites skew factors, direction.
	 * These can be set independently but may lead to unexpected behaivor.
	 * @param anchor 	   the camera's scroll where the sprite appears unchanged.
	 * @param scrollOne        the scroll factors of the first point.
	 * @param scrollTwo        the scroll factors of the second point.
	 * @param direction        the sprite's direction, which determines the skew.
	 * @param horizontal       typically for ceilings and floors. Skews on the x axis, scales on the y axis.
	 * @param vertical         typically for walls and backdrops. Scales on the x axis, skews on the y axis.
	**/
	public function fixate(anchorX:Int = 0, anchorY:Int = 0, scrollOneX:Float = 1, scrollOneY:Float = 1, scrollTwoX:Float = 1.1, scrollTwoY:Float = 1.1,
			direct:String = 'horizontal'):TestParallaxSprite
	{
		switch (direct.toLowerCase())
		{
			case 'horizontal', 'orizzontale', 'horisontell':
				direction = HORIZONTAL;

			case 'vertical', 'vertikale', 'verticale', 'vertikal':
				direction = VERTICAL;
		}
		scrollFactor.set(scrollOneX, scrollOneY);
		scrollFactor2.set(scrollTwoX, scrollTwoY);
		return this;
	}

	public function getCcreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect
	{
		if (newRect == null)
			newRect = FlxRect.get();

		camera ??= FlxG.camera; // getDefaultCamera();
		_scaledOrigin.set(origin.x * scale.x, origin.y * scale.y);
		_scroll.set(x - camera.scroll.x * scrollFactor.x, y - camera.scroll.y * scrollFactor.y + origin.x - _scaledOrigin.x);
		_scroll2.set(x2 - camera.scroll.x * scrollFactor2.x, y2 - camera.scroll.y * scrollFactor2.y + origin.y - _scaledOrigin.y);
		newRect.fromTwoPoints(_scroll, _scroll2);

		if (pixelPerfectPosition)
			newRect.floor();

		if (isPixelPerfectRender(camera))
			newRect.floor();
		return newRect.getRotatedBounds(angle, _scaledOrigin, newRect);
	}

	/**
	 * Calculates the smallest globally aligned bounding box that encompasses this sprite's graphic as it
	 * would be displayed. Honors scrollFactor, rotation, scale, offset and origin.
	 * @param newRect  Optional output `FlxRect`, if `null`, a new one is created
	 * @param camera   Optional camera used for scrollFactor, if null `getDefaultCamera()` is used
	 * @return A globally aligned `FlxRect` that fully contains the input sprite.
	 * @since 4.11.0
	 */
	override public function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect
	{
		if (newRect == null)
			newRect = FlxRect.get();

		camera ??= FlxG.camera;

		newRect.setPosition(x, y);
		if (pixelPerfectPosition)
			newRect.floor();
		_scaledOrigin.set(origin.x * scale.x, origin.y * scale.y);
		newRect.x += -Std.int(camera.scroll.x * scrollFactor.x) - offset.x + origin.x - _scaledOrigin.x;
		newRect.y += -Std.int(camera.scroll.y * scrollFactor.y) - offset.y + origin.y - _scaledOrigin.y;
		if (isPixelPerfectRender(camera))
			newRect.floor();
		newRect.setSize(frameWidth * Math.abs(scale.x), frameHeight * Math.abs(scale.y));
		return newRect.getRotatedBounds(angle, _scaledOrigin, newRect);
	}

	override public function destroy():Void
	{
		direction = null;
		super.destroy();
	}

	@:noCompletion
	override function drawComplex(camera:FlxCamera):Void
	{
		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);
		/*
			if (direction == HORIZONTAL)
			{
				_matrix.c = (_scroll2.x - _scroll.x) / frameHeight;
				_matrix.d = (_scroll2.y - _scroll.y) / frameHeight;
			}
			else if (direction == VERTICAL)
			{
				_matrix.b = (_scroll2.y - _scroll.y) / frameWidth;
				_matrix.a = (_scroll2.x - _scroll.x) / frameWidth;
			}
		 */

		if (bakedRotationAngle <= 0)
		{
			updateTrig();

			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		getScreenPosition(_point, camera).subtractPoint(offset);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera))
		{
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}

		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}

	override public function isSimpleRender(?camera:FlxCamera):Bool
	{
		if (!FlxG.renderBlit)
			return false;
		return super.isSimpleRender(camera) && _matrix.c == 0 && _matrix.b == 0;
	}
}
#end

/*
	https://github.com/Itz-Miles/parallaxLT

		Comply with the license!!!

		© 2022-2024 It'z_Miles - some rights rerserved.

		Licensed under the Apache License, Version 2.0 (the "License");
		you may not use this file except in compliance with the License.
		You may obtain a copy of the License at

			http://www.apache.org/licenses/LICENSE-2.0

		Unless required by applicable law or agreed to in writing, software
		distributed under the License is distributed on an "AS IS" BASIS,
		WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		See the License for the specific language governing permissions and
		limitations under the License.
 */
