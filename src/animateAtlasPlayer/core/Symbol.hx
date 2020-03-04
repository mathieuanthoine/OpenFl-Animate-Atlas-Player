package animateAtlasPlayer.core;

import haxe.Json;
import animateAtlasPlayer.utils.MathUtil;
import openfl.display.BitmapData;
import openfl.display.FrameLabel;
import flash.errors.ArgumentError;
import flash.errors.Error;
import flash.geom.Matrix;
import openfl.display.DisplayObjectContainer;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.filters.ColorMatrixFilter;

class Symbol extends DisplayObjectContainer
{
    public var currentLabel(get, never) : String;
    public var currentFrame(get, set) : Int;
    public var type(get, set) : String;
    public var loopMode(get, set) : String;
    public var symbolName(get, never) : String;
    public var numLayers(get, never) : Int;
    public var numFrames(get, never) : Int;

    public static inline var BITMAP_SYMBOL_NAME : String = "___atlas_sprite___";

    private var _data : Dynamic;
    private var _atlas : AnimationAtlas;
    private var _symbolName : String;
    private var _type : String;
    private var _loopMode : String;
    private var _currentFrame : Int;
    private var _composedFrame : Int;
    private var _layers : Sprite;
    private var _bitmap : Bitmap;
    private var _numFrames : Int;
    private var _numLayers : Int;
    private var _frameLabels : Array<Dynamic>;
    private var _colorTransform:ColorMatrixFilter;

    private static var sMatrix : Matrix = new Matrix();

    @:allow(openfl.extensions.animate)
    public function new(data : Dynamic, atlas : AnimationAtlas)
    {
        super();
        _data = data;
        _atlas = atlas;
        _composedFrame = -1;
        _numLayers = data.timeline.layers.length;
        _numFrames = getNumFrames();
        _frameLabels = getFrameLabels();
        _symbolName = data.symbolName;
        _type = SymbolType.GRAPHIC;
        _loopMode = LoopMode.LOOP;

        createLayers();
    }

    public function reset():Void
    {
        sMatrix.identity();
        transform.matrix = sMatrix;
        alpha = 1.0;
        _currentFrame = 0;
        _composedFrame = -1;
    }

    /** To be called whenever sufficient time for one frame has passed. Does not necessarily
         *  move 'currentFrame' ahead - depending on the 'loop' mode. MovieClips all move
         *  forward, though (recursively). */
    public function nextFrame():Void
    {
        if (_loopMode != LoopMode.SINGLE_FRAME)
            currentFrame += 1;

        nextFrame_MovieClips();
    }

    /** Moves all movie clips ahead one frame, recursively. */
    public function nextFrame_MovieClips():Void
    {
        if (_type == SymbolType.MOVIE_CLIP)
            currentFrame += 1;

        for (l in 0..._numLayers)
        {
            var layer:Sprite = getLayer(l);
            var numElements:Int = layer.numChildren;

            for (e in 0...numElements)
                cast(layer.getChildAt(e),Symbol).nextFrame_MovieClips();
        }
    }

    public function update():Void
    {
        for (i in 0..._numLayers)
            updateLayer(i);

        _composedFrame = _currentFrame;
    }

    private function updateLayer(layerIndex:Int):Void
    {
        var layer:Sprite = getLayer(layerIndex);
        var frameData:Dynamic = getFrameData(layerIndex, _currentFrame);
        var elements:Array<Dynamic> = frameData ? frameData.elements : null;
        var numElements:Int = elements != null ? elements.length : 0;

        var oldSymbol:Symbol = null;

        for (i in 0...numElements)
        {
            var elementData:Dynamic = elements[i].symbolInstance;
            oldSymbol = layer.numChildren > i ? cast(layer.getChildAt(i),Symbol) : null;
            var newSymbol:Symbol = null;
            var symbolName:String = elementData.symbolName;

            if (!_atlas.hasSymbol(symbolName))
                symbolName = BITMAP_SYMBOL_NAME;

            if (oldSymbol != null && oldSymbol._symbolName == symbolName)
                newSymbol = oldSymbol;
            else
            {
                if (oldSymbol != null)
                {
                    oldSymbol.removeFromParent();
                    _atlas.putSymbol(oldSymbol);
                }

                newSymbol = _atlas.getSymbol(symbolName);
                layer.addChildAt(newSymbol, i);
            }

            newSymbol.setTransformationMatrix(elementData.matrix3D);
            newSymbol.setBitmap(elementData.bitmap);
            newSymbol.setColor(elementData.color);
            newSymbol.setLoop(elementData.loop);
            newSymbol.setType(elementData.symbolType);

            if (newSymbol.type == SymbolType.GRAPHIC)
            {
                var firstFrame:Int = elementData.firstFrame;
                var frameAge:Int = Std.int(_currentFrame - frameData.index);

                if (newSymbol.loopMode == LoopMode.SINGLE_FRAME)
                    newSymbol.currentFrame = firstFrame;
                else if (newSymbol.loopMode == LoopMode.LOOP)
                    newSymbol.currentFrame = (firstFrame + frameAge) % newSymbol._numFrames;
                else
                    newSymbol.currentFrame = firstFrame + frameAge;
            }
        }

        var numObsoleteSymbols:Int = layer.numChildren - numElements;

        for (i in 0...numObsoleteSymbols)
        {
            oldSymbol = cast(layer.removeChildAt(numElements), Symbol);
            _atlas.putSymbol(oldSymbol);
        }
    }

    private function removeFromParent():Void {
        if (parent != null) parent.removeChild(this);
    }

    private function createLayers():Void
    {
        if (_layers != null)
            throw new Error("Method must only be called once");

        _layers = new Sprite();
        addChild(_layers);

        for (i in 0..._numLayers)
        {
            var layer:Sprite = new Sprite();
            layer.name = getLayerData(i).layerName;
            _layers.addChild(layer);
        }
    }

    public function setBitmap(data:Dynamic):Void
    {
        if (data != null)
        {
            var texture:BitmapData = _atlas.getTexture(data.name);

            if (_bitmap != null)
            {
                _bitmap.bitmapData = texture;
            }
            else
            {
                _bitmap = _atlas.getImage(texture);
                addChild(_bitmap);
            }

            trace("parsedJson", Json.stringify(data));

            if(data.position != null)
            {
                _bitmap.x = data.position.x;
                _bitmap.y = data.position.y;
            }else{
                _bitmap.x = data.decomposedMatrix.position.x;
                _bitmap.y = data.decomposedMatrix.position.y;
            }
        }
        else if (_bitmap != null)
        {
            _bitmap.x = _bitmap.y = 0;
            if (_bitmap.parent != null) _bitmap.parent.removeChild(_bitmap);
            _atlas.putImage(_bitmap);
            _bitmap = null;
        }
    }

    private function setTransformationMatrix(data:Dynamic):Void
    {
        sMatrix.setTo(data.m00, data.m01, data.m10, data.m11, data.m30, data.m31);
        transform.matrix = sMatrix;
    }

    private function setColor(data:Dynamic):Void
    {
        if (data != null)
        {
            var mode:String = data.mode;
            var ALPHA_MODES = ["Alpha", "Advanced", "AD"];
            alpha = (ALPHA_MODES.indexOf(mode) >= 0) ? data.alphaMultiplier : 1.0;
        }
        else
        {
            alpha = 1.0;
        }
    }

    private function setLoop(data:String):Void
    {
        if (data != null)
            _loopMode = LoopMode.parse(data);
        else
            _loopMode = LoopMode.LOOP;
    }

    private function setType(data:String):Void
    {
        if (data != null)
            _type = SymbolType.parse(data);
    }

    private function getNumFrames() : Int
    {
        var numFrames : Int = 0;

        for (i in 0..._numLayers)
        {
            var frameDates:Array<Dynamic> = getLayerData(i).frames;
            var numFrameDates:Int = frameDates != null ? frameDates.length : 0;
            var layerNumFrames:Int = numFrameDates != 0 ? frameDates[0].index : 0;

            for (j in 0...numFrameDates)
                layerNumFrames += frameDates[j].duration;

            if (layerNumFrames > numFrames)
                numFrames = layerNumFrames;
        }

        return numFrames == 0 ? 1 : numFrames;
    }

    private function getFrameLabels():Array<FrameLabel>
    {
        var labels:Array<FrameLabel> = [];

        for (i in 0..._numLayers)
        {
            var frameDates:Array<Dynamic> = getLayerData(i).frames;
            var numFrameDates:Int = frameDates != null ? frameDates.length : 0;

            for (j in 0...numFrameDates)
            {
                var frameData:Dynamic = frameDates[j];
                //if ("name" in frameData)
                //todo check this
                if (frameData.name != null)
                {
                    labels[labels.length] = new FrameLabel(frameData.name, frameData.index);
                }else{
                    trace(frameData);
                }
            }
        }

        //labels.sortOn('frame', Array.NUMERIC);
        labels.sort(sortLabels);
        return labels;
    }

    function sortLabels(i1:FrameLabel, i2:FrameLabel) : Int{
        var f1 = i1.frame;
        var f2 = i2.frame;
        if (f1 < f2){
            return -1;
        }else if (f1 > f2){
            return 1;
        }else{
            return 0;
        }
    }

    private function getLayer(layerIndex:Int):Sprite
    {
        return cast(_layers.getChildAt(layerIndex), Sprite);
    }

    public function getNextLabel(afterLabel:String=null):String
    {
        var numLabels:Int = _frameLabels.length;
        var startFrame:Int = getFrame(afterLabel == null ? currentLabel : afterLabel);
        //todo check getFrame

        for (i in 0...numLabels)
        {
            var label:FrameLabel = _frameLabels[i];
            if (label.frame > startFrame)
                return label.name;
        }

        return _frameLabels != null ? _frameLabels[0].name : null; // wrap around
    }

    private function get_currentLabel() : String
    {
        var numLabels:Int = _frameLabels.length;
        var highestLabel:FrameLabel = numLabels != null ? _frameLabels[0] : null;

        for (i in 0...numLabels)
        {
            var label:FrameLabel = _frameLabels[i];

            if (label.frame <= _currentFrame)
                highestLabel = label;
            else
                break;
        }

        return highestLabel != null ? highestLabel.name : null;
    }

    public function getFrame(label : String) : Int
    {
        var numLabels:Int = _frameLabels.length;
        for (i in 0...numLabels)
        {
            var frameLabel:FrameLabel = _frameLabels[i];
            if (frameLabel.name == label)
            {
                return frameLabel.frame;
            }
        }
        return -1;
    }

    private function get_currentFrame() : Int
    {
        return _currentFrame;
    }

    private function set_currentFrame(value : Int) : Int
    {
        while (value < 0)
            value += _numFrames;

        if (_loopMode == LoopMode.PLAY_ONCE)
            _currentFrame = Std.int(MathUtil.clamp(value, 0, _numFrames - 1));
        else
            _currentFrame = Std.int(Math.abs(value % _numFrames));

        if (_composedFrame != _currentFrame)
            update();
        return value;
    }

    private function get_type() : String
    {
        return _type;
    }
    private function set_type(value : String) : String
    {
        if (SymbolType.isValid(value))
            _type = value;
        else
            throw new ArgumentError("Invalid symbol type: " + value);
        return value;
    }

    private function get_loopMode() : String
    {
        return _loopMode;
    }
    private function set_loopMode(value : String) : String
    {
        if (LoopMode.isValid(value))
            _loopMode = value;
        else
            throw new ArgumentError("Invalid loop mode: " + value);
        return value;
    }

    private function get_symbolName() : String
    {
        return _symbolName;
    }
    private function get_numLayers() : Int
    {
        return _numLayers;
    }
    private function get_numFrames() : Int
    {
        return _numFrames;
    }

    // data access

    private function getLayerData(layerIndex : Int) : Dynamic
    {
        return _data.timeline.layers[layerIndex];
    }

    private function getFrameData(layerIndex:Int, frameIndex:Int):Dynamic
    {
        var frames:Array<Dynamic> = getLayerData(layerIndex).frames;
        var numFrames:Int = frames.length;

        for (i in 0...numFrames)
        {
            var frame:Dynamic = frames[i];
            if (frame.index <= frameIndex && frame.index + frame.duration > frameIndex)
                return frame;
        }

        return null;
    }
}