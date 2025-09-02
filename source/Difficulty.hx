package;

enum abstract Difficulty(Int) from Int to Int
{
	var EASY = 0;
	var NORMAL = 1;
	var HARD = 2;
}

var stringMap(default, never):Map<Difficulty, String> = [EASY => 'Easy', NORMAL => 'Normal', HARD => 'Hard'];