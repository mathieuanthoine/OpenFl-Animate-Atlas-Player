package animateAtlasPlayer.assets;
import openfl.system.Capabilities;

/** An AssetFactory is responsible for creating a concrete instance of an asset.
 *
 *  <p>The AssetManager contains a list of AssetFactories, registered via 'registerFactory'.
 *  When the asset queue is processed, each factory (sorted by priority) will be asked if it
 *  can handle a certain AssetReference (via the 'canHandle') method. If it can, the 'create'
 *  method will be called, which is responsible for creating at least one asset.</p>
 *
 *  <p>By extending 'AssetFactory' and registering your class at the AssetManager, you can
 *  customize how assets are being created and even add new types of assets.</p>
 */
class AssetFactory
{
	@:allow(animateAtlasPlayer.assets)
    private var priority(get, set) : Int;

    private var _priority : Int;
    private var _mimeTypes : Array<String>;
    private var _extensions : Array<String>;
    
    /** Creates a new instance. */
    public function new()
    {
        if (Capabilities.isDebugger &&
            Type.getClassName(Type.getClass(this)) == "animateAtlasPlayer.assets::AssetFactory")
        {
            // TODO
			throw "new AbstractClassError();";
        }
        
        _mimeTypes = [];
        _extensions = [];
    }
    
    /** Returns 'true' if this factory can handle the given reference. The default
     *  implementation checks if extension and/or mime type of the reference match those
     *  of the factory. */
    //public function canHandle(reference : AssetReference) : Bool
    //{
        //var mimeType : String = reference.mimeType;
        //var extension : String = reference.extension;
        //
        //return Std.is(reference.data, ByteArray) && (
        //(mimeType && Lambda.indexOf(_mimeTypes, reference.mimeType.toLowerCase()) != -1) ||
        //(extension && Lambda.indexOf(_extensions, reference.extension.toLowerCase()) != -1));
    //}
    
    /** This method will only be called if 'canHandle' returned 'true' for the given reference.
     *  It's responsible for creating at least one concrete asset and passing it to 'onComplete'.
     *
     *  @param reference   The asset to be created. If a local or remote URL is referenced,
     *                     it will already have been loaded, and 'data' will contain a ByteArray.
     *  @param helper      Contains useful utility methods to be used by the factory. Look
     *                     at the class documentation for more information.
     *  @param onComplete  To be called with the name and asset as parameters when loading
     *                     is successful. <pre>function(name:String, asset:Object):void;</pre>
     *  @param onError     To be called when creation fails for some reason. Do not call
     *                     'onComplete' when that happens. <pre>function(error:String):void</pre>
     */
    public function create(reference : AssetReference,assets:AssetManager/*, helper : AssetFactoryHelper,
            onComplete : Function, onError : Function*/) : Void
    {  // to be implemented by subclasses  
       
    }
    
    /** Add one or more mime types that identify the supported data types. Used by
     *  'canHandle' to figure out if the factory is suitable for an asset reference. */
    public function addMimeTypes(args : Array<Dynamic> = null) : Void
    {
        for (mimeType in args)
        {
            mimeType = mimeType.toLowerCase();
            
            if (Lambda.indexOf(_mimeTypes, mimeType) == -1)
            {
                _mimeTypes[_mimeTypes.length] = mimeType;
            }
        }
    }
    
    /** Add one or more file extensions (without leading dot) that identify the supported data
     *  types. Used by 'canHandle' to figure out if the factory is suitable for an asset
     *  reference. */
    public function addExtensions(arg) : Void
    {
            var extension:String = arg.toLowerCase();
            
            if (Lambda.indexOf(_extensions, extension) == -1)
            {
                _extensions[_extensions.length] = extension;
            }
    }
    
    /** Returns the mime types this factory supports. */
    public function getMimeTypes(out : Array<String> = null) : Array<String>
    {
        out = (out != null) ? out : new Array<String>();
        
        for (i in 0..._mimeTypes.length)
        {
            out[i] = _mimeTypes[i];
        }
        
        return out;
    }
    
    /** Returns the file extensions this factory supports. */
    public function getExtensions(out : Array<String> = null) : Array<String>
    {
        out = (out != null) ? out : new Array<String>();
        
        for (i in 0..._extensions.length)
        {
            out[i] = _extensions[i];
        }
        
        return out;
    }
    
    private function get_priority() : Int
    {
        return _priority;
    }

    private function set_priority(value : Int) : Int
    {
        _priority = value;
        return value;
    }
	
	public function toString () : String {
		return "[Object " +Type.getClassName(Type.getClass(this)).split(".").pop() + "]";
	}
}

