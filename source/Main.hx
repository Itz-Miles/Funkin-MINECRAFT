package;

import openfl.text.TextFormat;
import openfl.text.TextField;
import flixel.system.FlxAssets;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;
#if !macro
import Paths;
#end
#if desktop
import Discord.DiscordClient;
#end
// crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class Main extends Sprite
{
	public static var fpsVar:FPSCounter;
	public static var buildInfo:TextField;

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
		stage.addEventListener(Event.RESIZE, onResize);
	}

	function setupGame():Void
	{
		FlxAssets.FONT_DEFAULT = "Monocraft";
		addChild(new FlxGame(1280, 720, LoadingState, 60, 60, true, false));

		#if !html5 FlxG.camera.bgColor = 0x0F0F0F; #end
		FlxG.save.bind('funkin', ClientPrefs.getSavePath());
		ClientPrefs.loadDefaultKeys();
		ClientPrefs.loadPrefs();
		Controls.init();

		#if !mobile
		fpsVar = new FPSCounter();
		addChild(fpsVar);

		buildInfo = new TextField();
		buildInfo.width = 1280;
		buildInfo.height = 24;
		buildInfo.x = 0;
		buildInfo.y = 676;
		buildInfo.selectable = false;
		mouseEnabled = false;
		buildInfo.defaultTextFormat = new TextFormat("Monocraft", 16, 0xffffff);
		buildInfo.autoSize = CENTER;
		buildInfo.wordWrap = true;
		buildInfo.background = true;
		buildInfo.backgroundColor = 0x24000000;
		buildInfo.alpha = 0.6;
		addChild(buildInfo);
		buildInfo.text = '${FlxG.stage.application.meta.get("name")} Open Pre-Alpha Build (${FlxG.stage.application.meta.get("version")}) - ${haxe.macro.Compiler.getDefine("BUILD_DATE")}';
		onResize(null);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		if (fpsVar != null)
		{
			fpsVar.visible = ClientPrefs.data.showFPS;
		}
		#end

		#if desktop
		if (!DiscordClient.isInitialized)
		{
			DiscordClient.initialize();
			Application.current.window.onClose.add(function()
			{
				ClientPrefs.saveSettings();
				DiscordClient.shutdown();
			});
		}
		#end

		#if html5
		FlxG.autoPause = false;
		#end

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	function onResize(e:Event):Void
	{
		if (buildInfo != null && stage != null)
		{
			buildInfo.width = stage.stageWidth;
			buildInfo.y = stage.stageHeight - buildInfo.height;
		}
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "FunkinMinecraft" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: "
			+ e.error
			+ "\nPlease report this error to the GitHub page: https://github.com/Itz-Miles/Funkin-MINECRAFT \n\n> Crash Handler written by sqirra-rng";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end
}
