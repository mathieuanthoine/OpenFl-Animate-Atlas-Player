package;

import animateAtlasPlayer.assets.AssetManager;
import animateAtlasPlayer.core.Animation;
import flash.display.Sprite;
import openfl.events.Event;

/**
 * ...
 * @author Mathieu Anthoine
 */
class Demo extends Sprite 
{

	private var _ninja:Animation;
	
	public function new() 
	{
		super();
		
	}
	
	public function start(assets:AssetManager):Void {
		
		trace (stage.stageWidth, stage.stageHeight);
		
		var lNinjas:Array<Animation> = new Array<Animation>();
		
		for (i in 0...80) {
		
			_ninja = assets.createAnimation("ninja-girl");
			_ninja.x = stage.stageWidth * Math.random();
			_ninja.y = stage.stageHeight * Math.random();
			
			_ninja.frameRate = 24;
			var lScale:Float = 0.75 + 0.25 * Math.random();
			_ninja.scaleX = lScale*(Math.random()>0.5 ? -1 :1);
			_ninja.scaleY = lScale;
			addChild(_ninja);
			lNinjas.push(_ninja);
			_ninja.gotoFrame(Math.floor(_ninja.numFrames * Math.random()));
			
		}
		
		lNinjas.sort(function (pA:Animation, pB:Animation):Int { return pA.y < pB.y ? -1 :1; });
		
		for (i in 0...lNinjas.length) addChild (lNinjas[i]);
		
		//TODO: Tilemap ???
		
	}
	
	
}