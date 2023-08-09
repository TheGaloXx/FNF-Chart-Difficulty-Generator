package menus;

import flixel.FlxState;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.ui.FlxButton;
import sys.*;

using StringTools;

class PlayState extends FlxState
{
	private var buttons:FlxTypedGroup<FlxButton>;
	private var refreshButton:FlxButton;
	private var chartsDrop:FlxUIDropDownMenu;
	private var chartsList:Array<String> = [];

	override function create()
	{
		bgColor = 0;

		loadCharts();

		add(buttons = new FlxTypedGroup<FlxButton>());

		refreshButton = new FlxButton(15, 15, 'Refresh', function ()
		{
			loadCharts();
			trace('Refreshed!');
		});
		buttons.add(refreshButton);

		add(chartsDrop = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(chartsList, true), function(character:String)
		{
			//loadCharts();
		}));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override function destroy()
	{
		super.destroy();

		buttons = null;
		refreshButton = null;
		chartsDrop = null;
		chartsList = null;
	}

	private function loadCharts():Void
	{
		chartsList = [];

		var files = FileSystem.readDirectory('charts');
		for (i in 0...files.length)
		{
			var song = files[i];

			if (!song.contains('.json')) continue;
			trace('continues??');

			var lastDotIndex:Int = song.lastIndexOf(".");
			song = lastDotIndex != -1 ? song.substr(0, lastDotIndex) : song;
			
			chartsList.push(song); 
		}

		trace(chartsList);

		if (chartsList.length <= 0)
		{
			//var json = new TestChart().get().trim();
			//while (!json.endsWith("}")) json = json.substr(0, json.length - 1);
			chartsList.push('test');
		}
	}
}
