package animateAtlasPlayer.core;

import openfl.errors.ArgumentError;
import starling.errors.AbstractClassError;

class SymbolType
{
    /** @private */
    @:allow(animateAtlasPlayer.core)
    private function new()
    {
        throw new AbstractClassError();
    }

    public static inline var GRAPHIC:String = "graphic";
    public static inline var MOVIE_CLIP:String = "movieclip";
    public static inline var BUTTON:String = "button";

    public static function isValid(value:String):Bool
    {
        return value == GRAPHIC || value == MOVIE_CLIP || value == BUTTON;
    }

    public static function parse(value:String):String
    {
        switch (value)
        {
            case "G":
                return GRAPHIC;
            case GRAPHIC:
                return GRAPHIC;
            case "MC":
                return MOVIE_CLIP;
            case MOVIE_CLIP:
                return MOVIE_CLIP;
            case "B":
                return BUTTON;
            case BUTTON:
                return BUTTON;
            default:
                throw new ArgumentError("Invalid symbol type: " + value);
        }
    }
}