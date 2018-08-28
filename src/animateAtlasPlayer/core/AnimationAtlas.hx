package animateAtlasPlayer.core;

import animateAtlasPlayer.textures.TextureAtlas;
import animateAtlasPlayer.utils.ArrayUtil;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

typedef Frame = {
	var name: String;
	var index: Int;
	var duration: Int;
	var elements: Array<Dynamic>;
}

typedef Layer = {
	var Layer_name: String;
	var Frames: Array<Frame>;
}

typedef Timeline = {
	var LAYERS : Array<Layer>;
	@optional var sortedForRender:Bool;
}

typedef SymbolData = {
	var SYMBOL_name: String;
	var TIMELINE: Timeline;
}

typedef SymbolDictionnary = {
	var Symbols : Array<SymbolData>;
}

typedef MetaData = {
	var frameRate : Int;
}

typedef AnimationJson = {
  var ANIMATION : Dynamic;
  var SYMBOL_DICTIONARY : SymbolDictionnary;
  var metadata : MetaData;
}

class AnimationAtlas
{
    public var frameRate(get, set) : Float;

    public static inline var ASSET_TYPE : String = "animationAtlas";
    
    private var _atlas : TextureAtlas;
    private var _symbolData : Map<String,Dynamic>;
    private var _symbolPool : Dynamic;
    private var _imagePool : Array<Dynamic>;
    private var _frameRate : Float;
    private var _defaultSymbolName : String;
    
    private static var STD_MATRIX3D_DATA : Dynamic = {
            m00 : 1,
            m01 : 0,
            m02 : 0,
            m03 : 0,
            m10 : 0,
            m11 : 1,
            m12 : 0,
            m13 : 0,
            m20 : 0,
            m21 : 0,
            m22 : 1,
            m23 : 0,
            m30 : 0,
            m31 : 0,
            m32 : 0,
            m33 : 1
        };
    
	public function new(data : Dynamic, atlas : TextureAtlas)
    {
        parseData(data);
        
        _atlas = atlas;
        _symbolPool = {};
        _imagePool = [];
    }
    
    public function hasAnimation(name : String) : Bool
    {
        return hasSymbol(name);
    }
    
    public function createAnimation(name : String = null) : Animation
    {
        name = name != null ? name : _defaultSymbolName;
		
        if (!hasSymbol(name))
        {
			throw "Animation not found: " + name;
        }
		
        return new Animation(getSymbolData(name), this);
    }
    
    public function getAnimationNames(prefix : String = "", out : Array<String> = null) : Array<String>
    {
        out = (out != null) ? out : new Array<String>();
        
        for (name in Reflect.fields(_symbolData))
        {
            if (name != Symbol.BITMAP_SYMBOL_NAME && name.indexOf(prefix) == 0)
            {
                out[out.length] = name;
            }
        }
        
        out.sort(ArrayUtil.CASEINSENSITIVE);
        return out;
    }
    
    // pooling
    
    @:allow(animateAtlasPlayer.core)
    private function getTexture(name : String) : BitmapData
    {
		return _atlas.getTexture(name);
    }
    
    @:allow(animateAtlasPlayer.core)
    private function getImage(texture : BitmapData) : Bitmap
    {

		if (_imagePool.length == 0)
        {
            return new Bitmap(texture);
        }
        else
        {
            var image : Bitmap = cast _imagePool.pop();
            image.bitmapData = texture;
            //TODO: image.readjustSize();
            return image;
        }
    }
    
    @:allow(animateAtlasPlayer.core)
    private function putImage(image : Bitmap) : Void
    {
        _imagePool[_imagePool.length] = image;
    }
    
    @:allow(animateAtlasPlayer.core)
    private function hasSymbol(name : String) : Bool
    {
        return _symbolData[name]!=null;
    }
    
    @:allow(animateAtlasPlayer.core)
    private function getSymbol(name : String) : Symbol
    {
        var pool : Array<Dynamic> = getSymbolPool(name);
        if (pool.length == 0)
        {
            return new Symbol(getSymbolData(name), this);
        }
        else
        {
            return pool.pop();
        }
    }
    
    @:allow(animateAtlasPlayer.core)
    private function putSymbol(symbol : Symbol) : Void
    {
        symbol.reset();
        var pool : Array<Dynamic> = getSymbolPool(symbol.symbolName);
        pool[pool.length] = symbol;
        symbol.currentFrame = 0;
    }
    
    // helpers
    
    private function parseData(data : AnimationJson) : Void
    {
        var metaData : MetaData = data.metadata;
        
        if (metaData != null && metaData.frameRate > 0)
        {
            _frameRate = metaData.frameRate;
        }
        else
        {
            _frameRate = 24;
        }
        _symbolData = new Map<String,Dynamic>();
        
        // the actual symbol dictionary
        for (symbolData in data.SYMBOL_DICTIONARY.Symbols)
        {

			_symbolData[symbolData.SYMBOL_name]=preprocessSymbolData(symbolData);
        }
        
        // the main animation
        var defaultSymbolData : SymbolData = preprocessSymbolData(data.ANIMATION);
        _defaultSymbolName = defaultSymbolData.SYMBOL_name;
        _symbolData[_defaultSymbolName]= defaultSymbolData;

        // a purely internal symbol for bitmaps - simplifies their handling		
		_symbolData[Symbol.BITMAP_SYMBOL_NAME]=	{
                    SYMBOL_name : Symbol.BITMAP_SYMBOL_NAME,
                    TIMELINE : {
                        LAYERS : []
                    }
                };	
				
    }
    
    private static function preprocessSymbolData(symbolData : SymbolData) : Dynamic
    {
        var timeLineData : Timeline = symbolData.TIMELINE;
        var layerDates : Array<Layer> = timeLineData.LAYERS;
        
        // In Animate CC, layers are sorted front to back.
        // In animateAtlasPlayer, it's the other way round - so we simply reverse the layer data.
       // TODO: voir s'il faut faire comme animateAtlasPlayer 	
		
        if (timeLineData.sortedForRender==null)
        {
            timeLineData.sortedForRender = true;
            layerDates.reverse();
        }
        
        // We replace all "ATLAS_SPRITE_instance" elements with symbols of the same contents.
        // That way, we are always only dealing with symbols.
        
        var numLayers : Int = layerDates.length;
        
        for (l in 0...numLayers)
        {
            var layerData : Layer = layerDates[l];
            var frames : Array<Frame> = cast layerData.Frames;
            var numFrames : Int = frames.length;
            
            for (f in 0...numFrames)
            {
                var elements : Array<Dynamic> = cast frames[f].elements;
                var numElements : Int = elements.length;
                
                for (e in 0...numElements)
                {
                    var element : Dynamic = elements[e];
                    
                    if (Reflect.hasField(element, "ATLAS_SPRITE_instance"))
                    {
                        element = elements[e] = {
                                            SYMBOL_Instance : {
                                                SYMBOL_name : Symbol.BITMAP_SYMBOL_NAME,
                                                Instance_Name : "InstName",
                                                bitmap : element.ATLAS_SPRITE_instance,
                                                symbolType : SymbolType.GRAPHIC,
                                                firstFrame : 0,
                                                loop : LoopMode.LOOP,
                                                transformationPoint : {
                                                    x : 0,
                                                    y : 0
                                                },
                                                Matrix3D : STD_MATRIX3D_DATA
                                            }
                                        };
                    }
                    
                    // not needed - remove decomposed matrix to save some memory
                    element.SYMBOL_Instance.DecomposedMatrix=null;
                }
            }
        }
        
        return symbolData;
    }
    
    private function getSymbolData(name : String) : Dynamic
    {
        return _symbolData[name];
    }
    
    private function getSymbolPool(name : String) : Array<Dynamic>
    {
        var pool : Array<Dynamic> = Reflect.field(_symbolPool, name);
        if (pool == null)
        {
            Reflect.setField(_symbolPool, name, []);
			pool = Reflect.field(_symbolPool, name);
        }
        return pool;
    }
    
    // properties
    
    private function get_frameRate() : Float
    {
        return _frameRate;
    }
    private function set_frameRate(value : Float) : Float
    {
        _frameRate = value;
        return value;
    }
	
	public function toString () : String {
		return "[Object" +Type.getClassName(Type.getClass(this)).split(".").pop() + "]";
	}
}

