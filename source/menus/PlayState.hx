package menus;

import Objects;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import sys.*;

using StringTools;

class PlayState extends FlxState
{
	private var buttons:FlxTypedGroup<FlxButton>;
	private var refreshButton:FlxButton;
	private var chartsDrop:FlxUIDropDownMenu;
	private var chartsList:Array<String> = [];

	private var loadedTxt:Text;
	private var infoTxt:Text;

	private var curSelected:Int = -1;

	override function create()
	{
		bgColor = 0;

		loadCharts();

		add(buttons = new FlxTypedGroup<FlxButton>());

		refreshButton = new FlxButton(15, 15, 'Refresh', function ()
		{
			loadCharts();

			curSelected = -1;
			setInfo();
			trace('Refreshed!');
		});
		buttons.add(refreshButton);

		add(chartsDrop = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(chartsList, true), function(character:String)
		{
			setInfo();
		}));

		add(loadedTxt = new Text(chartsDrop.x, chartsDrop.y - 20, FlxG.width, 'Currently loaded:', 11, LEFT, FlxColor.WHITE, OUTLINE, FlxColor.BLACK, 1));
		loadedTxt.font = null;

		add(infoTxt = new Text(FlxG.width / 2 - 5, 20, FlxG.width / 2, '', 20, RIGHT, FlxColor.WHITE, OUTLINE, FlxColor.BLACK, 1.5));

		setInfo();
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
		loadedTxt = null;
		infoTxt = null;
	}

	private function loadCharts():Void
	{
		chartsList = [];

		var files = FileSystem.readDirectory('charts');
		for (i in 0...files.length)
		{
			var song = files[i];

			if (!song.contains('.json')) continue;

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

	private function setInfo():Void
	{
		var selected = curSelected;
		curSelected = Std.parseInt(chartsDrop.selectedId);

		if (selected == curSelected) 
		{
			trace("It's the same song!");
			return;
		}

		var chart = new Chart();
		try 
		{
			Chart.getData(chartsDrop.selectedLabel, chart);
		}
		catch (e)
		{
			trace('Error: ${e.message}.');
		}

		var data = chart.data;
		var info = 
		{
			name: data.song,
			bpm: Std.string(data.bpm),
			speed: Std.string(data.speed),
			notesCount: chart.notesCount,
			susCount: chart.susCount,
			totalNotes: chart.totalNotes
		}

		infoTxt.text = '';
		infoTxt.lerpText = 'Song: ${info.name}\nScroll speed: ${info.speed}\nBPM: ${info.bpm}\n\nNotes: ${info.notesCount}\nHold notes: ${info.susCount}\nTotal notes: ${info.totalNotes}';
	}
}
