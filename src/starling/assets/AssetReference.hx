package starling.assets;

/** The description of an asset to be created by an AssetFactory. */
class AssetReference
{
    public var name(get, set) : String;
    public var url(get, set) : String;
    public var data(get, set) : Dynamic;
    public var mimeType(get, set) : String;
    public var extension(get, set) : String;
    //public var textureOptions(get, set) : TextureOptions;
    @:allow(starling.assets)
	private var filename(get, never) : String;

    private var _name : String;
    private var _url : String;
    private var _data : Dynamic;
    private var _mimeType : String;
    private var _extension : String;
    //TODO: ? private var _textureOptions : TextureOptions;
    
    /** Creates a new instance with the given data, which is typically some kind of file
     *  reference / URL or an instancse of an asset class. If 'data' contains an URL, an
     *  equivalent value will be assigned to the 'url' property. */
    public function new(data : Dynamic)
    {
        _data = data;
        //_textureOptions = new TextureOptions();
        
        //if (Std.is(data, String))
        //{
            //_url = Std.string(data);
        //}
        //else if (Lambda.has(data, "url"))
        //{
            //_url = Std.string(Reflect.field(data, "url"));
        //}
    }
    
    /** The name with which the asset should be added to the AssetManager. */
    private function get_name() : String
    {
        return _name;
    }
    private function set_name(value : String) : String
    {
        _name = value;
        return value;
    }
    
    /** The url from which the asset needs to be / has been loaded. */
    private function get_url() : String
    {
        return _url;
    }
    private function set_url(value : String) : String
    {
        _url = value;
        return value;
    }
    
    /** The raw data of the asset. This property often contains an URL; when it's passed
     *  to an AssetFactory, loading has already completed, and the property contains a
     *  ByteArray with the loaded data. */
    private function get_data() : Dynamic
    {
        return _data;
    }
    private function set_data(value : Dynamic) : Dynamic
    {
        _data = value;
        return value;
    }
    
    /** The mime type of the asset, if loaded from a server. */
    private function get_mimeType() : String
    {
        return _mimeType;
    }
    private function set_mimeType(value : String) : String
    {
        _mimeType = value;
        return value;
    }
    
    /** The file extension of the asset, if the filename or URL contains one. */
    private function get_extension() : String
    {
        return _extension;
    }
    private function set_extension(value : String) : String
    {
        _extension = value;
        return value;
    }
    
    /** The TextureOptions describing how to create a texture, if the asset references one. */
    //private function get_textureOptions() : TextureOptions
    //{
        //return _textureOptions;
    //}
    //private function set_textureOptions(value : TextureOptions) : TextureOptions
    //{
        //_textureOptions.copyFrom(value);
        //return value;
    //}
    
    private function get_filename() : String
    {
        if (name != null && extension != null && extension != "")
        {
            return name + "." + extension;
        }
        else if (name != null)
        {
            return name;
        }
        else
        {
            return null;
        }
    }
}

