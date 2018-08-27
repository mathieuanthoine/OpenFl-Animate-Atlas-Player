package animateAtlasPlayer.utils;

/** A utility class with methods related to the String class. */
class StringUtil
{
    /** Formats a String in .Net-style, with curly braces ("{0}"). Does not support any
     *  number formatting options yet. */
    public static function format(format : String, args : Array<Dynamic> = null) : String
    // TODO: add number formatting options
    {        
        
        for (i in 0...args.length)
        {
            //TODO: format = format.replace(new EReg("\\{" + i + "\\}", "g"), args[i]);
        }
        
        return format;
    }
    
    /** Replaces a string's "master string" — the string it was built from —
     *  with a single character to save memory. Find more information about this AS3 oddity
     *  <a href="http://jacksondunstan.com/articles/2260">here</a>.
     *
     *  @param  string The String to clean
     *  @return The input string, but with a master string only one character larger than it.
     *  @author Jackson Dunstan, JacksonDunstan.com
     */
    public static function clean(string : String) : String
    {
        return ("_" + string).substr(1);
    }
    
    /** Removes all leading white-space and control characters from the given String.
     *
     *  <p>Beware: this method does not make a proper Unicode white-space check,
     *  but simply trims all character codes of '0x20' or below.</p>
     */
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
    
    /** Removes all trailing white-space and control characters from the given String.
     *
     *  <p>Beware: this method does not make a proper Unicode white-space check,
     *  but simply trims all character codes of '0x20' or below.</p>
     */
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
    
    /** Removes all leading and trailing white-space and control characters from the given
     *  String.
     *
     *  <p>Beware: this method does not make a proper Unicode white-space check,
     *  but simply trims all character codes of '0x20' or below.</p>
     */
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
    
    /** Returns <code>true</code> if <code>value</code> equals
     *  <code>true, TRUE, True, or 1</code>.
     */
    public static function parseBoolean(value : String) : Bool
    {
        return value == "true" || value == "TRUE" || value == "True" || value == "1";
    }
}

