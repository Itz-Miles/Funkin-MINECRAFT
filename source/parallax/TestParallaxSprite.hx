#if (flixel >= "5.3.1")
package parallax;

import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.graphics.frames.FlxTileFrames;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxDestroyUtil;
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
 * The ParallaxSprite is a FlxSprite extension that performs linear transformations to mimic 3D graphics.
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
	 * Creates a ParallaxSprite at specified position with a specified graphic.
	 * @param graphic		The graphic to load (uses haxeflixel's default if null)
	 * @param   X			The ParallaxSprite's initial X position.
	 * @param   Y			The FlxParllaxSprite's initial Y position.
	 * @param   SimpleGraphic   The graphic you want to display
	 *                          (OPTIONAL - for simple stuff only, do NOT use for animated images!).
	 */
	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
	}

	@:noCompletion
	override function initVars():Void
	{
		scrollFactor2 = FlxPoint.get(1.1, 1.1);
		_scroll = FlxPoint.get();
		_scroll2 = FlxPoint.get();
		super.initVars();
	}

	override public function destroy():Void
	{
		super.destroy();

		scrollFactor2 = FlxDestroyUtil.put(scrollFactor2);
		_scroll = FlxDestroyUtil.put(_scroll);
		_scroll2 = FlxDestroyUtil.put(_scroll2);
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

	/**
	 * Helper function to set the graphic's dimensions by using `scale`, allowing you to keep the current aspect ratio
	 * should one of the numbers be `<= 0`. It might make sense to call `updateHitbox()` afterwards!
	 *
	 * @param   width    How wide the graphic should be. If `<= 0`, and `height` is set, the aspect ratio will be kept.
	 * @param   height   How high the graphic should be. If `<= 0`, and `width` is set, the aspect ratio will be kept.
	 */
	override public function setGraphicSize(width = 0.0, height = 0.0):Void
	{
		if (width <= 0 && height <= 0)
			return;

		var newScaleX:Float = width / frameWidth;
		var newScaleY:Float = height / frameHeight;
		scale.set(newScaleX, newScaleY);

		if (width <= 0)
			scale.x = newScaleY;
		else if (height <= 0)
			scale.y = newScaleX;
	}

	/**
	 * Updates the sprite's hitbox (`width`, `height`, `offset`) according to the current `scale`.
	 * Also calls `centerOrigin()`.
	 */
	override public function updateHitbox():Void
	{
		width = Math.abs(scale.x) * frameWidth;
		height = Math.abs(scale.y) * frameHeight;
		offset.set(-0.5 * (width - frameWidth), -0.5 * (height - frameHeight));
		centerOrigin();
	}

	/**
	 * Resets some important variables for sprite optimization and rendering.
	 */
	@:noCompletion
	override function resetHelpers():Void
	{
		resetFrameSize();
		resetSizeFromFrame();
		_flashRect2.x = 0;
		_flashRect2.y = 0;

		if (graphic != null)
		{
			_flashRect2.width = graphic.width;
			_flashRect2.height = graphic.height;
		}

		centerOrigin();

		if (FlxG.renderBlit)
		{
			dirty = true;
			updateFramePixels();
		}
	}

	/**
	 * Called by game loop, updates then blits or renders current frame of animation to the screen.
	 */
	override public function draw():Void
	{
		checkEmptyFrame();

		if (alpha == 0 || _frame.type == FlxFrameType.EMPTY)
			return;

		if (dirty) // rarely
			calcFrame(useFramePixels);

		for (camera in getCamerasLegacy())
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
				continue;

			if (isSimpleRender(camera))
				drawSimple(camera);
			else
				drawComplex(camera);

			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	@:noCompletion
	override function drawSimple(camera:FlxCamera):Void
	{
		getScreenPosition(_point, camera).subtractPoint(offset);
		if (isPixelPerfectRender(camera))
			_point.floor();

		_point.copyToFlash(_flashPoint);
		camera.copyPixels(_frame, framePixels, _flashRect, _flashPoint, colorTransform, blend, antialiasing);
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

	/**
	 * Request (or force) that the sprite update the frame before rendering.
	 * Useful if you are doing procedural generation or other weirdness!
	 *
	 * @param   Force   Force the frame to redraw, even if its not flagged as necessary.
	 */
	override public function drawFrame(Force:Bool = false):Void
	{
		if (FlxG.renderBlit)
		{
			if (Force || dirty)
			{
				dirty = true;
				calcFrame();
			}
		}
		else
		{
			dirty = true;
			calcFrame(true);
		}
	}

	/**
	 * Helper function that adjusts the offset automatically to center the bounding box within the graphic.
	 *
	 * @param   AdjustPosition   Adjusts the actual X and Y position just once to match the offset change.
	 */
	override public function centerOffsets(AdjustPosition:Bool = false):Void
	{
		offset.x = (frameWidth - width) * 0.5;
		offset.y = (frameHeight - height) * 0.5;
		if (AdjustPosition)
		{
			x += offset.x;
			y += offset.y;
		}
	}

	/**
	 * Retrieve the midpoint of this sprite's graphic in world coordinates.
	 *
	 * @param   point  The resulting point, if `null` a new one is created
	 */
	override public function getGraphicMidpoint(?point:FlxPoint):FlxPoint
	{
		final rect = getGraphicBounds();
		point = rect.getMidpoint(point);
		rect.put();
		return point;
	}

	/**
	 * Retrieves the world bounds of this sprite's graphic
	 * **Note:** Ignores `scrollFactor`, to get the screen position of the graphic use
	 * `getScreenBounds`
	 *
	 * @param   rect  The resulting rect, if `null` a new one is created
	 * @since 5.9.0
	 */
	override public function getGraphicBounds(?rect:FlxRect):FlxRect
	{
		if (rect == null)
			rect = FlxRect.get();

		rect.set(x, y);
		if (pixelPerfectPosition)
			rect.floor();

		_scaledOrigin.set(origin.x * scale.x, origin.y * scale.y);
		rect.x += origin.x - offset.x - _scaledOrigin.x;
		rect.y += origin.y - offset.y - _scaledOrigin.y;
		rect.setSize(frameWidth * scale.x, frameHeight * scale.y);

		if (angle % 360 != 0)
			rect.getRotatedBounds(angle, _scaledOrigin, rect);

		return rect;
	}

	/**
	 * Check and see if this object is currently on screen. Differs from `FlxObject`'s implementation
	 * in that it takes the actual graphic into account, not just the hitbox or bounding box or whatever.
	 *
	 * @param   Camera  Specify which game camera you want. If `null`, `FlxG.camera` is used.
	 * @return  Whether the object is on screen or not.
	 */
	override public function isOnScreen(?camera:FlxCamera):Bool
	{
		if (camera == null)
			camera = FlxG.camera;

		return camera.containsRect(getScreenBounds(_rect, camera));
	}

	/**
	 * Returns the result of `isSimpleRenderBlit()` if `FlxG.renderBlit` is
	 * `true`, or `false` if `FlxG.renderTile` is `true`.
	 */
	override public function isSimpleRender(?camera:FlxCamera):Bool
	{
		if (FlxG.renderTile)
			return false;

		return isSimpleRenderBlit(camera);
	}

	/**
	 * Determines the function used for rendering in blitting:
	 * `copyPixels()` for simple sprites, `draw()` for complex ones.
	 * Sprites are considered simple when they have an `angle` of `0`, a `scale` of `1`,
	 * don't use `blend` and `pixelPerfectRender` is `true`.
	 *
	 * @param   camera   If a camera is passed its `pixelPerfectRender` flag is taken into account
	 */
	override public function isSimpleRenderBlit(?camera:FlxCamera):Bool
	{
		var result:Bool = (angle == 0 || bakedRotationAngle > 0) && scale.x == 1 && scale.y == 1 && blend == null;
		result = result && (camera != null ? isPixelPerfectRender(camera) : pixelPerfectRender);
		return result;
	}

	/**
	 * Calculates the smallest globally aligned bounding box that encompasses this
	 * sprite's width and height, at its current rotation.
	 * Note, if called on a `FlxSprite`, the origin is used, but scale and offset are ignored.
	 * Use `getScreenBounds` to use these properties.
	 * @param newRect The optional output `FlxRect` to be returned, if `null`, a new one is created.
	 * @return A globally aligned `FlxRect` that fully contains the input object's width and height.
	 * @since 4.11.0
	 */
	override function getRotatedBounds(?newRect:FlxRect)
	{
		if (newRect == null)
			newRect = FlxRect.get();

		newRect.set(x, y, width, height);
		return newRect.getRotatedBounds(angle, origin, newRect);
	}

	/**
	 * Calculates the smallest globally aligned bounding box that encompasses this sprite's graphic as it
	 * would be displayed. Honors scrollFactor, rotation, scale, offset and origin.
	 * @param newRect Optional output `FlxRect`, if `null`, a new one is created.
	 * @param camera  Optional camera used for scrollFactor, if null `FlxG.camera` is used.
	 * @return A globally aligned `FlxRect` that fully contains the input sprite.
	 * @since 4.11.0
	 */
	override public function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect
	{
		if (newRect == null)
			newRect = FlxRect.get();

		if (camera == null)
			camera = FlxG.camera;

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
