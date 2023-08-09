package;

import flixel.FlxG;
import flixel.util.FlxColor;

// THIS IS A MODIFICATION OF THE OPENFL FPS CLASS

class FPSCounter extends openfl.text.TextField {
	public var currentFPS(default, null):Int;

	private var cacheCount:Int;
	private var currentTime:Float;
	private var times:Array<Float> = [];

	public function new() {
		super();

		x = 10;
		y = 8;

		selectable = mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat("_sans", 12, 0xFFFFFFFF);
		text = "FPS: ";
		defaultTextFormat.align = "left";
		defaultTextFormat.bold = true;
		width = FlxG.width;

		cacheCount = currentFPS = 0;
		currentTime = 0;
	}

	private override function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000) times.shift();

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		if (currentCount != cacheCount) text = "FPS: " + currentFPS;

		cacheCount = currentCount;

		if (currentFPS < (FlxG.updateFramerate / 1.2)) textColor = 0xFFFF0000;
		else textColor = 0xFFFFFFFF;
	}
}

class Error extends flixel.text.FlxText 
{
	override public function new(message:String) 
	{
		super(0, 100, FlxG.width, 'Error\n$message', 64);

		setFormat(null, 52, FlxColor.RED, CENTER, OUTLINE, FlxColor.BLACK);
		borderSize = 4;
		active = autoSize = false;

		flixel.tweens.FlxTween.tween(this, {alpha: 0, y: 0}, 1, 
		{
			startDelay: 2,
			onComplete: function(_)  destroy()
		});
	}
}