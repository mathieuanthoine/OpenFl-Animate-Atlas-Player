package;

import animateAtlasPlayer.assets.AssetManager;
import com.isartdigital.utils.Config;
import com.isartdigital.utils.game.GameStage;
import com.isartdigital.utils.game.GameStageScale;
import com.kircode.debug.FPS_Mem;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite {
		
	public static var instance:Main;
	
	public function new () {
		
		super ();

		instance = this;
		
		GameStage.getInstance().scaleMode = GameStageScale.SHOW_ALL;
		GameStage.getInstance().init(null, 2160, 1440);
		stage.addChild(GameStage.getInstance());
		
		var fps_mem:FPS_Mem = new FPS_Mem(10, 10, 0xFFFFFF);
		
		fps_mem.scaleX = fps_mem.scaleY = 5;
		
		var lSprite:Sprite = new Sprite();
		lSprite.graphics.beginFill(0x000000);
		lSprite.graphics.drawRect(0, 0, fps_mem.width, fps_mem.height);
		lSprite.graphics.endFill();
		
		GameStage.getInstance().addChild(lSprite);
		GameStage.getInstance().addChild(fps_mem);	
		
		stage.addEventListener(Event.RESIZE, resize);
		resize();
		
		var demo:Demo = new Demo();
		addChild(demo);
        var assets:AssetManager = new AssetManager();
		
		//TODO: méthode d'automatisation en fonction juste du nom du dossier
		// Parsing du nom pour éviter tous les accents et autres tirets...
		// Ou plutot soulever une erreur et demander le renommage ou mettre un trace "info" ou "warning"
		
		assets.enqueueSingle("assets/ninja-girl/spritemap.json", "ninja_girl_spritemap");
		assets.enqueueSingle("assets/bunny/Animation.json", "bunny_animation");
		assets.enqueueSingle("assets/ninja-girl/Animation.json","ninja_girl_animation");
		assets.enqueueSingle("assets/bunny/spritemap.png", "bunny");
		assets.enqueueSingle("assets/ninja-girl/spritemap.png","ninja_girl");		
		assets.enqueueSingle("assets/bunny/spritemap.json","bunny_spritemap");	
		
		assets.loadQueue(demo.start);
		
	}
	
	public function resize (pEvent:Event = null): Void {
		//renderer.resize(DeviceCapabilities.width, DeviceCapabilities.height);
		GameStage.getInstance().resize();
	}
	
	
}