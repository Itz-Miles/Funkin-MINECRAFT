package states;

// import parallax.ParallaxDebugState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxSprite;
import lime.app.Promise;
import lime.app.Future;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import haxe.io.Path;

class LoadingState extends MusicBeatState
{
	public static var stage(default, set):String = "aero_archways";

	static function set_stage(value:String):String
	{
		if (value != null)
			return stage = value;
		else
			return stage = "aero_archways";
	}

	var target:FlxState;
	var stopMusic = false;
	var directory:String;
	var callbacks:MultiCallback;
	var callbacksRatio:Float = 0;

	function new(target:FlxState, stopMusic:Bool, directory:String)
	{
		super();
		this.target = target != null ? target : new GameWorld();
		this.stopMusic = stopMusic;
		this.directory = directory;
	}

	var loadBar:FlxSprite;

	override function create()
	{
		var loadingText:FlxText = new FlxText(0, 200, 1280, "loading", 160);
		loadingText.setFormat(Paths.font('Monocraft.ttf'), 160, 0xFFFFFF, CENTER);
		add(loadingText);
		loadBar = new FlxSprite(300, 720 - 300).makeGraphic(1280 - 600, 64, 0xffffffff);
		loadBar.screenCenter(X);
		loadBar.scale.x = 0;
		add(loadBar);
		var librariesText:FlxText = new FlxText(0, 720 - 300, 1280, "asset libraries", 64);
		librariesText.setFormat(Paths.font("Monocraft.ttf"), 48, FlxG.camera.bgColor, CENTER, OUTLINE, 0xffffffff);
		librariesText.borderSize = 4;
		add(librariesText);

		initSongsManifest().onComplete(function(lib)
		{
			callbacks = new MultiCallback(onLoad);
			var introComplete = callbacks.add("introComplete");
			checkLibrary("shared");
			if (directory != null && directory.length > 0 && directory != 'shared')
			{
				checkLibrary(directory);
			}

			var fadeTime = 0.5;
			FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
			FlxG.camera.zoom = 0.5;
			FlxTween.tween(FlxG.camera, {zoom: 1}, 0.5, {ease: FlxEase.elasticOut, startDelay: 0.1});
			new FlxTimer().start(fadeTime, function(_) introComplete());
		});
	}

	/*
		function checkLoadSong(path:String)
		{
			if (!Assets.cache.hasSound(path))
			{
				var library = Assets.getLibrary("songs");
				final symbolPath = path.split(":").pop();
				var callback = callbacks.add("song:" + path);
				Assets.loadSound(path).onComplete(function(_)
				{
					callback();
				});
			}
		}
	 */
	function checkLibrary(library:String)
	{
		// trace(Assets.hasLibrary(library));
		if (Assets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw "Missing library: " + library;

			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function(_)
			{
				callback();
			});
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (callbacks != null)
		{
			callbacksRatio = FlxMath.remapToRange(callbacks.numRemaining / callbacks.length, 1, 0, 0, 1);
			loadBar.scale.x = FlxMath.lerp(loadBar.scale.x, callbacksRatio, CoolUtil.boundTo(elapsed * 12, 0, 1));
		}
	}

	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.switchState(target);
	}

	static function isInstLoaded():Bool
	{
		return Paths.inst(PlayState.SONG.name) != null;
	}

	static function areVoicesLoaded():Bool
	{
		return Paths.voices(PlayState.SONG.name) != null;
	}

	public static function isAudioLoaded():Bool
	{
		return (isInstLoaded() && (!PlayState.SONG.needsVoices || areVoicesLoaded()));
	}

	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		FlxG.switchState(getNextState(target, stopMusic));
	}

	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		var library:String = 'shared';

		if (stage != null && stage.length > 0 && stage != '')
			library = stage;

		Paths.currentLevel = library;
		trace('Setting asset folder to ' + library);

		var loaded:Bool = isLibraryLoaded("shared") && isLibraryLoaded(library);
		trace('Assets loaded: $loaded');
		if (PlayState.SONG != null)
		{
			if (loaded)
				loaded = isInstLoaded() && (!PlayState.SONG.needsVoices || areVoicesLoaded());
			// wondering why haxe doesnt support the &&= operator
			trace('Song loaded: $loaded');
		}

		if (!loaded)
			return new LoadingState(target, stopMusic, library);

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		return target;
	}

	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}

	override function destroy()
	{
		super.destroy();

		callbacks = null;
	}

	static function initSongsManifest()
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error("Cannot open library \"" + id + "\"");
			}
			else
			{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
				promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;

	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();

	public function new(callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}

	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;

				if (logId != null)
					log('fired $id, $numRemaining remaining');

				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}

	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}

	public function getFired()
		return fired.copy();

	public function getUnfired()
		return [for (id in unfired.keys()) id];
}
