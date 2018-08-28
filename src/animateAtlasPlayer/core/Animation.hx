package animateAtlasPlayer.core;

import openfl.display.DisplayObjectContainer;
import openfl.events.Event;

class Animation extends DisplayObjectContainer
{
    public var currentLabel(get, never) : String;
    public var currentFrame(get, set) : Int;
    public var currentTime(get, set) : Float;
    public var frameRate(get, set) : Float;
    public var loop(get, set) : Bool;
    public var numFrames(get, never) : Int;
    public var isPlaying(get, never) : Bool;
    public var totalTime(get, never) : Float;

    private var _symbol : Symbol;
    private var _behavior : MovieBehavior;
    private var _cumulatedTime : Float = 0.0;
    
    public function new(data : Dynamic, atlas : AnimationAtlas)
    {
        super();
        _symbol = new Symbol(data, atlas);
        _symbol.update();
        addChild(_symbol);
        
        _behavior = new MovieBehavior(this, onFrameChanged, atlas.frameRate);
        _behavior.numFrames = _symbol.numFrames;
        _behavior.addEventListener(Event.COMPLETE, onComplete);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
        play();
    }
    
    private function onComplete(pEvent:Event ) : Void
    {
        // TODO: dispatchEventWith(Event.COMPLETE);
        dispatchEvent(new Event(Event.COMPLETE));
    }
    
    private function onFrameChanged(frameIndex : Int) : Void
    {
        _symbol.currentFrame = frameIndex;
    }
    
    public function play() : Void
    {
        _behavior.play();
    }
    
    public function pause() : Void
    {
        _behavior.pause();
    }
    
    public function stop() : Void
    {
        _behavior.stop();
    }
    
    public function gotoFrame(indexOrLabel : Dynamic) : Void
    {
        currentFrame = (Std.is(indexOrLabel, String)) ? 
        _symbol.getFrame(Std.string(indexOrLabel)) : Std.int(indexOrLabel);
    }
    
    public function addFrameAction(indexOrLabel : Dynamic, action: Void->Void) : Void
    {
        var frameIndex : Int = (Std.is(indexOrLabel, String)) ? 
        _symbol.getFrame(Std.string(indexOrLabel)) : Std.int(indexOrLabel);
        
        _behavior.addFrameAction(frameIndex, action);
    }
    
    public function removeFrameAction(indexOrLabel : Dynamic, action: Void->Void) : Void
    {
        var frameIndex : Int = (Std.is(indexOrLabel, String)) ? 
        _symbol.getFrame(Std.string(indexOrLabel)) : Std.int(indexOrLabel);
        
        _behavior.removeFrameAction(frameIndex, action);
    }
    
    public function removeFrameActions(indexOrLabel : Dynamic) : Void
    {
        var frameIndex : Int = (Std.is(indexOrLabel, String)) ? 
        _symbol.getFrame(Std.string(indexOrLabel)) : Std.int(indexOrLabel);
        
        _behavior.removeFrameActions(frameIndex);
    }
    
	private function onEnterFrame (pEvent:Event):Void {
		//TODO: on peut se baser sur le temps entre deux frames si on veut (getTimer)
		advanceTime(0.016);
	}
	
    public function advanceTime(time:Float) : Void
    {
		
		var frameRate : Float = _behavior.frameRate;
        var prevTime : Float = _cumulatedTime;
        
        _behavior.advanceTime(time);
        _cumulatedTime += time;
        
        if (Std.int(prevTime * frameRate) != Std.int(_cumulatedTime * frameRate))
        {
            _symbol.nextFrame_MovieClips();
        }
    }
    
    public function getNextLabel(afterLabel : String = null) : String
    {
        return _symbol.getNextLabel(afterLabel);
    }
    
    public function getFrame(label : String) : Int
    {
        return _symbol.getFrame(label);
    }
    
    private function get_currentLabel() : String
    {
        return _symbol.currentLabel;
    }
    
    private function get_currentFrame() : Int
    {
        return _behavior.currentFrame;
    }
    private function set_currentFrame(value : Int) : Int
    {
        _behavior.currentFrame = value;
        return value;
    }
    
    private function get_currentTime() : Float
    {
        return _behavior.currentTime;
    }
    private function set_currentTime(value : Float) : Float
    {
        _behavior.currentTime = value;
        return value;
    }
    
    private function get_frameRate() : Float
    {
        return _behavior.frameRate;
    }
    private function set_frameRate(value : Float) : Float
    {
        _behavior.frameRate = value;
        return value;
    }
    
    private function get_loop() : Bool
    {
        return _behavior.loop;
    }
    private function set_loop(value : Bool) : Bool
    {
        _behavior.loop = value;
        return value;
    }
    
    private function get_numFrames() : Int
    {
        return _behavior.numFrames;
    }
    private function get_isPlaying() : Bool
    {
        return _behavior.isPlaying;
    }
    private function get_totalTime() : Float
    {
        return _behavior.totalTime;
    }
}

