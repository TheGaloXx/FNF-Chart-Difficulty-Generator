package substates;

import flixel.FlxG;

class Start extends flixel.FlxState 
{
	override function create() 
	{
		#if debug
		saveCompiles();
		#end

		// flixel.system.FlxAssets.FONT_DEFAULT = 'extras/vcr.ttf';
		FlxG.worldBounds.set(0, 0);
		FlxG.mouse.visible = FlxG.mouse.enabled = true;
		FlxG.autoPause = false;

		lime.app.Application.current.onExit.add(function(_) 
		{
			Data.saveData();
			#if sys
			Sys.exit(1);
			#else
			openfl.system.System.exit(1);
			#end
		});

		Data.check();
		Data.getData();

		if (Data.data.settings.skip) FlxG.switchState(new menus.PlayState());
		else FlxG.switchState(new menus.SplashScreen());

		super.create();
	}

	private function saveCompiles():Void 
	{
		#if sys
		var compiles:Int = 0;

		var cwd = haxe.io.Path.normalize(Sys.getCwd());
		var thePath = StringTools.replace(cwd, 'export/debug/${getTarget()}/bin', '') + 'compiles.galo';

		trace('Path exists: ${sys.FileSystem.exists(thePath)}.');

		if (sys.FileSystem.exists(thePath))
			compiles = Std.parseInt(sys.io.File.getContent(thePath));

		sys.io.File.saveContent(thePath, Std.string(compiles + 1));
		#else
		trace('Target is not compatible to save compiles!');
		#end
	}

	private function getTarget():String 
	{
		var target:String = '';

		#if python
		target = 'python';
		#elseif java
		target = 'java';
		#elseif cs
		target = 'cs';
		#elseif cpp
		target = 'cpp';
		#elseif php
		target = 'php';
		#elseif lua
		target = 'lua';
		#elseif hl
		target = 'hl';
		#elseif neko
		target = 'neko';
		#end

		return target;
	}
}
