import haxe.Json;
import sys.*;
import sys.io.*;

using StringTools;

class Chart
{
    public var data:Dynamic;

    public function new()
    {
        
    }

    public inline static function getData(song:String, daChart:Chart):Void
    {
        var file = File.getContent('charts/$song').trim();

        while (!file.endsWith("}")) file = file.substr(0, file.length - 1);

        daChart.data = cast Json.parse(file);
    }
}