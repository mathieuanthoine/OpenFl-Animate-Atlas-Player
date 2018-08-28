package animateAtlasPlayer.utils;


class StringUtil
{
    public static function format(format : String, args : Array<Dynamic> = null) : String
    // TODO: add number formatting options
    {        
        
        for (i in 0...args.length)
        {
            //TODO: format = format.replace(new EReg("\\{" + i + "\\}", "g"), args[i]);
        }
        
        return format;
    }
    
    public static function clean(string : String) : String
    {
        return ("_" + string).substr(1);
    }

    public static function trimStart(string : String) : String
    {
        var pos : Int;
        var length : Int = string.length;
        
        for (pos in 0...length)
        {
            if (string.charCodeAt(pos) > 0x20)
            {
                break;
            }
        }
        
        return string.substring(pos, length);
    }
    
    public static function trimEnd(string : String) : String
    {
        var pos : Int = cast(string.length - 1,Int);
        while (pos >= 0)
        {
            if (string.charCodeAt(pos) > 0x20)
            {
                break;
            }
            --pos;
        }
        
        return string.substring(0, pos + 1);
    }
    
    public static function trim(string : String) : String
    {
        var startPos : Int;
        var endPos : Int;
        var length : Int = string.length;
        
        for (startPos in 0...length)
        {
            if (string.charCodeAt(startPos) > 0x20)
            {
                break;
            }
        }
        
        endPos = cast(string.length - 1,Int);
        while (endPos >= startPos)
        {
            if (string.charCodeAt(endPos) > 0x20)
            {
                break;
            }
            --endPos;
        }
        
        return string.substring(startPos, endPos + 1);
    }
    
    public static function parseBoolean(value : String) : Bool
    {
        return value == "true" || value == "TRUE" || value == "True" || value == "1";
    }
}

