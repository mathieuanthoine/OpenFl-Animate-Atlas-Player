package starling.extensions.animate;
import js.Lib;
import starling.assets.AssetManager;
import starling.assets.JsonFactory;


class AssetManagerEx extends AssetManager
{
    // helper objects
    private static var sNames : Array<String> = [];
    
    public function new()
    {
        super();
        registerFactory(new AnimationAtlasFactory(), 10);
    }
    
    override public function addAsset(name : String, asset : Dynamic, type : String = null) : Void
    {
        if (type == null && Std.is(asset, AnimationAtlas))
        {
            type = AnimationAtlas.ASSET_TYPE;
        }
        
        super.addAsset(name, asset, type);
    }
    
    /** Returns an animation atlas with a certain name, or null if it's not found. */
    public function getAnimationAtlas(name : String) : AnimationAtlas
    {
        return cast getAsset(AnimationAtlas.ASSET_TYPE, name);
    }
    
    /** Returns all animation atlas names that start with a certain string, sorted alphabetically.
     *  If you pass an <code>out</code>-vector, the names will be added to that vector. */
    public function getAnimationAtlasNames(prefix : String = "", out : Array<String> = null) : Array<String>
    {	
		return getAssetNames(AnimationAtlas.ASSET_TYPE, prefix, true, out);
    }
    
    public function createAnimation(name : String) : Animation
    {
        	
		var atlasNames : Array<String> = getAnimationAtlasNames("", sNames);
        var animation : Animation = null;
        for (atlasName in atlasNames)
        {
            var atlas : AnimationAtlas = getAnimationAtlas(atlasName);
            if (atlas.hasAnimation(name))
            {
				trace ("hey");
				animation = atlas.createAnimation(name);
				trace (animation);
                break;
            }
        }
        //
        //if (animation == null && Lambda.indexOf(atlasNames, name) != -1)
        //{
            //animation = getAnimationAtlas(name).createAnimation();
        //}
        //
        sNames=[];
        return animation;
    }
    
    override private function getNameFromUrl(url : String) : String
    {
        var defaultName : String = super.getNameFromUrl(url);
        var separator : String = "/";
        
        if (defaultName == "Animation" || defaultName == "spritemap" &&
            url.indexOf(separator) != -1)
        {
            var elements : Array<Dynamic> = url.split(separator);
            var folderName : String = elements[elements.length - 2];
            var suffix : String = (defaultName == "Animation") ? AnimationAtlasFactory.ANIMATION_SUFFIX : "";
            return super.getNameFromUrl(folderName + suffix);
        }
        
        return defaultName;
    }
}