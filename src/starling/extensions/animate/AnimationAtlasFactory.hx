package starling.extensions.animate;

import haxe.Json;
import js.Lib;
import openfl.display.BitmapData;
import starling.assets.AssetManager;
import starling.assets.AssetReference;
import starling.assets.JsonFactory;

class AnimationAtlasFactory extends JsonFactory
{
    public static inline var ANIMATION_SUFFIX : String = "_animation";
    public static inline var SPRITEMAP_SUFFIX : String = "_spritemap";
    
    override public function create(reference : AssetReference,assets:AssetManager/*, helper : AssetFactoryHelper, onComplete : Function, onError : Function*/) : Void
    {
        super.create(reference,assets/*, helper, onObjectComplete, onError*/);
		
		var name:String = reference.name;
		var json:Json = reference.data;
		
		assets.addAsset(name, json);
        
		if (Reflect.hasField(json,"ATLAS") && Reflect.hasField(json,"meta"))
		{
			if (name.indexOf(SPRITEMAP_SUFFIX) == name.length - SPRITEMAP_SUFFIX.length)
			{
				name = name.substr(0, name.length - SPRITEMAP_SUFFIX.length);
			}
			
			var texture : BitmapData = assets.getTexture(name);

			assets.addAsset(name, new JsonTextureAtlas(texture, json));

		}
		else if (Reflect.hasField(json,"ANIMATION") && Reflect.hasField(json,"SYMBOL_DICTIONARY"))
		{
			var suffixIndex : Int = name.indexOf(ANIMATION_SUFFIX);
			var baseName : String = name.substr(0,(suffixIndex >= 0) ? suffixIndex : 2147483647);
			assets.addAsset(baseName, new AnimationAtlas(json, assets.getTextureAtlas(baseName)), AnimationAtlas.ASSET_TYPE);
		}
    }

    public function new()
    {
        super();
    }
}