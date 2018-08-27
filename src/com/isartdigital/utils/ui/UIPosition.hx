package com.isartdigital.utils.ui;
import com.isartdigital.utils.system.DeviceCapabilities;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;

/**
 * Classe utilitaire permettant de gérer le repositionnement des élements d'interface dans l'écran
 * @author Mathieu ANTHOINE
 */

class UIPosition 
{
	public static inline var LEFT:String="left";
	public static inline var RIGHT:String="right";
	public static inline var TOP:String="top";
	public static inline var BOTTOM:String="bottom";
	public static inline var TOP_LEFT:String="topLeft";
	public static inline var TOP_RIGHT:String="topRight";
	public static inline var BOTTOM_LEFT:String="bottomLeft";
	public static inline var BOTTOM_RIGHT:String="bottomRight";
	
	public static inline var FIT_WIDTH:String="fitWidth";
	public static inline var FIT_HEIGHT:String="fitHeight";
	public static inline var FIT_SCREEN:String = "fitScreen";
	
	private function new() {}
	
	/**
	* 
	* @param	pTarget DisplayObject à positionner
	* @param	pPosition type de positionnement
	* @param	pOffsetX décalage en X (positif si c'est vers l'interieur de la zone de jeu sinon en négatif)
	* @param	pOffsetY décalage en Y (positif si c'est vers l'interieur de la zone de jeu sinon en négatif)
	*/
	static public function setPosition (pTarget:DisplayObject, pPosition:String, pOffsetX:Float = 0, pOffsetY:Float = 0): Void {
				
		var lScreen:Rectangle = DeviceCapabilities.getScreenRect(pTarget.parent);
		
		var lTopLeft:Point = new Point (lScreen.x, lScreen.y);
		var lBottomRight:Point = new Point (lScreen.x+lScreen.width,lScreen.y+lScreen.height);
		
		if (pPosition == TOP || pPosition == TOP_LEFT || pPosition == TOP_RIGHT) pTarget.y = lTopLeft.y + pOffsetY;
		if (pPosition == BOTTOM || pPosition == BOTTOM_LEFT || pPosition == BOTTOM_RIGHT) pTarget.y = lBottomRight.y - pOffsetY;
		if (pPosition == LEFT || pPosition == TOP_LEFT || pPosition == BOTTOM_LEFT) pTarget.x = lTopLeft.x + pOffsetX;
		if (pPosition == RIGHT || pPosition == TOP_RIGHT || pPosition == BOTTOM_RIGHT) pTarget.x = lBottomRight.x - pOffsetX;
		
		if (pPosition == FIT_WIDTH || pPosition == FIT_SCREEN) {
			pTarget.x = lTopLeft.x;
			untyped pTarget.width = lBottomRight.x - lTopLeft.x;
		}
		if (pPosition == FIT_HEIGHT || pPosition == FIT_SCREEN) {
			pTarget.y = lTopLeft.y;
			untyped pTarget.height = lBottomRight.y - lTopLeft.y;
		}

	}
	
}
