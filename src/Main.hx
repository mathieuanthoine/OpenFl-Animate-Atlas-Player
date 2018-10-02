package;

import animateAtlasPlayer.assets.AssetManager;
import animateAtlasPlayer.core.Animation;
import com.kircode.debug.FPS_Mem;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

/**
 * ...
 * @author Mathieu Anthoine
 */
class Main extends Sprite 
{ 

	public static inline var PUPPET:String = "Astronaut";
	public static inline var NUM:Int = 10;
	
	private var myAnimation:Animation;
	private var assetsMgr:AssetManager;
	private var swap:String = "*gun";
	private var item:String = "gun";
	private var numItem:Int = 2;
	
	private static inline var GRID:Int = 30;
	
	//private var states:Array<String> = ["_idle", "_run" , "_runFire", "_loading", "_fire"];
	private var states:Array<String> = ["_idle", "_run" , "_runFire", "_loading", "_fire"];
	
	
	public function new() 
	{
		super();
		
		var fps_mem:FPS_Mem = new FPS_Mem(10, 10, 0xFFFFFF);
		
		var lSprite:Sprite = new Sprite();
		lSprite.graphics.beginFill(0x000000);
		lSprite.graphics.drawRect(0, 0, fps_mem.width, fps_mem.height);
		lSprite.graphics.endFill();
		
		addChild(lSprite);
		addChild(fps_mem);

        var assets:AssetManager = new AssetManager();
		assets.enqueue("assets/"+PUPPET);
		assets.loadQueue(start);
	}
	
	public function start(assets:AssetManager):Void {
		
		assetsMgr = assets;
		
		var animations:Array<Animation> = new Array<Animation>();
		
		for (i in 0...Main.NUM) {
		
			myAnimation = assetsMgr.createAnimation(Main.PUPPET+states[Math.floor(Math.random()*states.length)]);
			
			if (Main.NUM == 1) {
				myAnimation.x = stage.stageWidth * 0.5;
				myAnimation.y = stage.stageHeight *0.5;
			} else {
				myAnimation.x = GRID * (1+Math.floor(Math.random()*(stage.stageWidth/GRID-1)));
				myAnimation.y = GRID * (1+Math.floor(Math.random()*(stage.stageHeight/GRID-1)));
			}
			
			var lScale:Float = 0.75 + 0.25 * Math.random();
			myAnimation.scaleX = lScale*(Math.random()>0.5 ? -1 :1);
			myAnimation.scaleY = lScale;
			addChild(myAnimation);
			animations.push(myAnimation);
			myAnimation.gotoAndPlay(Math.floor(myAnimation.totalFrames * Math.random()));
			//myAnimation.addItem(swap, assetsMgr.createAnimation("arme1"));
			myAnimation.addEventListener(MouseEvent.CLICK, changeItem);
		}
		
		animations.sort(function (pA:Animation, pB:Animation):Int { return pA.y < pB.y ? -1 :1; });
		
		for (i in 0...animations.length) addChild (animations[i]);
		
		//addEventListener(Event.ENTER_FRAME, changeState);
		
	}
	
	//function changeState(pEvent:Event):Void 
	//{
		//if (myAnimation.currentFrame == myAnimation.totalFrames - 1) {
			//myAnimation.removeEventListener(MouseEvent.CLICK, changeItem);
			//myAnimation = assetsMgr.createAnimation(Main.PUPPET+states[Math.floor(Math.random()*states.length)]);
			////myAnimation.addItem("gun", assetsMgr.createAnimation(currentItem));
		//}
	//}
	
	function changeItem(e:MouseEvent):Void 
	{
		var lNum:Int = Math.floor(Math.random() * (numItem+1));
		var lItem:String = item + lNum;
		trace (lItem);
		if (lNum == numItem) cast(e.currentTarget, Animation).removeItem(swap);
		else cast(e.currentTarget, Animation).addItem(swap,assetsMgr.createAnimation(lItem)); 
	}

}
