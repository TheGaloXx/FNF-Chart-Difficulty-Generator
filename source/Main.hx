package;

import flixel.FlxG;

using StringTools;

class Main extends openfl.display.Sprite
{
	public function new()
	{
		super();

		final multiplier = 2;
		var stage = openfl.Lib.current.stage;

		addChild(new flixel.FlxGame(Std.int(stage.stageWidth / multiplier), Std.int(stage.stageHeight / multiplier), substates.Start, 60, 60, true));
		addChild(new Objects.FPSCounter());

		#if sys
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if (hl && !debug)
		hl.UI.closeConsole();
		#end
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	#if sys
	private function onCrash(e:openfl.events.UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<haxe.CallStack.StackItem> = haxe.CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + 'crash_' + dateNow + ".txt";

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

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the dev team.\n\n> Crash Handler written by: sqirra-rng";

		if (!sys.FileSystem.exists("./crash/"))
			sys.FileSystem.createDirectory("./crash/");

		sys.io.File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + haxe.io.Path.normalize(path));

		#if !hl lime.app.Application.current.window.alert(errMsg, "Error!"); #end
		Sys.exit(1);
	}
	#end

	// Code by Sanco
	public static function changeFPS(cap:Int)
	{
		if (cap > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = cap;
			FlxG.drawFramerate = cap;
		}
		else
		{
			FlxG.drawFramerate = cap;
			FlxG.updateFramerate = cap;
		}
	}
}
