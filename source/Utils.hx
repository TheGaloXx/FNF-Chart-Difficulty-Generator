package;

import lime.utils.Assets;

using StringTools;

class Utils
{
    inline public static function textFile(path:String):Array<String>
    {
        var daList:Array<String> = Assets.getText(path).trim().split('\n');

        for (i in 0...daList.length) daList[i] = daList[i].trim();

        return daList;
    }
}