package animateAtlasPlayer.assets;

import haxe.Json;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.events.EventDispatcher;
import openfl.utils.ByteArray;
import animateAtlasPlayer.core.Animation;
import animateAtlasPlayer.core.AnimationAtlas;
import animateAtlasPlayer.core.AnimationAtlasFactory;
import animateAtlasPlayer.textures.TextureAtlas;
import animateAtlasPlayer.utils.ArrayUtil;

class AssetManager extends EventDispatcher
{
	
	public var verbose(get, set) : Bool;
    public var numQueuedAssets(get, never) : Int;
    public var numConnections(get, set) : Int;
    //public var textureOptions(get, set) : TextureOptions;
    //public var dataLoader(get, set) : DataLoader;
    public var registerBitmapFontsWithFontFace(get, set) : Bool;

    //private var _animateAtlasPlayer : animateAtlasPlayer;
    private var _assets : Map<String,Map<String,Dynamic>>;
    private var _verbose : Bool;
    private var _numConnections : Int;
    //private var _dataLoader : DataLoader;
    //private var _textureOptions : TextureOptions;
    private var _queue : Array<AssetReference>;
    private var _registerBitmapFontsWithFontFace : Bool;
    private var _assetFactories : Array<AssetFactory>;
    private var _numRestoredTextures : Int;
    private var _numLostTextures : Int;
    
    // Regex for name / extension extraction from URLs.
    private static var NAME_REGEX : EReg = new EReg('([^?\\/\\\\]+?)(?:\\.([\\w\\-]+))?(?:\\?.*)?$', "");
    
    // fallback for unnamed assets
    private static inline var NO_NAME : String = "unnamed";
    private static var sNoNameCount : Int = 0;
    
    // helper objects
    private static var sNames : Array<String> = [];
    
    /** Create a new instance with the given scale factor. */
    public function new(scaleFactor : Float = 1)
    {
        super();
        _assets = new Map<String,Map<String,Dynamic>>();
        _verbose = true;
        //_textureOptions = new TextureOptions(scaleFactor);
        _queue = [];
        _numConnections = 3;
        //_dataLoader = new DataLoader();
        _assetFactories = [];
        
        //registerFactory(new BitmapTextureFactory());
        //registerFactory(new AtfTextureFactory());
        //registerFactory(new SoundFactory());
        registerFactory(new JsonFactory());
        //registerFactory(new XmlFactory());
        //registerFactory(new ByteArrayFactory(), -100);
		registerFactory(new AnimationAtlasFactory(), 10);
    }
    
    /** Disposes all assets and purges the queue.
     *
     *  <p>Beware that all references to the assets will remain intact, even though the assets
     *  are no longer valid. Call 'purge' if you want to remove all resources and reuse
     *  the AssetManager later.</p>
     */
    //public function dispose() : Void
    //{
        //purgeQueue();
        //
        //for (store/* AS3HX WARNING could not determine type for var: store exp: EIdent(_assets) type: Dynamic */ in _assets)
        //{
            //for (asset/* AS3HX WARNING could not determine type for var: asset exp: EIdent(store) type: null */ in store)
            //{
                //disposeAsset(asset);
            //}
        //}
    //}
    
    /** Removes assets of all types (disposing them along the way), empties the queue and
     *  aborts any pending load operations. */
    //public function purge() : Void
    //{
        //log("Purging all assets, emptying queue");
        //
        //purgeQueue();
        //dispose();
        //
        //_assets = new Map<String,Map<String,Dynamic>>();
    //}

    
    /** Enqueues a single asset with a custom name that can be used to access it later.
     *  If the asset is a texture, you can also add custom texture options.
     *
     *  @param asset    The asset that will be enqueued; accepts the same objects as the
     *                  'enqueue' method.
     *  @param name     The name under which the asset will be found later. If you pass null or
     *                  omit the parameter, it's attempted to generate a name automatically.
     *  @param options  Custom options that will be used if 'asset' points to texture data.
     *  @return         the name with which the asset was registered.
     */
    public function enqueueSingle(url : String, name : String = null/*, options : TextureOptions = null*/) : String
    {

		var asset = getExtensionFromUrl(url) == "json" ? Json.parse(Assets.getText(url)) : Assets.getBitmapData(url);
		
        var assetReference : AssetReference = new AssetReference(asset);
        if (name != null) assetReference.name = name;
		else assetReference.name =  getNameFromUrl(url);
        assetReference.extension = getExtensionFromUrl(url);
       // assetReference.textureOptions = options || _textureOptions;
        
        _queue.push(assetReference);
        trace("Enqueuing '" + assetReference.filename + "'");
        return assetReference.name;
    }
    
    /** Empties the queue and aborts any pending load operations. */
    //public function purgeQueue() : Void
    //{
        //as3hx.Compat.setArrayLength(_queue, 0);
        //_dataLoader.close();
       //dispatchEventWith(Event.CANCEL);
    //}
    
    /** Loads all enqueued assets asynchronously. The 'onComplete' callback will be executed
     *  once all assets have been loaded - even when there have been errors, which are
     *  forwarded to the optional 'onError' callback. The 'onProgress' function will be called
     *  with a 'ratio' between '0.0' and '1.0' and is also optional.
     *
     *  <p>When you call this method, the manager will save a reference to "animateAtlasPlayer.current";
     *  all textures that are loaded will be accessible only from within this instance. Thus,
     *  if you are working with more than one animateAtlasPlayer instance, be sure to call
     *  "makeCurrent()" on the appropriate instance before processing the queue.</p>
     *
     *  @param onComplete   <code>function(manager:AssetManager):void;</code> - parameter is optional!
     *  @param onError      <code>function(error:String):void;</code>
     *  @param onProgress   <code>function(ratio:Number):void;</code>
     */
    public function loadQueue(onComplete : Dynamic, onError : Dynamic = null, onProgress : Dynamic = null) : Void
    {
		var asset:AssetReference;
		for (i in 0..._queue.length) {
			asset = _queue[i];		
			var assetFactory : AssetFactory = getFactoryFor(asset);		
			if (assetFactory == null)
			{
				trace("Warning: no suitable factory found for '" + asset.name + "'");
			}
			else
			{
				assetFactory.create(asset, this/*, helper, onComplete, onCreateError*/);			
			}
			
		}
		
		//for (i in 0..._queue.length) {
			//asset = _queue[i];
			//addAsset(asset.name, asset.data);
		//}
		
		_queue = [];
		
		onComplete(this);
		
		//if (_queue.length == 0)
        //{
            //finish();
            //return;
        //}
        
        // By using an event listener, we can make a call to "cancel" affect
        // only the currently active loading process(es).
        //addEventListener(Event.CANCEL, untyped onCanceled);
        
        //var factoryHelper : AssetFactoryHelper = new AssetFactoryHelper();
        //factoryHelper.getNameFromUrlFunc = getNameFromUrl;
        //factoryHelper.getExtensionFromUrlFunc = getExtensionFromUrl;
        //factoryHelper.addPostProcessorFunc = addPostProcessor;
        //factoryHelper.addAssetFunc = addAsset;
        //factoryHelper.onRestoreFunc = onAssetRestored;
        //factoryHelper.dataLoader = _dataLoader;
        //factoryHelper.logFunc = log;
        
        //var i : Int;
        //self = this;
        //
        //queue = _queue.copy();
        //numAssets = queue.length;
        //numComplete = 0;
        //numConnections = Std.int(Math.min(_numConnections, numAssets));
        //assetProgress = new Array<Float>();
        //postProcessors = [];
        //
        //_queue = [];
        //
        //for (i in 0...numAssets)
        //{
            //assetProgress[i] = -1;
        //}
        //
        //for (i in 0...numConnections)
        //{
            //loadNextAsset();
        //}
  
    }
	
	//private var canceled : Bool = false;
	//private var queue : Array<AssetReference>;
    //private var numAssets : Int;
    //private var numComplete : Int;
    //private var assetProgress : Array<Float>;
    //private var postProcessors : Array<AssetPostProcessor>;
	//private var onProgress: Dynamic;
	//private var onComplete:Dynamic;
	//private var onError:Dynamic;
	//private var self : AssetManager;
	//
	//private function finish () : Void
	//{
		//onCanceled();
		//onProgress(1.0);
		////execute(onProgress, 1.0);
		//onComplete(self);
		////execute(onComplete, self);
	//}
	//
	//private function onCanceled () : Void
	//{
		//canceled = true;
		////TODO: removeEventListener attend normalement une callback avec arguments
		//removeEventListener(Event.CANCEL, untyped onCanceled);
	//}
	//
	//private function runPostProcessors() : Void
	//{
		//if (!canceled)
		//{
			//if (postProcessors.length)
			//{
				//try
				//{
					//postProcessors.shift().execute(self);
				//}
				//catch (e : Error)
				//{
					//onError(e.message);
				//}
				//
				//runPostProcessors();
			//}
			//else
			//{
				//finish();
			//}
		//}
	//}
	//
	//private function onAssetLoadError (error : String) : Void
	//{
		//if (!canceled)
		//{
			//onError(error);
			//onAssetLoaded();
		//}
	//}
        //
    //private function onAssetProgress (ratio : Float) : Void
	//{
		//if (!canceled)
		//{
			//onProgress(ratio * 0.95);
		//}
	//}
        //
    //private function addPostProcessor (processorFunc : Dynamic, priority : Int) : Void
	//{
		//postProcessors.push(new AssetPostProcessor(processorFunc, priority));
	//}
	//
	//private function loadNextAsset() : Void
	//{
		//if (canceled)
		//{
			//return;
		//}
		//
		//for (j in 0...numAssets)
		//{
			//if (assetProgress[j] < 0)
			//{
				//loadFromQueue(queue, assetProgress, j, factoryHelper, 
						//onAssetLoaded, onAssetProgress, onAssetLoadError, onError
			//);
				//break;
			//}
		//}
	//}
	//
	//private function onAssetLoaded(name : String = null, asset : Dynamic = null) : Void
	//{
		//if (canceled && asset != null)
		//{
			////TODO: disposeAsset(asset);
		//}
		//else
		//{
			//if (name != null && asset != null)
			//{
				//addAsset(name, asset);
			//}
			//numComplete++;
			//
			//if (numComplete == numAssets)
			//{
				//postProcessors.sort(comparePriorities);
				//runPostProcessors();
			//}
			//else
			//{
				//loadNextAsset();
			//}
		//}
	//}
    //
    //private function loadFromQueue(queue : Array<AssetReference>, progressRatios : Array<Float>, index : Int,helper : AssetFactoryHelper, onComplete : Dynamic, onProgress : Dynamic, onError : Dynamic, onIntermediateError : Dynamic) : Void
    //{
        //var assetCount : Int = queue.length;
        //var asset : AssetReference = queue[index];
        //progressRatios[index] = 0;
        //
        ////if (asset.url)
        ////{
            ////_dataLoader.load(asset.url, onLoadComplete, onLoadError, onLoadProgress);
        ////}
        ////else if (Std.is(asset.data, AssetManager))
        ////{
            ////cast(asset.data, AssetManager).loadQueue(onManagerComplete, onIntermediateError, onLoadProgress);
        ////}
        ////else
        ////{
            //onLoadComplete([asset.data]);
        ////}
        //
        //
    //}
	//
	//private function onLoadComplete(data : Dynamic, mimeType : String = null, name : String = null, extension : String = null) : Void
	//{
		////if (_animateAtlasPlayer != null)
		////{
			////_animateAtlasPlayer.makeCurrent();
		////}
		//
		////onLoadProgress(1.0);
		//
		//if (data != null)
		//{
			//asset.data = data;
		//}
		//if (name != null)
		//{
			//asset.name = name;
		//}
		//if (extension != null)
		//{
			//asset.extension = extension;
		//}
		//if (mimeType != null)
		//{
			//asset.mimeType = mimeType;
		//}
		//
		//var assetFactory : AssetFactory = getFactoryFor(asset);
		//if (assetFactory == null)
		//{
			//onAnyError("Warning: no suitable factory found for '" + asset.name + "'");
		//}
		//else
		//{
			//assetFactory.create(asset, helper, onComplete, onCreateError);
		//}
	//}
        
    //private function onLoadProgress(ratio : Float) : Void
	//{
		//progressRatios[index] = ratio;
		//
		//var totalRatio : Float = 0;
		//var multiplier : Float = 1.0 / assetCount;
		//
		//for (k in 0...assetCount)
		//{
			//var r : Float = progressRatios[k];
			//if (r > 0)
			//{
				//totalRatio += multiplier * r;
			//}
		//}
		//
		//onProgress(Math.min(totalRatio, 1.0));
	//}
        //
    //private function onLoadError(error : String) : Void
	//{
		//onLoadProgress(1.0);
		//onAnyError("Error loading " + asset.name + ": " + error);
	//}
        //
    //private function onCreateError(error : String) : Void
	//{
		//onAnyError("Error creating " + asset.name + ": " + error);
	//}
        //
    //private function onAnyError(error : String) : Void
	//{
		//log(error);
		//onError(error);
	//}
        //
    //private function onManagerComplete() : Void
	//{
		//onComplete( asset.name, asset.data);
	//}
    
    private function getFactoryFor(asset : AssetReference) : AssetFactory
    {
        //var numFactories : Int = _assetFactories.length;
        //for (i in 0...numFactories)
        //{
            //var factory : AssetFactory = _assetFactories[i];
            //if (factory.canHandle(asset))
            //{
                //return factory;
            //}
        //}
		
		var lFactory:AssetFactory = asset.extension == "json" ? new AnimationAtlasFactory() : new BitmapTextureFactory(); 
		return lFactory;
		//return null;
    }
    
    //private function onAssetRestored(finished : Bool) : Void
    //{
        //if (finished)
        //{
            //_numRestoredTextures++;
            //
            //if (_animateAtlasPlayer != null)
            //{
                //_animateAtlasPlayer.stage.setRequiresRedraw();
            //}
            //
            //if (_numRestoredTextures == _numLostTextures)
            //{
                //dispatchEventWith(Event.TEXTURES_RESTORED);
            //}
        //}
        //else
        //{
            //_numLostTextures++;
        //}
    //}
    
    // basic accessing methods
    
    /** Add an asset with a certain name and type.
     *
     *  <p>Beware: if the slot (name + type) was already taken, the existing object will be
     *  disposed and replaced by the new one.</p>
     *
     *  @param name    The name with which the asset can be retrieved later. Must be
     *                 unique within this asset type.
     *  @param asset   The actual asset to add (e.g. a texture, a sound, etc).
     *  @param type    The type of the asset. If omitted, the type will be determined
     *                 automatically (which works for all standard types defined within
     *                 the 'AssetType' class).
     */
    public function addAsset(name : String, asset : Dynamic, type : String = null) : Void
    {
        if (type == null && Std.is(asset, AnimationAtlas))
        {
            type = AnimationAtlas.ASSET_TYPE;
        }
		
		type = (type != null) ? type : AssetType.fromAsset(asset);
        
        var store : Map<String,Dynamic> = _assets[type];
        if (store == null)
        {
            store = new Map<String,Dynamic>();
            _assets[type]= store;
        }
        
        trace("Adding " + type + " '" + name + "'");
        
        var prevAsset : Map<String,Dynamic> = store[name];
        if (prevAsset != null && prevAsset != asset)
        {
            log("Warning: name was already in use; disposing the previous " + type);
            //TODO: disposeAsset(prevAsset);
        }
        
        store[name]= asset;
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
				animation = atlas.createAnimation(name);
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
    
    /** Retrieves an asset of the given type, with the given name. If 'recursive' is true,
     *  the method will traverse included texture atlases and asset managers.
     *
     *  <p>Typically, you will use one of the type-safe convenience methods instead, like
     *  'getTexture', 'getSound', etc.</p>
     */
    public function getAsset(type : String, name : String, recursive : Bool = true) : Dynamic
    {

		if (recursive)
        {

            var managerStore : Map<String,Dynamic> = _assets[AssetType.ASSET_MANAGER];
            if (managerStore != null)
            {
				for (manager in managerStore)
                {
                    var asset : Dynamic = manager.getAsset(type, name, true);
                    if (asset != null)
                    {
                        return asset;
                    }
                }
            }

			
            if (type == AssetType.TEXTURE)
            {

				var atlasStore : Map<String,Dynamic> = _assets[AssetType.TEXTURE_ATLAS];
                if (atlasStore != null)
                {
                    for (atlas in atlasStore)
                    {
                        var texture : BitmapData = atlas.getTexture(name);
                        if (texture != null)
                        {
                            return texture;
                        }
                    }
                }
            }
        }
		var store : Map<String,Dynamic> = _assets[type];
        if (store != null)
        {
            return store[name];
        }
        else
        {
            return null;
        }
    }
    
    /** Retrieves an alphabetically sorted list of all assets that have the given type and
     *  start with the given prefix. If 'recursive' is true, the method will traverse included
     *  texture atlases and asset managers. */
    public function getAssetNames(assetType : String, prefix : String = "", recursive : Bool = true,
            out : Array<String> = null) : Array<String>
    {
        out = (out != null) ? out : new Array<String>();
        
        if (recursive)
        {
            var managerStore : Map<String,Dynamic> = _assets[AssetType.ASSET_MANAGER];
            if (managerStore != null)
            {
                for (manager in managerStore)
                {
                    manager.getAssetNames(assetType, prefix, true, out);
                }
            }
            
            if (assetType == AssetType.TEXTURE)
            {
                var atlasStore : Map<String,Dynamic> = _assets[AssetType.TEXTURE_ATLAS];
                if (atlasStore != null)
                {
                    for (atlas in atlasStore)
                    {
                        atlas.getNames(prefix, out);
                    }
                }
            }
        }
		
	
        getDictionaryKeys(_assets[assetType], prefix, out);
		out.sort(ArrayUtil.CASEINSENSITIVE);
		
        return out;
    }
    
    /** Removes the asset with the given name and type, and will optionally dispose it. */
    //public function removeAsset(assetType : String, name : String, dispose : Bool = true) : Void
    //{
        //var store : Dynamic = Reflect.field(_assets, assetType);
        //if (store != null)
        //{
            //var asset : Dynamic = Reflect.field(store, name);
            //if (asset != null)
            //{
                //log("Removing " + assetType + " '" + name + "'");
                //if (dispose)
                //{
                    //disposeAsset(asset);
                //}
				//
				//Reflect.deleteField(store, name);
            //}
        //}
    //}
    
    // convenience access methods
    
    /** Returns a texture with a certain name. Includes textures stored inside atlases. */
    public function getTexture(name : String) : BitmapData
    {
        return cast getAsset(AssetType.TEXTURE, name);
    }
    
    /** Returns all textures that start with a certain string, sorted alphabetically
     *  (especially useful for "MovieClip"). Includes textures stored inside atlases. */
    public function getTextures(prefix : String = "", out : Array<BitmapData> = null) : Array<BitmapData>
    {
        if (out == null)
        {
            out = [];
        }
        
        for (name/* AS3HX WARNING could not determine type for var: name exp: ECall(EIdent(getTextureNames),[EIdent(prefix),EIdent(sNames)]) type: null */ in getTextureNames(prefix, sNames))
        {
            out[out.length] = getTexture(name);
        }  // avoid 'push'  
        
		sNames = [];
        return out;
    }
    
    /** Returns all texture names that start with a certain string, sorted alphabetically.
     *  Includes textures stored inside atlases. */
    public function getTextureNames(prefix : String = "", out : Array<String> = null) : Array<String>
    {
        return getAssetNames(AssetType.TEXTURE, prefix, true, out);
    }
    
    /** Returns a texture atlas with a certain name, or null if it's not found. */
    public function getTextureAtlas(name : String) : TextureAtlas
    {
        return cast getAsset(AssetType.TEXTURE_ATLAS, name);
    }
    
    /** Returns all texture atlas names that start with a certain string, sorted alphabetically.
     *  If you pass an <code>out</code>-vector, the names will be added to that vector. */
    public function getTextureAtlasNames(prefix : String = "", out : Array<String> = null) : Array<String>
    {
        return getAssetNames(AssetType.TEXTURE_ATLAS, prefix, true, out);
    }
    
    /** Returns a sound with a certain name, or null if it's not found. */
    //public function getSound(name : String) : Sound
    //{
        //return try cast(getAsset(AssetType.SOUND, name), Sound) catch(e:Dynamic) null;
    //}
    
    /** Returns all sound names that start with a certain string, sorted alphabetically.
     *  If you pass an <code>out</code>-vector, the names will be added to that vector. */
    //public function getSoundNames(prefix : String = "", out : Array<String> = null) : Array<String>
    //{
        //return getAssetNames(AssetType.SOUND, prefix, true, out);
    //}
    
    /** Generates a new SoundChannel object to play back the sound. This method returns a
     *  SoundChannel object, which you can access to stop the sound and to control volume. */
    //public function playSound(name : String, startTime : Float = 0, loops : Int = 0,
            //transform : SoundTransform = null) : SoundChannel
    //{
        //var sound : Sound = getSound(name);
        //if (sound != null)
        //{
            //return sound.play(startTime, loops, transform);
        //}
        //else
        //{
            //return null;
        //}
    //}
    
    /** Returns an XML with a certain name, or null if it's not found. */
    //public function getXml(name : String) : FastXML
    //{
        //return try cast(getAsset(AssetType.XML_DOCUMENT, name), FastXML) catch(e:Dynamic) null;
    //}
    
    /** Returns all XML names that start with a certain string, sorted alphabetically.
     *  If you pass an <code>out</code>-vector, the names will be added to that vector. */
    //public function getXmlNames(prefix : String = "", out : Array<String> = null) : Array<String>
    //{
        //return getAssetNames(AssetType.XML_DOCUMENT, prefix, true, out);
    //}
    
    /** Returns an object with a certain name, or null if it's not found. Enqueued JSON
     *  data is parsed and can be accessed with this method. */
    public function getObject(name : String) : Dynamic
    {
        return getAsset(AssetType.OBJECT, name);
    }
    
    /** Returns all object names that start with a certain string, sorted alphabetically.
     *  If you pass an <code>out</code>-vector, the names will be added to that vector. */
    public function getObjectNames(prefix : String = "", out : Array<String> = null) : Array<String>
    {
        return getAssetNames(AssetType.OBJECT, prefix, true, out);
    }
    
    /** Returns a byte array with a certain name, or null if it's not found. */
    public function getByteArray(name : String) : ByteArray
    {
        return cast getAsset(AssetType.BYTE_ARRAY, name);
    }
    
    /** Returns all byte array names that start with a certain string, sorted alphabetically.
     *  If you pass an <code>out</code>-vector, the names will be added to that vector. */
    public function getByteArrayNames(prefix : String = "", out : Array<String> = null) : Array<String>
    {
        return getAssetNames(AssetType.BYTE_ARRAY, prefix, true, out);
    }
    
    /** Returns a bitmap font with a certain name, or null if it's not found. */
    //public function getBitmapFont(name : String) : BitmapFont
    //{
        //return try cast(getAsset(AssetType.BITMAP_FONT, name), BitmapFont) catch(e:Dynamic) null;
    //}
    
    /** Returns all bitmap font names that start with a certain string, sorted alphabetically.
     *  If you pass an <code>out</code>-vector, the names will be added to that vector. */
    //public function getBitmapFontNames(prefix : String = "", out : Array<String> = null) : Array<String>
    //{
        //return getAssetNames(AssetType.BITMAP_FONT, prefix, true, out);
    //}
    
    /** Returns an asset manager with a certain name, or null if it's not found. */
    public function getAssetManager(name : String) : AssetManager
    {
        return cast getAsset(AssetType.ASSET_MANAGER, name);
    }
    
    /** Returns all asset manager names that start with a certain string, sorted alphabetically.
     *  If you pass an <code>out</code>-vector, the names will be added to that vector. */
    public function getAssetManagerNames(prefix : String = "", out : Array<String> = null) : Array<String>
    {
        return getAssetNames(AssetType.ASSET_MANAGER, prefix, true, out);
    }
    
    ///** Removes a certain texture, optionally disposing it. */
    //public function removeTexture(name : String, dispose : Bool = true) : Void
    //{
        //removeAsset(AssetType.TEXTURE, name, dispose);
    //}
    //
    ///** Removes a certain texture atlas, optionally disposing it. */
    //public function removeTextureAtlas(name : String, dispose : Bool = true) : Void
    //{
        //removeAsset(AssetType.TEXTURE_ATLAS, name, dispose);
    //}
    //
    ///** Removes a certain sound. */
    //public function removeSound(name : String) : Void
    //{
        //removeAsset(AssetType.SOUND, name);
    //}
    
    ///** Removes a certain Xml object, optionally disposing it. */
    //public function removeXml(name : String, dispose : Bool = true) : Void
    //{
        //removeAsset(AssetType.XML_DOCUMENT, name, dispose);
    //}
    //
    ///** Removes a certain object. */
    //public function removeObject(name : String) : Void
    //{
        //removeAsset(AssetType.OBJECT, name);
    //}
    //
    ///** Removes a certain byte array, optionally disposing its memory right away. */
    //public function removeByteArray(name : String, dispose : Bool = true) : Void
    //{
        //removeAsset(AssetType.BYTE_ARRAY, name, dispose);
    //}
    //
    ///** Removes a certain bitmap font, optionally disposing it. */
    //public function removeBitmapFont(name : String, dispose : Bool = true) : Void
    //{
        //removeAsset(AssetType.BITMAP_FONT, name, dispose);
    //}
    //
    ///** Removes a certain asset manager and optionally disposes it right away. */
    //public function removeAssetManager(name : String, dispose : Bool = true) : Void
    //{
        //removeAsset(AssetType.ASSET_MANAGER, name, dispose);
    //}
    
    // registration of factories
    
    /** Registers a custom AssetFactory. If you use any priority > 0, the factory will
     *  be called before the default factories. The final factory to be invoked is the
     *  'ByteArrayFactory', which is using a priority of '-100'. */
    public function registerFactory(factory : AssetFactory, priority : Int = 0) : Void
    {
        factory.priority = priority;
        
        _assetFactories.push(factory);
        _assetFactories.sort(comparePriorities);
    }
    
    private static function comparePriorities(a : Dynamic, b : Dynamic) : Int
    {
        if (a.priority == b.priority)
        {
            return 0;
        }
        return (a.priority > b.priority) ? -1 : 1;
    }
    
    // helpers
    
    /** This method is called internally to determine the name under which an asset will be
     *  accessible; override it if you need a custom naming scheme.
     *
     *  @return the name to be used for the asset, or 'null' if it can't be determined. */
    private function getNameFromUrl(url : String) : String
    {
        var defaultName : String=getSubName(url);
        var separator : String = "/";
        
        if (defaultName == "Animation" || defaultName == "spritemap" &&
            url.indexOf(separator) != -1)
        {
            var elements : Array<Dynamic> = url.split(separator);
            var folderName : String = elements[elements.length - 2];
            var suffix : String = (defaultName == "Animation") ? AnimationAtlasFactory.ANIMATION_SUFFIX : "";
            return getSubName(folderName + suffix);
        }
        
        return defaultName;
    }
	
	private function getSubName (url:String): String {
		if (url != null)
        {
            var matches : Array<String> = NAME_REGEX.split(url);
            if (matches != null && matches.length > 0)
            {
                return matches[1];
            }
        }
		return null;
	}
    
    /** This method is called internally to determine the extension that's passed to the
     *  'AssetFactory' (via the 'AssetReference'). Override it if you need to customize
     *  e.g. the extension of a server URL.
     *
     *  @return the extension to be used for the asset, or an empty string if it can't be
     *          determined. */
    private function getExtensionFromUrl(url : String) : String
    {
        if (url != null)
        {
            //var matches : Array<String> = NAME_REGEX.split(url);
            //if (matches != null && matches.length > 1)
            //{
                //return matches[2];
            //}
			return url.split("?")[0].split(".").pop();
        }
		
        return "";
    }
    
    /** Disposes the given asset. ByteArrays are cleared, XMLs are disposed using
     *  'System.disposeXML'. If the object contains a 'dispose' method, it will be called.
     *  Override if you need to add custom cleanup code for a certain asset. */
    //private function disposeAsset(asset : Dynamic) : Void
    //{
        //if (Std.is(asset, ByteArray))
        //{
            //(try cast(asset, ByteArray) catch(e:Dynamic) null).clear();
        //}
        //if (Std.is(asset, FastXML))
        //{
            //System.disposeXML(try cast(asset, FastXML) catch(e:Dynamic) null);
        //}
        //if (Lambda.has(asset, "dispose"))
        //{
            //Reflect.field(asset, "dispose")();
        //}
    //}
    
    /** This method is called during loading of assets when 'verbose' is activated. Per
     *  default, it traces 'message' to the console. */
    private function log(message : String) : Void
    {
        if (_verbose)
        {
            trace("[AssetManager]", message);
        }
    }
    
    private static function getDictionaryKeys(dictionary : Map<String,Dynamic>, prefix : String = "", out : Array<String> = null) : Array<String>
    {
        //if (out == null)
        //{
            //out = [];
        //}
        if (dictionary != null)
        {
            for (name in dictionary.keys())
            {
                if (name.indexOf(prefix) == 0)
                {
                    out[out.length] = name;
                }
            }  // avoid 'push'  
            
            out.sort(ArrayUtil.CASEINSENSITIVE);
        }
        return out;
    }
    
    private static function getUniqueName() : String
    {
        return NO_NAME + "-" + sNoNameCount++;
    }
    
    // properties
    
    /** When activated, the class will trace information about added/enqueued assets.
     *  @default true */
    private function get_verbose() : Bool
    {
        return _verbose;
    }
    private function set_verbose(value : Bool) : Bool
    {
        _verbose = value;
        return value;
    }
    
    /** Returns the number of raw assets that have been enqueued, but not yet loaded. */
    private function get_numQueuedAssets() : Int
    {
        return _queue.length;
    }
    
    /** The maximum number of parallel connections that are spawned when loading the queue.
     *  More connections can reduce loading times, but require more memory. @default 3. */
    private function get_numConnections() : Int
    {
        return _numConnections;
    }
    private function set_numConnections(value : Int) : Int
    {
        _numConnections = Std.int(Math.min(1, value));
        return value;
    }
    
    /** Textures will be created with the options set up in this object at the time of
     *  enqueuing. */
    //private function get_textureOptions() : TextureOptions
    //{
        //return _textureOptions;
    //}
    //private function set_textureOptions(value : TextureOptions) : TextureOptions
    //{
        //_textureOptions.copyFrom(value);
        //return value;
    //}
    
    /** The DataLoader is used to load any data from files or URLs. If you need to customize
     *  its behavior (e.g. to add a caching mechanism), assign your custom instance here. */
    //private function get_dataLoader() : DataLoader
    //{
        //return _dataLoader;
    //}
    //private function set_dataLoader(value : DataLoader) : DataLoader
    //{
        //_dataLoader = value;
        //return value;
    //}
    
    /** Indicates if bitmap fonts should be registered with their "face" attribute from the
     *  font XML file. Per default, they are registered with the name of the texture file.
     *  @default false */
    private function get_registerBitmapFontsWithFontFace() : Bool
    {
        return _registerBitmapFontsWithFontFace;
    }
    
    private function set_registerBitmapFontsWithFontFace(value : Bool) : Bool
    {
        _registerBitmapFontsWithFontFace = value;
        return value;
    }
}



class AssetPostProcessor
{
    public var priority(get, never) : Int;

    private var _priority : Int;
    private var _callback : Dynamic;
    
    public function new(callback : Dynamic, priority : Int)
    {
		//TODO:
		//if (callback == null || as3hx.Compat.getFunctionLength(callback) != 1)
        //{
            //throw new ArgumentError("callback must be a function " +
            //"accepting one 'AssetStore' parameter");
        //}
        
        _callback = callback;
        _priority = priority;
    }
    
    @:allow(animateAtlasPlayer.assets.AssetManager)
    private function execute(store : AssetManager) : Void
    {
        _callback(store);
    }
    
    private function get_priority() : Int
    {
        return _priority;
    }
}