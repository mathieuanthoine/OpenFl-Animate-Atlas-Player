package animateAtlasPlayer.core;

import animateAtlasPlayer.textures.TextureAtlas;
import openfl.errors.Error;
import animateAtlasPlayer.assets.AssetManager;
import animateAtlasPlayer.assets.AssetReference;
import animateAtlasPlayer.assets.JsonFactory;
import haxe.Json;
import openfl.display.BitmapData;

class AnimationAtlasFactory extends JsonFactory
{
    public static inline var ANIMATION_SUFFIX : String = "_animation";
    public static inline var SPRITEMAP_SUFFIX : String = "_spritemap";
    
    override public function create(reference : AssetReference,assets:AssetManager/*, helper : AssetFactoryHelper, onComplete : Function, onError : Function*/) : Void
    {
        super.create(reference,assets/*, helper, onObjectComplete, onError*/);
		var json:Dynamic = reference.data;

		var baseName:String = getName(null, reference.name, false);

		if (json.ATLAS != null && json.meta != null)
		{
			var texture:BitmapData = assets.getTexture(baseName);
			if (texture == null)
				throw new Error("Missing texture " + baseName);
			else
				assets.addAsset(baseName, new JsonTextureAtlas(texture, json));

		}
		else if ((json.ANIMATION != null && json.SYMBOL_DICTIONARY != null) || (json.AN != null && json.SD != null))
		{
			var atlas:TextureAtlas = assets.getTextureAtlas(baseName);
			if (atlas == null)
				throw new Error("Missing texture atlas " + baseName);
			else
				assets.addAsset(baseName, new AnimationAtlas(json, atlas), AnimationAtlas.ASSET_TYPE);
		}
    }

	public static function getName(url:String, stdName:String, addSuffix:Bool):String
	{
		var separator:String = "/";

		// embedded classes are stripped of the suffix here
		if (url == null)
		{
			if (addSuffix)
			{
				return stdName; // should already include suffix
			} else {
				stdName = StringTools.replace(stdName, AnimationAtlasFactory.ANIMATION_SUFFIX, "");
				stdName = StringTools.replace(stdName, AnimationAtlasFactory.SPRITEMAP_SUFFIX, "");
			}
		}

		//if ((stdName == "Animation" || stdName.match(/spritemap\d*/)) && url.indexOf(separator) != -1)
		//todo fix this

		if (stdName == "Animation" || stdName.indexOf("spritemap") != -1 && url.indexOf(separator) != -1)
		{
			var elements:Array<String> = url.split(separator);
			var folderName:String = elements[Std.int(elements.length - 2)];
			var suffix:String = stdName == "Animation" ? AnimationAtlasFactory.ANIMATION_SUFFIX : AnimationAtlasFactory.SPRITEMAP_SUFFIX;

			if (addSuffix)
				return folderName + suffix;
			else
				return folderName;
		}

		return stdName;
	}

    public function new()
    {
        super();
    }

}