package starling.assets;
import openfl.utils.ByteArray;
import starling.assets.AssetReference;

/** This AssetFactory creates objects from JSON data. */
class JsonFactory extends AssetFactory
{
    /** Creates a new instance. */
    public function new()
    {
        super();
        addExtensions("json");
        //TODO ? addMimeTypes("application/json", "text/json");
    }
    
    /** @inheritDoc */
    //override public function canHandle(reference : AssetReference) : Bool
    //{
        //return super.canHandle(reference) || (Std.is(reference.data, ByteArray) &&
        //ByteArrayUtil.startsWithString(try cast(reference.data, ByteArray) catch(e:Dynamic) null, "{"));
    //}
    
    /** @inheritDoc */
    override public function create(reference : AssetReference,assets:AssetManager/*, helper : AssetFactoryHelper, onComplete : Function, onError : Function*/) : Void
    {	
			//try
            //{
                //var bytes:ByteArray = reference.data as ByteArray;
                //var object:Object = JSON.parse(bytes.readUTFBytes(bytes.length));
                //onComplete(reference.name, object);
            //}
            //catch (e:Error)
            //{
                //onError("Could not parse JSON: " + e.message);
            //}
    }
}

