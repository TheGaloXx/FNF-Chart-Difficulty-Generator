package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

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

class Text extends FlxText
{
	public var lerpText:String;
	private var timer:Float = 0;

	public function new(X:Float, Y:Float, Width:Float, Text:String, Size:Int = 16, Alignment:FlxTextAlign = CENTER, Color:FlxColor = FlxColor.WHITE, ?BorderStyle:FlxTextBorderStyle = OUTLINE, BorderColor:FlxColor = FlxColor.BLACK, BorderSize:Float = 1.5)
	{
		super(X, Y, Width, Text, Size);

		font = 'extras/vcr.ttf';
		color = Color;
		
		if (Width > 0)
		{
			autoSize = false;
			alignment = Alignment;
		}

		setBorderStyle(BorderStyle, BorderColor, BorderSize);

		scrollFactor.set();
	}

	override public function update(elapsed:Float):Void
	{
		// super.update(elapsed);

		if (lerpText != null && lerpText.length > 0)
		{
			timer += elapsed;
			if (timer >= 0.025)
			{
				timer = 0;
				text += lerpText.charAt(0);
				lerpText = lerpText.substr(1, lerpText.length - 1);
			}
		}
	}
}