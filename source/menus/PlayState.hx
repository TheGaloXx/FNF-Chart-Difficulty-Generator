package menus;

import Objects;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import sys.*;

using StringTools;

class PlayState extends FlxUIState
{
	private var buttons:FlxTypedGroup<FlxButton>;
	private var errors:FlxTypedGroup<Error>;
	private var refreshButton:FlxButton;
	private var chartsDrop:FlxUIDropDownMenu;
	private var chartsList:Array<String> = [];
	private var box:FlxUITabMenu;

	private var loadedTxt:Text;
	private var infoTxt:Text;

	private var curSelected:Int = -1;

	override function create()
	{
		bgColor = 0;
		FlxG.autoPause = true;

		var bg = new FlxBackdrop('extras/bg_note.png', XY, 10, 10);
		bg.velocity.set(10, 10);
		bg.antialiasing = true;
		bg.angle = 45;
		add(bg);

		loadCharts();
		addUI();
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

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;

			switch(wname)
			{
				case 'FPS cap:':
					Data.data.settings.fps = nums.value;
					Data.saveData();
					Main.changeFPS(Data.data.settings.fps);
				case 'Speed reduction:':
					var chart = new Chart(); Chart.getData(chartsDrop.selectedLabel, chart);

					trace('Chart speed: ${chart.data.speed} - Speed reduction: ${nums.value} - Is lower: ${chart.data.speed - 0.1 < nums.value}');
					if (chart.data.speed - 0.1 < nums.value)
					{
						nums.value = chart.data.speed - 0.1;
						addError("Scroll speed reduction can't be lower than chart's scroll speed!");
					}
			}
		}
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

			var songExclude = ['bpm', 'scroll speed', 'aprox. duration'];
			var noteExclude = ['notes', 'hold notes', 'hold note slides'];
			var sectionExclude = ['average sec. notes'];


			if (!Data.data.settings.songInfo && (songExclude.contains(data[0].toLowerCase()))) continue;
			else if (!Data.data.settings.noteInfo && (noteExclude.contains(data[0].toLowerCase()))) continue;
			else if (!Data.data.settings.sectionInfo && (sectionExclude.contains(data[0].toLowerCase()))) continue;

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

	private function addUI():Void
	{
		add(buttons = new FlxTypedGroup<FlxButton>());

		buttons.add(refreshButton = new FlxButton(15, 15, 'Refresh', function ()
		{
			loadCharts();
			curSelected = -1;
			setInfo();
			trace('Refreshed!');
		}));

		addBox();
		add(chartsDrop = new FlxUIDropDownMenu(10, 60, FlxUIDropDownMenu.makeStrIdLabelArray(chartsList, true), function(_) setInfo()));
		add(loadedTxt = new Text(chartsDrop.x, chartsDrop.y - 20, FlxG.width, 'Currently loaded:', 11, LEFT, FlxColor.WHITE, OUTLINE, FlxColor.BLACK, 1));
		add(infoTxt = new Text(FlxG.width / 2 - 5, 20, FlxG.width / 2, '', 20, RIGHT, FlxColor.WHITE, OUTLINE, FlxColor.BLACK, 1.5));
		add(errors = new FlxTypedGroup<Error>(10));

		loadedTxt.font = null;
	}

	private function addBox():Void
	{
		var tabs = [
			{name: "Settings", label: 'Settings'},
			{name: "Generator", label: 'Generator'}
		];

		box = new FlxUITabMenu(null, tabs, true);
		box.resize(200, 200);
		box.setPosition(5, FlxG.height - box.height - 5);
		add(box);

		addSettings();
		addGenerator();
	}

	private function addSettings():Void
	{
		trace(Data.data.settings);

		var settingsTab = new FlxUI(null, box);
		settingsTab.name = "Settings";

		var check = new FlxUICheckBox(10, 10, null, null, "Skip intro", Std.int(box.width));
		check.checked = Data.data.settings.skip;
		check.callback = function()
		{
			Data.data.settings.skip = check.checked;
			Data.saveData();
		}
		settingsTab.add(check);

		var check = new FlxUICheckBox(10, 30, null, null, "Complex song info", Std.int(box.width));
		check.checked = Data.data.settings.songInfo;
		check.callback = function()
		{
			Data.data.settings.songInfo = check.checked;
			Data.saveData();
			curSelected = -1;
			setInfo();
		}
		settingsTab.add(check);

		var check = new FlxUICheckBox(10, 50, null, null, "Complex note info", Std.int(box.width));
		check.checked = Data.data.settings.noteInfo;
		check.callback = function()
		{
			Data.data.settings.noteInfo = check.checked;
			Data.saveData();
			curSelected = -1;
			setInfo();
		}
		settingsTab.add(check);

		var check = new FlxUICheckBox(10, 70, null, null, "Complex section info", Std.int(box.width));
		check.checked = Data.data.settings.sectionInfo;
		check.callback = function()
		{
			Data.data.settings.sectionInfo = check.checked;
			Data.saveData();
			curSelected = -1;
			setInfo();
		}
		settingsTab.add(check);

		var check = new Text(10, 90, box.width, 'FPS cap:', 8, LEFT, FlxColor.WHITE, NONE, FlxColor.TRANSPARENT, 0);
		check.font = FlxAssets.FONT_DEFAULT;
		settingsTab.add(check);

		var check = new FlxUINumericStepper(60, 90, 10, 60, 20, 320);
		check.value = Data.data.settings.fps;
		check.name = 'FPS cap:';
		settingsTab.add(check);

		box.addGroup(settingsTab);
	}

	private function addGenerator():Void
	{
		var generatorTab = new FlxUI(null, box);
		generatorTab.name = "Generator";

		var check = new Text(10, 10, box.width, 'Speed reduction:', 8, LEFT, FlxColor.WHITE, NONE, FlxColor.TRANSPARENT, 0);
		check.font = FlxAssets.FONT_DEFAULT;
		generatorTab.add(check);

		var reduction = new FlxUINumericStepper(100, 10, 0.1, 0, 0, 10, 1);
		reduction.name = 'Speed reduction:';
		generatorTab.add(reduction);

		var check = new Text(10, 30, box.width, 'Notes reduction:', 8, LEFT, FlxColor.WHITE, NONE, FlxColor.TRANSPARENT, 0);
		check.font = FlxAssets.FONT_DEFAULT;
		generatorTab.add(check);

		var notesReductionStepper = new FlxUINumericStepper(100, 30, 10 / 100, 0, 0, 90 / 100, 0, 1, null, null, null, true);
		notesReductionStepper.name = 'Notes reduction percent:';
		generatorTab.add(notesReductionStepper);

		var checkDoubles = new FlxUICheckBox(10, 55, null, null, "Remove double notes", Std.int(box.width));
		checkDoubles.checked = false;
		generatorTab.add(checkDoubles);

		function setSettings(speed:Float, notesReduction:Int, removeDoubles:Bool):Void
		{
			reduction.value = speed;
			notesReductionStepper.value = notesReduction / 100;
			checkDoubles.checked = removeDoubles;
		}

		var check = new FlxButton(15, 85, 'Default Easy Settings', function ()
		{
			setSettings(1, 70, true);

			trace('Set default easy settings');
		});
		check.label.color = FlxColor.LIME;
		check.label.borderStyle = OUTLINE;
		check.label.borderColor = FlxColor.BLACK;
		generatorTab.add(check);

		var check = new FlxButton(15, 85, 'Default Normal Settings', function ()
		{
			setSettings(0.5, 30, true);

			trace('Set default normal settings');
		});
		check.x = box.width - check.width - 15;
		check.label.color = FlxColor.YELLOW;
		check.label.borderStyle = OUTLINE;
		check.label.borderColor = FlxColor.BLACK;
		generatorTab.add(check);

		var check = new FlxButton(10, 115, 'Reset Settings', function ()
		{
			setSettings(0, 0, false);

			trace('Reseted settings');
		});
		check.x = box.width / 2 - check.width / 2;
		check.label.color = FlxColor.GRAY;
		check.label.borderStyle = OUTLINE;
		check.label.borderColor = FlxColor.BLACK;
		generatorTab.add(check);

		var check = new FlxButton(10, 0, 'Generate', function ()
		{
			trace('Generating chart');
		});
		check.y = box.height - (check.height * 2) - 5;
		generatorTab.add(check);

		// add "set recommended easy settings" and "set recommended normal settings" and "generate" button

		box.addGroup(generatorTab);
	}
}
