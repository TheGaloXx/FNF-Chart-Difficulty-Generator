import flixel.util.FlxStringUtil;
import haxe.Json;
import sys.*;
import sys.io.*;

using StringTools;

class Chart
{
    public var fileName:String;
    public var data:Dynamic;

    public var duration:String; // This just takes the strumTime from the last note in the chart, so it isnt the actual song's duration, more like "gameplay's" duration or something

    public var notesCount:Int;
    public var susSlices:Int;
    public var totalNotes:Int;
    public var susCount:Int;
    public var doublesCount:Int;

    public var sectionsCount:Int;
    public var averageCount:Int;

    public function new(song:String) 
    {
        getData(song);
    }

    // This is so messy I hate itttttttt but it works
    private function getData(song:String):Void
    {
        fileName = song;

        var file = (song == 'test' ? new TestChart().get() : File.getContent('charts/$song.json').trim());

        var lastDotIndex:Int = file.lastIndexOf("}") + 1;
		file = lastDotIndex != -1 ? file.substr(0, lastDotIndex) : file; // I think this is better than a while loop

        data = cast Json.parse(file).song;

        var emptySections:Int = 0;
        var lastNoteTime:Float = 0;
        var dadStrums:Array<Float> = [];
        var bfStrums:Array<Float> = [];

        for (section in cast (data.notes, Array<Dynamic>))
		{
            sectionsCount++;

            var sectionNotes = cast (section.sectionNotes, Array<Dynamic>);
            if (sectionNotes.length <= 0) emptySections++;

			for (songNotes in sectionNotes)
			{
                var strumTime:Float = (songNotes[0] < 0 ? 0 : songNotes[0]);
				var susLength:Float = songNotes[2] / (((60 / data.bpm) * 1000) / 4);
				var gottaHitNote:Bool = (songNotes[1] > 3 ? !section.mustHitSection : section.mustHitSection);

                // trace('Section: ${daChart.sectionsCount - 1} - Should hit: $gottaHitNote - BF Section: ${section.mustHitSection}');

				notesCount++;
                totalNotes++;

                if (susLength > 0)
                {
                    susCount++;
                    totalNotes++;
                }
	
                lastNoteTime = songNotes[0];

				for (i in 0...Math.floor(susLength))
				{
					susSlices++;
                    // totalNotes++; im not sure if counting this as a note, its just part of a hold note

                    lastNoteTime = songNotes[0];
				}

                var strumList:Array<Float> = (gottaHitNote ? bfStrums : dadStrums);
                if (strumList.contains(Math.round(strumTime))) doublesCount++;
                strumList.push(Math.round(strumTime));
			}
		}

        averageCount = Std.int(totalNotes / (sectionsCount - emptySections));
        duration = FlxStringUtil.formatTime(lastNoteTime / 1000);
    }

    /*
    *   
    * 
    */

    public function getProperty(property:String):String
    {
        // FINALLY GOT AROUND TO MAKE IT WORK GOD DAMMIT
        var fields = Reflect.fields(this);
        var field = fields[fields.indexOf(property)];
        var info = Std.string(Reflect.field(this, field));

        if (info == 'null' || info == null) info = Std.string(Reflect.getProperty(this.data, property));
        if (info == 'null' || info == null) info = '???';

        return info;
    }
}