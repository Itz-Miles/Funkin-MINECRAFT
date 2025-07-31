package parallax;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxGradient;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel_5_3_1.ParallaxSprite;

/**
 * This FlxGroup contains the background elements of a Parallax stage.
 */
class ParallaxBG extends FlxTypedGroup<FlxSprite>
{
	/**
	 * X position of the upper left corner of this group in world space.
	 */
	public var x(default, set):Float = 0;

	/**
	 * Y position of the upper left corner of this group in world space.
	 */
	public var y(default, set):Float = 0;

	// public var camera_speed:Float = 1.0;

	public function new(stage:String = 'arch', scrollMult:Float = 1.0)
	{
		super();

		switch (stage)
		{
			case 'arch':
				FlxG.camera.bgColor = 0xff82aafa;
				/*
					if (ClientPrefs.data.parallaxLT)
					{
				 */
				var piece01:FlxSprite = new FlxSprite(12, -3, Paths.image('archway/piece_00', stage));
				piece01.scrollFactor.set(0.0833333333 * scrollMult, 0.0833333333 * scrollMult);
				add(piece01);

				// 60, 1430, ?, 790
				// FlxG.camera.setScrollBounds(-60, 1430, null, 790);
				if (FlxG.state is PlayState)
				{
					// FlxG.camera.fade(FlxG.camera.bgColor, 0.5, true, true); // check for load
					PlayState.camZoomTarget = 1.0;
					PlayState.instance.camTarget.set(500, 200);

					var directoryTitle:FlxText = new FlxText(-400, 250, 0, "\nby itz_miles           stalstruck", 72);
					directoryTitle.setFormat(Paths.font('Minecrafter.ttf'), 72, 0xFF000000, CENTER, OUTLINE, 0xff82aafa);
					directoryTitle.borderSize = 6;
					directoryTitle.scrollFactor.set(0.3 * scrollMult, 0.3 * scrollMult);
					directoryTitle.updateHitbox();
					add(directoryTitle);

					FlxTween.tween(directoryTitle, {x: 1200}, 4.0, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							directoryTitle.destroy();
							directoryTitle = null;
						}
					});
				}

				var piece02:ParallaxSprite = new ParallaxSprite(0, 38, Paths.image('archway/piece_02', stage));
				piece02.fixate(768, 432, 0.728070175 * scrollMult, 0.728070175 * scrollMult, 0.350877193 * scrollMult, 0.350877193 * scrollMult, 'horizontal');
				add(piece02);

				var piece03:ParallaxSprite = new ParallaxSprite(592, 530, Paths.image('archway/piece_03', stage));
				piece03.fixate(768, 432, 0.175438596 * scrollMult, 0.175438596 * scrollMult, 0.333333333 * scrollMult, 0.333333333 * scrollMult, 'horizontal');
				add(piece03);

				var piece04:ParallaxSprite = new ParallaxSprite(658, 516, Paths.image('archway/piece_04', stage));
				piece04.fixate(768, 432, 0.254385965 * scrollMult, 0.254385965 * scrollMult, 0.285087719 * scrollMult, 0.285087719 * scrollMult, 'vertical');
				add(piece04);

				var piece05:ParallaxSprite = new ParallaxSprite(667, 523, Paths.image('archway/piece_05', stage));
				piece05.fixate(768, 432, 0.285087719 * scrollMult, 0.285087719 * scrollMult, 0.276315789 * scrollMult, 0.276315789 * scrollMult, 'vertical');
				add(piece05);

				var piece06:ParallaxSprite = new ParallaxSprite(849, 550, Paths.image('archway/piece_06', stage));
				piece06.fixate(768, 432, 0.333333333 * scrollMult, 0.333333333 * scrollMult, 0.380952381 * scrollMult, 0.380952381 * scrollMult, 'vertical');
				add(piece06);

				var piece07:ParallaxSprite = new ParallaxSprite(882, 529, Paths.image('archway/piece_07', stage));
				piece07.fixate(768, 432, 0.285087719 * scrollMult, 0.285087719 * scrollMult, 0.285087719 * scrollMult, 0.285087719 * scrollMult, 'vertical');
				add(piece07);

				var piece20:ParallaxSprite = new ParallaxSprite(482, 0, Paths.image('archway/piece_08', stage));
				piece20.fixate(768, 432, 0.478070175 * scrollMult, 0.478070175 * scrollMult, 0.298245614 * scrollMult, 0.298245614 * scrollMult,
					'vertical'); // inaccurate
				add(piece20);

				var piece09:ParallaxSprite = new ParallaxSprite(0, 512, Paths.image('archway/piece_09', stage));
				piece09.fixate(768, 432, 0.245614035 * scrollMult, 0.245614035 * scrollMult, 1 * scrollMult, 1 * scrollMult, 'horizontal');
				add(piece09);

				var piece10:ParallaxSprite = new ParallaxSprite(939, 496, Paths.image('archway/piece_10', stage));
				piece10.fixate(768, 1032, 0.434210526 * scrollMult, 0.434210526 * scrollMult, 0.51754386 * scrollMult, 0.51754386 * scrollMult, 'vertical');
				add(piece10);

				var piece12:ParallaxSprite = new ParallaxSprite(201, 0, Paths.image('archway/piece_11', stage));
				piece12.fixate(768, 432, 0.571428571 * scrollMult, 0.571428571 * scrollMult, 0.357142857 * scrollMult, 0.357142857 * scrollMult, 'horizontal');
				add(piece12);

				var piece13:ParallaxSprite = new ParallaxSprite(511, 0, Paths.image('archway/piece_12', stage));
				piece13.fixate(768, 432, 0.428571429 * scrollMult, 0.428571429 * scrollMult, 0.321428571 * scrollMult, 0.321428571 * scrollMult, 'horizontal');
				add(piece13);

				var piece14:ParallaxSprite = new ParallaxSprite(685, 0, Paths.image('archway/piece_13', stage));
				piece14.fixate(768, 432, 0.321428571 * scrollMult, 0.321428571 * scrollMult, 0.285714286 * scrollMult, 0.285714286 * scrollMult, 'horizontal');
				add(piece14);

				var piece15:ParallaxSprite = new ParallaxSprite(0, 93, Paths.image('archway/piece_14', stage));
				piece15.fixate(768, 432, 0.571428571 * scrollMult, 0.571428571 * scrollMult, 0.571428571 * scrollMult, 0.571428571 * scrollMult,
					'vertical'); // offscreen pt1
				add(piece15);

				var piece17:ParallaxSprite = new ParallaxSprite(17, 0, Paths.image('archway/piece_15', stage));
				piece17.fixate(768, 432, 0.820175439 * scrollMult, 0.820175439 * scrollMult, 0.429824561 * scrollMult, 0.429824561 * scrollMult, 'vertical');
				add(piece17);

				var piece18:ParallaxSprite = new ParallaxSprite(267, 0, Paths.image('archway/piece_16', stage));
				piece18.fixate(768, 432, 0.442982456 * scrollMult, 0.442982456 * scrollMult, 0.385964912 * scrollMult, 0.385964912 * scrollMult, 'vertical');
				add(piece18);

				var piece19:ParallaxSprite = new ParallaxSprite(337, 0, Paths.image('archway/piece_17', stage));
				piece19.fixate(768, 432, 0.530701754 * scrollMult, 0.530701754 * scrollMult, 0.315789474 * scrollMult, 0.315789474 * scrollMult, 'vertical');
				add(piece19);

				var piece11:ParallaxSprite = new ParallaxSprite(0, 467, Paths.image('archway/piece_18', stage));
				piece11.fixate(768, 432, 0.315789474 * scrollMult, 0.315789474 * scrollMult, 0.828947368 * scrollMult, 0.828947368 * scrollMult, 'horizontal');
				add(piece11);

				var piece16:ParallaxSprite = new ParallaxSprite(41, 0, Paths.image('archway/piece_19', stage));
				piece16.fixate(768, 432, 0.565789474 * scrollMult, 0.565789474 * scrollMult, 0.478070175 * scrollMult, 0.478070175 * scrollMult, 'vertical');
				add(piece16);

				var piece27:ParallaxSprite = new ParallaxSprite(898, 520, Paths.image('archway/piece_10', stage));
				piece27.fixate(768, 432, 0.555555556 * scrollMult, 0.555555556 * scrollMult, 0.684210526 * scrollMult, 0.684210526 * scrollMult, 'vertical');
				add(piece27);

				var piece21:ParallaxSprite = new ParallaxSprite(981, 0, Paths.image('archway/piece_20', stage));
				piece21.fixate(768, 432, 0.684210526 * scrollMult, 0.684210526 * scrollMult, 0.543859649 * scrollMult, 0.543859649 * scrollMult, 'vertical');
				add(piece21);

				var piece22:ParallaxSprite = new ParallaxSprite(1410, 94, Paths.image('archway/piece_21', stage));
				piece22.fixate(768, 432, 0.517857143 * scrollMult, 0.517857143 * scrollMult, 0.605263158 * scrollMult, 0.605263158 * scrollMult, 'vertical');
				add(piece22);

				var piece23:ParallaxSprite = new ParallaxSprite(1195, 0, Paths.image('archway/piece_01', stage));
				piece23.fixate(768, 432, 0.460526316 * scrollMult, 0.482142857 * scrollMult, 0.728070175 * scrollMult, 0.728070175 * scrollMult, 'vertical');
				add(piece23);

				var piece24:ParallaxSprite = new ParallaxSprite(1510, 555, Paths.image('archway/piece_22', stage));
				piece24.fixate(768, 432, 0.688596491 * scrollMult, 0.688596491 * scrollMult, 0.688596491 * scrollMult, 0.688596491 * scrollMult, 'vertical');
				add(piece24);

				var piece25:ParallaxSprite = new ParallaxSprite(1120, 0, Paths.image('archway/piece_23', stage));
				piece25.fixate(768, 432, 0.5 * scrollMult, 0.5 * scrollMult, 0.75877193 * scrollMult, 0.75877193 * scrollMult, 'vertical');
				add(piece25);

				var piece26:ParallaxSprite = new ParallaxSprite(0, 0, Paths.image('archway/piece_24', stage));
				piece26.fixate(768, 432, 0.657894737 * scrollMult, 0.657894737 * scrollMult, 0.657894737 * scrollMult, 0.657894737 * scrollMult, 'vertical');
				add(piece26);

				var piece28:ParallaxSprite = new ParallaxSprite(1405, 555, Paths.image('archway/piece_25', stage));
				piece28.fixate(768, 432, 0.75 * scrollMult, 0.75 * scrollMult, 0.697368421 * scrollMult, 0.697368421 * scrollMult, 'vertical');
				add(piece28);

				var piece29:ParallaxSprite = new ParallaxSprite(1, 584, Paths.image('archway/piece_26', stage));
				piece29.fixate(768, 432, 0.807017544 * scrollMult, 0.807017544 * scrollMult, 0.807017544 * scrollMult, 0.807017544 * scrollMult, 'veetical');
				add(piece29);
				/*
					}
					else
					{
						var bg:FlxSprite = new FlxSprite(12, -3, Paths.image('backgrounds/menuBG', stage));
						bg.scrollFactor.set(scrollMult, scrollMult);
						add(bg);
					}
				 */
				setPosition(-130, -70);
				if (FlxG.state is MainMenuState && MainMenuState.curSelection == 0)
				{
					var message:FlxText = new FlxText(500, 240, 0, "ItzMilesDev\nleft the game", 16);
					message.setFormat(Paths.font('Monocraft.ttf'), 16, 0xFFFFFF, CENTER, OUTLINE_FAST, 0xAA000000);
					message.borderSize = 32;
					message.scrollFactor.set(0.565789474 * scrollMult, 0.565789474 * scrollMult);
					add(message);
					FlxTween.tween(message, {alpha: 0, y: 250}, 0.8, {
						ease: FlxEase.quintOut,
						startDelay: 2.5,
						onComplete: function(twn:FlxTween)
						{
							message.destroy();
							message = null;
						}
					});
				}

			case 'camp':
				FlxG.camera.bgColor = 0xffff7142;
				var sky:FlxSprite = FlxGradient.createGradientFlxSprite(1920, 1080, [0xFFFF0000, 0x000000, 0xFF00059A]);
				add(sky);
				for (i in 0...20)
				{
					var cloud:FlxSprite = new FlxSprite(Math.random() * 1720, Math.random() * 340).makeGraphic(200, 40, 0xffffffff);
					cloud.alpha = Math.random();
					cloud.y += 100;
					add(cloud);
				}
				var ground:FlxSprite = new FlxSprite(0, 656).makeGraphic(1920, 424, 0xff1d1721);
				add(ground);
				PlayState.camZoomTarget = 0.4;
			case 'forge':
				FlxG.camera.bgColor = 0xff00053D;
				PlayState.camZoomTarget = 1.2;

				var sky:FlxSprite = FlxGradient.createGradientFlxSprite(1920, 1080, [0xFF151944, 0x000000, 0xFF9523FF, 0xFFAA64FF]);
				add(sky);
				for (i in 0...10)
				{
					var cloud:FlxSprite = new FlxSprite(Math.random() * 1740, Math.random() * 350).makeGraphic(240, 64, 0xffa65eff);
					cloud.alpha = Math.random() * 1.2;
					cloud.y += 100;
					add(cloud);
				}
				var ground:FlxSprite = new FlxSprite(341, 708).makeGraphic(1239, 80, 0xff191C2A);
				add(ground);
				var ground2:FlxSprite = new FlxSprite(341, 773).makeGraphic(1239, 360, 0xff141722);
				add(ground2);

				var foundation:FlxSprite = new FlxSprite(672, 677).makeGraphic(576, 31, 0xff222536);
				add(foundation);

				var smithingWall:FlxSprite = new FlxSprite(672, 504).makeGraphic(282, 173, 0xff181A26);
				add(smithingWall);
				var houseWall:FlxSprite = new FlxSprite(954, 504).makeGraphic(294, 173, 0xff34273B);
				add(houseWall);

				var roof:FlxSprite = new FlxSprite(672, 473).makeGraphic(576, 31, 0xff222536);
				add(roof);
				var houseRoof:FlxSprite = new FlxSprite(983, 442).makeGraphic(237, 31, 0xff34273B);
				add(houseRoof);
				var houseRoof2:FlxSprite = new FlxSprite(1018, 411).makeGraphic(168, 31, 0xff34273B);
				add(houseRoof2);
				var houseRoof3:FlxSprite = new FlxSprite(1047, 380).makeGraphic(109, 31, 0xff34273B);
				add(houseRoof3);
			case 'gates':
				var temp:FlxSprite = new FlxSprite(0, 0, Paths.image('T1_Concept', "gates"));
				temp.setGraphicSize(1280, 720);
				temp.origin.set(0, 0);
				add(temp);
				FlxG.camera.bgColor = 0xFF0C0D36;
				PlayState.camZoomTarget = 1.0;
			case 'rift':
				FlxG.camera.bgColor = 0xff5a0707;
				PlayState.camZoomTarget = 1.0;
			case 'ruins':
				FlxG.camera.bgColor = 0xff898336;
				PlayState.camZoomTarget = 1.0;
		}
	}

	@:noCompletion
	function set_x(value:Float):Float
	{
		for (member in this.members)
		{
			if (member != null)
			{
				member.x -= x;
				member.x += value;
			}
		}
		return x = value;
	}

	@:noCompletion
	function set_y(value:Float):Float
	{
		for (member in this.members)
		{
			if (member != null)
			{
				member.y -= y;
				member.y += value;
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
