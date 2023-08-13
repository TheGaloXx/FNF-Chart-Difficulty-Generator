package menus;

import Objects;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import sys.*;

using StringTools;

class PlayState extends FlxState
{
	private var buttons:FlxTypedGroup<FlxButton>;
	private var errors:FlxTypedGroup<Error>;
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

		add(errors = new FlxTypedGroup<Error>());
		addError('');

		setInfo();

		FlxG.camera.fade(FlxColor.BLACK, 0.75, true);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if debug
		if (FlxG.mouse.wheel != 0)
			FlxG.camera.zoom += (FlxG.mouse.wheel / 10);
		#end
	}

	override function destroy()
	{
		super.destroy();

		buttons = null;
		errors = null;
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

		trace('Charts list: ' + chartsList + ' - length: ' + chartsList.length);

		if (chartsList.length <= 0)
		{
			trace('No charts!!!');
			//var json = new TestChart().get().trim();
			//while (!json.endsWith("}")) json = json.substr(0, json.length - 1);
			chartsList.push('test');
			addError('No chart found in the charts folder!');
		}
		else if (chartsList.contains('test')) chartsList.remove('test');

		if (chartsDrop != null) chartsDrop.setData(FlxUIDropDownMenu.makeStrIdLabelArray(chartsList, true));
	}

	private function setInfo():Void
	{
		// Check if the song to select is already selected
		var selected = curSelected;
		curSelected = Std.parseInt(chartsDrop.selectedId);

		if (selected == curSelected) 
		{
			trace("It's the same song!");
			return;
		}

		// Get chart's info
		var chart = new Chart();
		Chart.getData(chartsDrop.selectedLabel, chart);

		// Get properties to load
		var dumbFile = Utils.textFile('extras/chart data.txt');
		var listData:Array<DataList> = [];

		for (i in 0...dumbFile.length)
		{
			// Load chart's properties
			var data:Array<String> = dumbFile[i].split(':');
			listData.push(new DataList(data[0], chart.getProperty(data[1])));
		}

		var list:String = '';

		// Add them as a text
		for (i in listData)
		{
			if (i.name == '' || i.name == null) list += '\n';
			else list += '${i.name}: ${i.data}\n';
		}

		infoTxt.text = '';
		infoTxt.lerpText = list;
	}

	private function addError(msg:String):Void
	{
		var error = errors.recycle(Error.new);
		error.setup(msg);
		error.bold = true;
		errors.add(error);
	}
}
