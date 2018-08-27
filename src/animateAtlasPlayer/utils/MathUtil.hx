package animateAtlasPlayer.utils;

/** A utility class containing methods you might need for math problems. */
class MathUtil
{   
    
    /** Moves <code>value</code> into the range between <code>min</code> and <code>max</code>. */
    public static function clamp(value : Float, min : Float, max : Float) : Float
    {
        return (value < min) ? min : ((value > max) ? max : value);
    }
}
