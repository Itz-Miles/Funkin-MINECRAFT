package;

import haxe.Json;
import lime.utils.Assets;

/**
 * The Story class manages the loaded "stories" and "character arcs".
 * 
 * Character arcs are the events of the story from the perspective of a character.
 * 
 * Stories are the collection of character arcs that make up the entire story.
 */
class Story
{
	/**
	 * The currently loaded story data.
	 */
	public static var currentStory:StoryData;

	/**
	 * A list of the story directories found in the filesystem.
	 */
	public static var storiesList:Array<String>;

	public static function reloadList()
	{
		storiesList = CoolUtil.coolTextFile(Paths.getPreloadPath('stories/stories.txt'));
		trace('Stories: $storiesList');
	}

	/**
	 * Loads a story from a JSON file.
	 * @param storyName The name of the story to load.
	 */
	public static function loadStory(storyName:String):Void
	{
		var rawJson:String = Assets.getText(Paths.json('stories/' + storyName + '.json'));
		currentStory = haxe.Json.parse(rawJson);
	}
}

typedef StoryData =
{
	var name:String;
	var author:String;
	var characterArcs:Array<CharacterArc>;
}

typedef CharacterArc =
{
	var character:String;
}
