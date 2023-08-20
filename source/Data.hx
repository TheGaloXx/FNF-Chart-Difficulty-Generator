package;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class Data
{
    public static var data:Dynamic;

    inline public static function getData():Void
    {
        var file = File.getContent('data.json').trim();
        data = cast Json.parse(file);

        Main.changeFPS(Data.data.settings.fps);
    }

    inline public static function saveData():Void
    {
        var json = {
			"settings": 
            {
                "skip": data.settings.skip,
                "songInfo": data.settings.songInfo,
                "noteInfo": data.settings.noteInfo,
                "sectionInfo": data.settings.sectionInfo,
                "fps": data.settings.fps,
		    }
        };

        File.saveContent('data.json', Json.stringify(json, '\t'));
    }

    inline public static function check():Void
    {
        if (!FileSystem.exists('data.json'))
        {
            var json = {
                "settings": 
                {
                    "skip": false,
                    "songInfo": true,
                    "noteInfo": true,
                    "sectionInfo": true,
                    "fps": 60
                }
            };
    
            File.saveContent('data.json', Json.stringify(json, '\t'));
        }
    }
}