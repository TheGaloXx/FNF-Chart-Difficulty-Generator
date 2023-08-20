package substates;

import Objects.Text;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class PopupSubstate extends FlxSubState
{
    private var song:String;
    private var speed:Float;
    private var notesPercent:Float;
    private var removeDoubles:Bool;
    private var chart:Chart;

    public function new(song:String, speed:Float, notesPercent:Float, removeDoubles:Bool)
    {
        super();

        this.song = song;
        this.speed = speed;
        this.notesPercent = notesPercent;
        this.removeDoubles = removeDoubles;
        this.chart = null;
    }

    override function create():Void
    {
        chart = new Chart(song);

        var bg = new FlxSprite(10, 10).makeGraphic(FlxG.width - 20, FlxG.height - 20, FlxColor.BLACK);
        bg.active = false;
        bg.alpha = 0.85;
        add(bg);

        var button = new FlxButton(0, 0, 'Generate', function()
        {
            Data.saveChart(chart);
        });
        button.screenCenter(X);
        button.y = bg.y + bg.height - button.height - 15;
        add(button);

        var back = new FlxButton(0, 0, 'Go back', function()
        {
            close();
        });
        back.setPosition(bg.x + bg.width - back.width - 15, bg.y + 15);
        add(back);

        var text:String = '${getVariable('speed')}\n\n${getVariable('notes')}\n\n${getVariable('doubles')}';

        var infoTxt = new Text(bg.x + 10, bg.y + 5, bg.width, text, 26, LEFT, FlxColor.WHITE, OUTLINE, FlxColor.BLACK, 1.5);
        add(infoTxt);
        infoTxt.applyMarkup(text, [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "/r/")]);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.anyJustPressed([BACKSPACE, ESCAPE])) close();
    }

    private function getVariable(variable:String):String
    {
        var text:String = '';

        switch (variable.toLowerCase())
        {
            case 'speed':
                if (speed == 0)
                    text = 'Same scroll speed';
                else
                    text = 'Scroll speed: ${chart.data.speed} -> /r/${chart.data.speed - speed}/r/';

            case 'notes':
                if (notesPercent == 0) 
                    text = 'Same amount of notes';
                else
                    text = 'Notes:        ${chart.totalNotes} -> /r/${chart.totalNotes - Std.int(chart.totalNotes * notesPercent)}/r/ aprox.';

            case 'doubles':
                text = 'Double notes: ${(removeDoubles ? '/r/disabled/r/' : 'enabled')}';
        }

        return text;
    }
}