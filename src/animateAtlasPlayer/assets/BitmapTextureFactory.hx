package animateAtlasPlayer.assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

/** This AssetFactory creates texture assets from bitmaps and image files. */
class BitmapTextureFactory extends AssetFactory
{
    /** Creates a new instance. */
    public function new()
    {
        super();
        //addMimeTypes("image/png", "image/jpg", "image/jpeg", "image/gif");
        addExtensions("png");
    }
    
    /** @inheritDoc */
    //override public function canHandle(reference : AssetReference) : Bool
    //{
        //return Std.is(reference.data, Bitmap) || Std.is(reference.data, BitmapData) ||
        //super.canHandle(reference);
    //}
    
    /** @inheritDoc */
    override public function create(reference : AssetReference,assets:AssetManager/*, helper : AssetFactoryHelper,
            onComplete : Function, onError : Function*/) : Void
    {
		//var texture : BitmapData;
        //var url : String = reference.url;
        //var data : Dynamic = reference.data; //deja un bitmapData ?
		
		assets.addAsset(reference.name, reference.data);
		

    }
	
	//private function createFromBitmapData (bitmapData : BitmapData) : Void
	//{
		////reference.textureOptions.onReady = function() : Void
				////{
					////onComplete(reference.name, texture);
				////};
		//
		//texture = Texture.fromData(bitmapData, reference.textureOptions);
		//
		//if (url != null)
		//{
			//texture.root.onRestore = function() : Void
					//{
						//helper.onBeginRestore();
						//
						//reload(url, function(bitmapData : BitmapData) : Void
								//{
									//helper.executeWhenContextReady(function() : Void
											//{
												//texture.root.uploadBitmapData(bitmapData);
												//helper.onEndRestore();
											//});
								//});
					//};
		//}
	//}


}

