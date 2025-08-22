package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.*;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;

/**
 * ...
 * @author 
 */
class Prompt extends MusicBeatSubstate
{
	var selected = 0;

	public var okc:Void->Void;
	public var cancelc:Void->Void;

	var theText:String = '';
	var goAnyway:Bool = false;
	var panel:FlxSprite;
	var buttonAccept:FlxButton;
	var buttonNo:FlxButton;

	public function new(promptText:String = '', defaultSelected:Int = 0, okCallback:Void->Void, cancelCallback:Void->Void, acceptOnDefault:Bool = false,
			option1:String = null, option2:String = null)
	{
		selected = defaultSelected;
		okc = okCallback;
		cancelc = cancelCallback;
		theText = promptText;
		goAnyway = acceptOnDefault;

		var op1 = 'OK';
		var op2 = 'CANCEL';

		if (option1 != null)
			op1 = option1;
		if (option2 != null)
			op2 = option2;
		buttonAccept = new FlxButton(473.3, 450, op1, function()
		{
			if (okc != null)
				okc();
			close();
		});
		buttonNo = new FlxButton(633.3, 450, op2, function()
		{
			if (cancelc != null)
				cancelc();
			close();
		});
		super();
	}

	override public function create():Void
	{
		super.create();
		if (goAnyway)
		{
			if (okc != null)
				okc();
			close();
		}
		else
		{
			var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
			bg.scale.set(1290, 730);
			bg.alpha = 0;
			bg.scrollFactor.set();
			bg.screenCenter();
			add(bg);
			FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quintOut});

			panel = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
			panel.scale.set(400, 250);
			panel.updateHitbox();
			panel.scrollFactor.set();
			panel.screenCenter();

			add(panel);
			add(buttonAccept);
			add(buttonNo);


			var text:FlxText = new FlxText(buttonNo.width * 2, panel.y, 300, theText, 16);
			text.alignment = 'center';
			add(text);

			text.screenCenter();
			buttonAccept.screenCenter();
			buttonNo.screenCenter();
			buttonAccept.x -= buttonNo.width / 1.5;
			buttonAccept.y = panel.y + panel.height - 30;
			buttonNo.x += buttonNo.width / 1.5;
			buttonNo.y = panel.y + panel.height - 30;
			text.scrollFactor.set();
		}
	}
}
