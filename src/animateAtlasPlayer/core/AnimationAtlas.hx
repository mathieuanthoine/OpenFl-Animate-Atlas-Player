package animateAtlasPlayer.core;

import openfl.Vector;
import openfl.errors.ArgumentError;
import animateAtlasPlayer.textures.TextureAtlas;
import animateAtlasPlayer.utils.ArrayUtil;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

class AnimationAtlas
{
    public var frameRate(get, set) : Float;

    public static inline var ASSET_TYPE : String = "animationAtlas";

    private var _atlas : TextureAtlas;
    private var _symbolData : Map<String, Dynamic>;
    private var _symbolPool : Map<String, Array<Symbol>>;
    private var _imagePool : Array<Bitmap>;
    private var _frameRate : Float;
    private var _defaultSymbolName : String;

    private static var STD_MATRIX3D_DATA : Dynamic =
    {
        m00: 1, m01: 0, m02: 0, m03: 0,
        m10: 0, m11: 1, m12: 0, m13: 0,
        m20: 0, m21: 0, m22: 1, m23: 0,
        m30: 0, m31: 0, m32: 0, m33: 1
    };

	public function new(data : Dynamic, atlas : TextureAtlas)
    {
        if (data  == null)
            throw new ArgumentError("data must not be null");
        if (atlas == null)
            throw new ArgumentError("atlas must not be null");

        data = normalizeJsonKeys(data);
        parseData(data);

        _atlas = atlas;

        _symbolPool = new Map<String, Array<Symbol>>();
        _imagePool = [];
    }

    public function hasAnimation(name : String) : Bool
    {
        return hasSymbol(name);
    }

    public function createAnimation(name : String = null) : Animation
    {
        name = (name != null) ? name : _defaultSymbolName;
        if (!hasSymbol(name))
        {
            throw new ArgumentError("Animation not found: " + name);
        }
        return new Animation(name, this);
    }

    public function getAnimationNames(prefix : String = "", out : Vector<String> = null) : Vector<String>
    {
        out = (out != null) ? out : new Vector<String>();

        for (name in _symbolData.keys())
        {
            if (name != Symbol.BITMAP_SYMBOL_NAME && name.indexOf(prefix) == 0)
            {
                out[out.length] = name;
            }
        }

        //out.sort(Array.CASEINSENSITIVE);
        out.sort(function(a1, a2) : Int {
            a1 = a1.toLowerCase();
            a2 = a2.toLowerCase();
            if (a1 < a2){
                return -1;
            }else if (a1 > a2){
                return 1;
            }else{
                return 0;
            }
        });
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
        return _symbolData.exists(name);
    }

    @:allow(animateAtlasPlayer.core)
    private function getSymbol(name : String) : Symbol
    {
        var pool:Array<Symbol> = getSymbolPool(name);
        if (pool.length == 0)
            return new Symbol(getSymbolData(name), this);
        else return pool.pop();
    }

    @:allow(animateAtlasPlayer.core)
    private function putSymbol(symbol : Symbol) : Void
    {
        symbol.reset();
        var pool:Array<Symbol> = getSymbolPool(symbol.symbolName);
        pool[pool.length] = symbol;
        symbol.currentFrame = 0;
    }

    // helpers

    private function parseData(data : Dynamic) : Void
    {
        var metaData:Dynamic = data.metadata;

        if (metaData != null && metaData.frameRate > 0)
            _frameRate = Std.int(metaData.frameRate);
        else
            _frameRate = 24;

        _symbolData = new Map<String, Dynamic>();

        // the actual symbol dictionary
        for (symbolData in cast(data.symbolDictionary.symbols, Array<Dynamic>))
            _symbolData[symbolData.symbolName] = preprocessSymbolData(symbolData);

        // the main animation
        var defaultSymbolData:Dynamic = preprocessSymbolData(data.animation);
        _defaultSymbolName = defaultSymbolData.symbolName;
        _symbolData[_defaultSymbolName] = defaultSymbolData;

        // a purely internal symbol for bitmaps - simplifies their handling
        _symbolData[Symbol.BITMAP_SYMBOL_NAME] = {
            symbolName: Symbol.BITMAP_SYMBOL_NAME,
            timeline: { layers: [] }
        };
    }

    private static function preprocessSymbolData(symbolData : Dynamic) : Dynamic
    {
        var timeLineData:Dynamic = symbolData.timeline;
        var layerDates:Array<Dynamic> = timeLineData.layers;

        // In Animate CC, layers are sorted front to back.
        // In Starling, it's the other way round - so we simply reverse the layer data.

        if (!timeLineData.sortedForRender)
        {
            timeLineData.sortedForRender = true;
            layerDates.reverse();
        }

        // We replace all "ATLAS_SPRITE_instance" elements with symbols of the same contents.
        // That way, we are always only dealing with symbols.

        var numLayers:Int = layerDates.length;

        for (l in 0...numLayers)
        {
            var layerData:Dynamic = layerDates[l];
            var frames:Array<Dynamic> = layerData.frames;
            var numFrames:Int = frames.length;

            for (f in 0...numFrames)
            {
                var elements:Array<Dynamic> = frames[f].elements;
                var numElements:Int = elements.length;

                for (e in 0...numElements)
                {
                    var element:Dynamic = elements[e];

                    if (element.atlasSpriteInstance != null)
                    {
                        element = elements[e] = {
                            symbolInstance: {
                                symbolName: Symbol.BITMAP_SYMBOL_NAME,
                                instanceName: "InstName",
                                bitmap: element.atlasSpriteInstance,
                                symbolType: SymbolType.GRAPHIC,
                                firstFrame: 0,
                                loop: LoopMode.LOOP,
                                transformationPoint: { x: 0, y: 0 },
                                matrix3D: STD_MATRIX3D_DATA
                            }
                        }
                    }

                    // not needed - remove decomposed matrix to save some memory
                    if (element.symbolInstance.decomposedMatrix != null)
                    {
                        element.symbolInstance.decomposedMatrix = null;
                    }
                }
            }
        }

        return symbolData;
    }

    public function getSymbolData(name : String) : Dynamic
    {
        return _symbolData.get(name);
    }

    private function getSymbolPool(name : String) : Array<Symbol>
    {
        var pool : Array<Symbol> = cast _symbolPool.get(name);
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
		return "[Object " +Type.getClassName(Type.getClass(this)).split(".").pop() + "]";
	}

    private static function normalizeJsonKeys(data:Dynamic):Dynamic
    {
        if (Std.is(data, String) || Std.is(data, Float) || Std.is(data, Int))
            return data;
        else if (Std.is(data, Array))
        {
            var array:Array<Dynamic> = [];
            var arrayLength:Int = data.length;
            for (i in 0...arrayLength)
                array[i] = normalizeJsonKeys(data[i]);
            return array;
        }
        else
        {
            var out:Dynamic = {};

            for (key in Reflect.fields(data))
            {
                var newData:Dynamic = Reflect.field(data, key);
                var value:Dynamic = normalizeJsonKeys(newData);
                if (Reflect.field(JsonKeys, key) != null)
                    key = Reflect.field(JsonKeys, key);
                Reflect.setField(out, key, value);
            }
            return out;
        }
    }


    private static var JsonKeys : Dynamic =
    {
        ANIMATION : "animation",
        ATLAS_SPRITE_instance : "atlasSpriteInstance",
        DecomposedMatrix : "decomposedMatrix",
        Frames : "frames",
        framerate : "frameRate",
        Instance_Name : "instanceName",
        Layer_name : "layerName",
        LAYERS : "layers",
        Matrix3D : "matrix3D",
        Position : "position",
        Rotation : "rotation",
        Scaling : "scaling",
        SYMBOL_DICTIONARY : "symbolDictionary",
        SYMBOL_Instance : "symbolInstance",
        SYMBOL_name : "symbolName",
        Symbols : "symbols",
        TIMELINE : "timeline",
        AN : "animation",
        AM : "alphaMultiplier",
        ASI : "atlasSpriteInstance",
        BM : "bitmap",
        C : "color",
        DU : "duration",
        E : "elements",
        FF : "firstFrame",
        FR : "frames",
        FRT : "frameRate",
        I : "index",
        IN : "instanceName",
        L : "layers",
        LN : "layerName",
        LP : "loop",
        M3D : "matrix3D",
        MD : "metadata",
        M : "mode",
        N : "name",
        POS : "position",
        S : "symbols",
        SD : "symbolDictionary",
        SI : "symbolInstance",
        SN : "symbolName",
        ST : "symbolType",
        TL : "timeline",
        TRP : "transformationPoint"
    };
}

