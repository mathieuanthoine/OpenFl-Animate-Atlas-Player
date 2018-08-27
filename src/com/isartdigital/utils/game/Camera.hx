package com.isartdigital.utils.game;

import com.isartdigital.utils.system.DeviceCapabilities;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;

/**
 * Classe Camera
 * @author Mathieu ANTHOINE
 */
class Camera
{

	private var render:Dynamic;
	
	public var target (default,null):DisplayObject;
	public var focus (default, null):DisplayObject;
	
	private var inertiaMax:Point = new Point(40, 20);
	private var inertiaMin:Point = new Point(2, 8);
	private var countH:UInt = 0;
	private var delayH:UInt = 120;
	private var countV:UInt = 0;
	private var delayV:UInt = 60;
	
	/**
	 * instance unique de la classe Camera
	 */
	private static var instance: Camera;

	/**
	 * Retourne l'instance unique de la classe, et la crée si elle n'existait pas au préalable
	 * @return instance unique
	 */
	public static function getInstance (): Camera {
		if (instance == null) instance = new Camera();
		return instance;
	}	
	
	private function new() 
	{
		
	}
	
	/**
	 * Défini la cible de la caméra
	 * @param	pTarget cible
	 */
	public function setTarget (pTarget:DisplayObject):Void {
		target = pTarget;
	}
	
	/**
	 * Défini l'élement à repositionner au centre de l'écran
	 * @param	pFocus focus
	 */
	public function setFocus(pFocus:DisplayObject):Void {
		focus = pFocus;
	}
	
	/**
	 * recadre la caméra
	 * @param	pDelay si false, la caméra est recadrée instantannément
	 */
	private function changePosition (?pDelay:Bool=true) :Void {
		
		countH++;
		countV++;
		
		var lCenter:Rectangle = DeviceCapabilities.getScreenRect(target.parent);				
		var lFocus:Point = getFocusCoord();
		var lInertiaX:Float = pDelay ? getInertiaX() : 1;
		var lInertiaY:Float = pDelay ? getInertiaY() : 1;
		
		var lDeltaX:Float = (lCenter.x + lCenter.width / 2 - lFocus.x - target.x) / lInertiaX;
		var lDeltaY:Float = (lCenter.y + lCenter.height / 2 - lFocus.y - target.y) / lInertiaY;
		
		target.x+= lDeltaX;
		target.y+= lDeltaY;
	}
	
	/**
	 * retourne une inertie en X variable suivant le temps
	 * @return inertie en X
	 */
	private function getInertiaX() : Float {
		if (countH > delayH) return inertiaMin.x;
		return inertiaMax.x + (inertiaMin.x-inertiaMax.x)*countH/delayH;
	}

	/**
	 * retourne une inertie en Y variable suivant le temps
	 * @return inertie en Y
	 */	
	private function getInertiaY() : Float {
		if (countV > delayV) return inertiaMin.y;
		return inertiaMax.y + (inertiaMin.y-inertiaMax.y)*countV/delayV;
	}
	
	/**
	 * cadre instantannément la caméra sur le focus
	 */
	public function setPosition():Void {
		GameStage.getInstance().render();
		changePosition(false);
	}
	
	/**
	 * cadre la caméra sur le focus avec de l'inertie
	 */
	public function move():Void {
		changePosition();
	}
	
	/**
	 * remet à zéro le compteur qui fait passer la caméra de l'inertie en X maximum à minimum
	 */
	public function resetX():Void {
		countH = 0;
	}

	/**
	 * remet à zéro le compteur qui fait passer la caméra de l'inertie en Y maximum à minimum
	 */
	public function resetY():Void {
		countV = 0;
	}
	
	/**
	 * retourne les coordonnées du focus dans le repère de la target
	 */
	public function getFocusCoord ():Point {
		return target.toLocal(focus.position, focus.parent);
	}
	
	/**
	 * détruit l'instance unique et met sa référence interne à null
	 */
	public function destroy (): Void {
		instance = null;
	}
	
}