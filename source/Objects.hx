package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
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

class Error extends Text
{
	private var floatThing:Float = 0;

	override public function new() 
	{
		super(0, 10, FlxG.width, '', 26, CENTER, FlxColor.RED, OUTLINE, FlxColor.BLACK, 3);
		kill();
	}

	public function setup(msg:String):Void
	{
		FlxTween.cancelTweensOf(this);
		scale.set(0, 0);
		text = msg;
		y = 25;
		alpha = 1;

		FlxTween.tween(this, {"scale.x": 1, "scale.y": 1}, 0.25, {ease: FlxEase.sineOut});
		FlxTween.tween(this, {alpha: 0, y: 10}, 1, {startDelay: 2, onComplete: function(_)
		{
			kill();
		}});

		trace('Added error - msg: $msg.');
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		floatThing += elapsed * 10;
		if (scale.x == 1 && scale.y == 1 && alpha == 1) y += Math.sin(floatThing);
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

class DataList
{
	public var name:String;
	public var data:String;

	public function new(name:String, data:String) 
	{
		this.name = name;
		this.data = data;
	}
}

class Note extends FlxSprite
{
	private var time:Float = 0;
	private var positions:Array<Float> = [];
	final random = FlxMath.roundDecimal(FlxG.random.float(0.2, 1), 2);
	private var mult = 0.7;

	public function new()
	{
		super();
		
		mult *= random;

		frames = FlxAtlasFrames.fromSparrow('extras/little_note.png', 'extras/little_note.xml');
		for (i in 0...4) animation.addByIndices('' + i, 'little_note', [i], '', 0, false);
		antialiasing = true;

		positions.push(-width / 2);
		positions.push(FlxG.width - width / 2);
		for (i in 0...10) positions.push(64 * i);

		kill();
	}

	override function update(elapsed:Float):Void
	{
		//super.update(elapsed);

		time += (elapsed * 10) * random;

		x += Math.sin(time);

		updateMotion(elapsed);

		if (getScreenPosition().y < -height) kill();
	}

	public function setup():Void
	{
		animation.play('' + FlxG.random.int(0, 3));

		alpha = FlxG.random.float(0.25, 0.9);
		scale.set(random, random);
		setPosition(FlxG.random.getObject(positions), FlxG.height);
		velocity.y = FlxG.random.float(-300 * mult, -500 * mult);
		// acceleration.y = FlxG.random.int(-50, -125);
		angularVelocity = FlxG.random.int(-365, 365);
		scrollFactor.set(FlxG.random.float(0.2, 1.5), FlxG.random.float(0.2, 1.5));
	}
}