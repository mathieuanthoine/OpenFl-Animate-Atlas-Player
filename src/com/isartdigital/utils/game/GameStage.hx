package com.isartdigital.utils.game;

import com.isartdigital.utils.system.DeviceCapabilities;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Rectangle;

/**
 * Classe en charge de mettre en place la structure graphique du jeu (conteneurs divers)
 * et la gestion du redimensionnement de la zone de jeu en fonction du contexte
 * @author Mathieu ANTHOINE
 */
class GameStage extends Sprite
{
	
	/**
	 * instance unique de la classe GameStage
	 */
	private static var instance: GameStage;

	private var _alignMode: GameStageAlign = GameStageAlign.CENTER;	

	private var _scaleMode: GameStageScale = GameStageScale.SHOW_ALL;
	
	private var _safeZone:Rectangle= new Rectangle(0,0,SAFE_ZONE_WIDTH,SAFE_ZONE_HEIGHT);

	/**
	 * callback de render
	 */
	private var _render:Void->Void;	
	
	/**
	 * largeur minimum pour le contenu visible par défaut
	 */
	private static inline var SAFE_ZONE_WIDTH: Int = 2048;

	/**
	 * hauteur minimum pour le contenu visible par défaut
	 */
	private static inline var SAFE_ZONE_HEIGHT: Int = 1366;
		
	/**
	 * conteneur des pop-in
	 */
	private var popinsSprite:Sprite;
	
	/**
	 * conteneur du Hud
	 */
	private var hudSprite:Sprite;
	
	/**
	 * conteneur des écrans d'interface
	 */
	private var screensSprite:Sprite;
	
	/**
	 * conteneur du jeu
	 */
	private var gameSprite:Sprite;
	
	public function new() 
	{
		super();
				
		gameSprite = new Sprite();		
		addChild(gameSprite);
		
		screensSprite = new Sprite();
		addChild(screensSprite);
		
		hudSprite = new Sprite();
		addChild(hudSprite);
		
		popinsSprite = new Sprite();
		addChild(popinsSprite);

	}
	
	/**
	 * Initialisation de la zone de jeu
	 * @param   pRender Callback qui fait le rendu pour mettre à jour le système de coordonnées avant de reconstruire d'éventuels éléments
	 * @param	pSafeZoneWidth largeur de la safeZone
	 * @param	pSafeZoneHeight hauteur de la safeZone
	 * @param	centerGameSprite centrer ou pas le conteneur des élements InGame
	 * @param	centerScreensSprite centrer ou pas le conteneur des Ecrans
	 * @param	centerPopinSprite centrer ou pas le conteneur des Popins
	 * @param	centerHudSprite centrer ou pas le conteneur
	 */
	public function init (pRender:Void->Void, ?pSafeZoneWidth:UInt = SAFE_ZONE_WIDTH, ?pSafeZoneHeight:UInt = SAFE_ZONE_WIDTH, ?pCenterGameSprite:Bool = false, ?pCenterScreensSprite:Bool = true, ?pCenterPopinSprite:Bool = true, ?pCenterHudSprite:Bool = false):Void {
		
		_safeZone = new Rectangle (0, 0, pSafeZoneWidth, pSafeZoneHeight);
		
		if (pCenterGameSprite) {
			gameSprite.x = safeZone.width / 2;
			gameSprite.y = safeZone.height / 2;
		}
		
		if (pCenterScreensSprite) {
			screensSprite.x = safeZone.width / 2;
			screensSprite.y = safeZone.height / 2;
		}
		
		if (pCenterPopinSprite) {
			popinsSprite.x = safeZone.width / 2;
			popinsSprite.y = safeZone.height / 2;
		}
		
		if (pCenterHudSprite) {
			hudSprite.x = safeZone.width / 2;
			hudSprite.y = safeZone.height / 2;
		}
		
		_render = pRender;
		
	}
	
	/**
	 * Retourne l'instance unique de la classe, et la crée si elle n'existait pas au préalable
	 * @return instance unique
	 */
	public static function getInstance (): GameStage {
		if (instance == null) instance = new GameStage();
		return instance;
	}
	
	/**
	 * Redimensionne la scène du jeu en fonction de la taille disponible pour l'affichage
	 */
	public function resize (): Void {
		
		var lWidth:UInt = DeviceCapabilities.width;
		var lHeight:UInt = DeviceCapabilities.height;
				
		var lRatio:Float = Math.round(10000 * Math.min( lWidth / safeZone.width, lHeight / safeZone.height)) / 10000;
		
		if (scaleMode == GameStageScale.SHOW_ALL) scaleX=scaleY=lRatio;
		else scaleX=scaleY=DeviceCapabilities.textureRatio;
		
		if (alignMode == GameStageAlign.LEFT || alignMode == GameStageAlign.TOP_LEFT || alignMode == GameStageAlign.BOTTOM_LEFT) x = 0;
		else if (alignMode == GameStageAlign.RIGHT || alignMode == GameStageAlign.TOP_RIGHT || alignMode == GameStageAlign.BOTTOM_RIGHT) x = lWidth - safeZone.width * scaleX;
		else x = (lWidth - safeZone.width * scaleX) / 2;
		
		if (alignMode == GameStageAlign.TOP || alignMode == GameStageAlign.TOP_LEFT || alignMode == GameStageAlign.TOP_RIGHT) y = 0;
		else if (alignMode == GameStageAlign.BOTTOM || alignMode == GameStageAlign.BOTTOM_LEFT || alignMode == GameStageAlign.BOTTOM_RIGHT) y = lHeight - safeZone.height * scaleY;
		else y = (lHeight - safeZone.height * scaleY) / 2;
		
		
		render();
		
		dispatchEvent(new Event(Event.RESIZE));// a transmettre { width:lWidth, height:lHeight } );
		trace(DeviceCapabilities.width, DeviceCapabilities.height);
		
	}

	/**
	 * fait le rendu de l'écran
	 */
	public function render (): Void {
		if (_render!=null) _render();
	}	
	
	/*
	 * style d'alignement au sein de l'écran
	 */
	public var alignMode (get, set) : GameStageAlign;
	
	private function get_alignMode( ) { 
		return _alignMode;
	}
	
	private function set_alignMode(pAlign:GameStageAlign) {
		_alignMode = pAlign;
		resize();
		return _alignMode;
	}

	/*
	 * style de redimensionnement au sein de l'écran
	 */
	public var scaleMode (get, set) : GameStageScale;
	
	private function get_scaleMode( ) { 
		return _scaleMode;
	}
	
	private function set_scaleMode(pScale:GameStageScale) {
		_scaleMode = pScale;
		resize();
		return _scaleMode;
	}	
	
	/**
	 * Rectangle délimitant le contenu minimum visible
	 */
	public var safeZone (get, never):Rectangle;
	
	private function get_safeZone () {
		return _safeZone;
	}

	/**
	 * accès en lecture au conteneur de jeu
	 * @return gameSprite
	 */
	public function getGameSprite (): Sprite {
		return gameSprite;
	}
	
	/**
	 * accès en lecture au conteneur d'écrans
	 * @return screensSprite
	 */
	public function getScreensSprite (): Sprite {
		return screensSprite;
	}
	
	/**
	 * accès en lecture au conteneur de hud
	 * @return hudSprite
	 */
	public function getHudSprite (): Sprite {
		return hudSprite;
	}
	
	/**
	 * accès en lecture au conteneur de PopIn
	 * @return popinSprite
	 */
	public function getPopinsSprite (): Sprite {
		return popinsSprite;
	}
				
	/**
	 * détruit l'instance unique et met sa référence interne à null
	 */
	//override public function destroy (?pOptions:EitherType<Bool, DestroyOptions>): Void {
		//instance = null;
		//super.destroy(true);
	//}

}