package animateAtlasPlayer.assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.ByteArray;
import animateAtlasPlayer.textures.TextureAtlas;

/** An enumeration class containing all the asset types supported by the AssetManager. */
class AssetType
{
    
    public static inline var TEXTURE : String = "texture";
    public static inline var TEXTURE_ATLAS : String = "textureAtlas";
    public static inline var SOUND : String = "sound";
    public static inline var XML_DOCUMENT : String = "xml";
    public static inline var OBJECT : String = "object";
    public static inline var BYTE_ARRAY : String = "byteArray";
    public static inline var BITMAP_FONT : String = "bitmapFont";
    public static inline var ASSET_MANAGER : String = "assetManager";
    
    /** Figures out the asset type string from the type of the given instance. */
    public static function fromAsset(asset : Dynamic) : String
    {
        if (Std.is(asset, BitmapData))
        {
            return TEXTURE;
        }
        else if (Std.is(asset, TextureAtlas))
        {
            return TEXTURE_ATLAS;
        }
        else if (Std.is(asset, Sound))
        {
            return SOUND;
        }
        //else if (Std.is(asset, FastXML))
        //{
            //return XML_DOCUMENT;
        //}
        else if (Std.is(asset, ByteArray))
        {
            return BYTE_ARRAY;
        }
        //else if (Std.is(asset, BitmapFont))
        //{
            //return BITMAP_FONT;
        //}
        else if (Std.is(asset, AssetManager))
        {
            return ASSET_MANAGER;
        }
        else
        {
            return OBJECT;
        }
    }
}

