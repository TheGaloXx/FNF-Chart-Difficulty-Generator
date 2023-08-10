import haxe.Json;
import sys.*;
import sys.io.*;

using StringTools;

class Chart
{
    public var data:Dynamic;
    public var notesCount:Int;
    public var susCount:Int;
    public var totalNotes:Int;

    public function new()
    {
        
    }

    public inline static function getData(song:String, daChart:Chart):Void
    {
        var file = (song == 'test' ? new TestChart().get() : File.getContent('charts/$song.json').trim());

        while (!file.endsWith("}")) file = file.substr(0, file.length - 1);

        daChart.notesCount = 0;
        daChart.susCount = 0;
        daChart.totalNotes = 0;
        daChart.data = cast Json.parse(file).song;

        for (section in cast (daChart.data.notes, Array<Dynamic>))
		{
			for (songNotes in cast (section.sectionNotes, Array<Dynamic>))
			{
				var susLength:Float = songNotes[2] / (((60 / daChart.data.bpm) * 1000) / 4);

				daChart.notesCount++;
                daChart.totalNotes++;
	
				for (i in 0...Math.floor(susLength))
				{
					daChart.susCount++;
                    daChart.totalNotes++;
				}
			}
		}
    }
}