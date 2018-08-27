package com.isartdigital.utils.game;

import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.graphics.Graphics;
import pixi.core.graphics.GraphicsData;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
import pixi.core.sprites.Sprite;

/**
 * Classe utilitaire permettant de tester diverses collisions entre boites, formes et points
 * @author Mathieu ANTHOINE
 * @version 0.9.0
 */
class CollisionManager 
{

	private function new() {}
		
	/**
	 * test la collision entre les boites englobantes de deux DisplayObject
	 * @param	pObjectA objet à tester
	 * @param	pObjectB objet à tester
	 * @return résultat du test de collision
	 */
	public static function hitTestObject(pObjectA:DisplayObject, pObjectB:DisplayObject):Bool {
		
		return getIntersection(pObjectA.getBounds(), pObjectB.getBounds());

	}
	
	/**
	 * test la collision entre l'objet et un point (prend en compte la hitArea si elle est définie). Légère adaptation de la méthode hitTest de la classe InteractionManager
	 * @param	pObject objet à tester
	 * @param	pPoint point exprimé en coordonnées globales
	 * @return	résultat du test de collision
	 */
	public static function hitTestPoint (pItem:DisplayObject, pGlobalPoint:Point):Bool {

		var lPoint:Point=pItem.toLocal(pGlobalPoint);
		var x:Float = lPoint.x;
		var y:Float = lPoint.y;
		
		if (pItem.hitArea != null && pItem.hitArea.contains != null) {
			return pItem.hitArea.contains(x, y);		
		}
		else if (Std.is(pItem, Sprite)) {	
			
			var lSprite:Sprite = cast(pItem, Sprite);
			
			var lWidth:Float = lSprite.texture.frame.width;
			var lHeight:Float = lSprite.texture.frame.height;
			var lX1:Float = -lWidth * lSprite.anchor.x;
			var lY1:Float;
	 
			if (x > lX1 && x < lX1 + lWidth)
			{
				lY1 = -lHeight * lSprite.anchor.y;
				if (y > lY1 && y < lY1 + lHeight) return true;
			}
		}
		else if (Std.is(pItem, Graphics)) {
			var lGraphicsData:Array<GraphicsData> = untyped pItem.graphicsData;		
			for (i in 0...lGraphicsData.length) {
				var lData = lGraphicsData[i];
				 // only deal with fills..
				if (! untyped lData.fill) continue;			
				if(lData.shape!=null && lData.shape.contains(x, y)) return true;
			}
		}
		else if (Std.is (pItem, Container)) {
			var lContainer:Container = cast(pItem, Container);
			var lLength:Int = lContainer.children.length;
			for (i in 0...lLength) {
				if (hitTestPoint(lContainer.children[i], pGlobalPoint)) {
					return true;
				}
			}
		}
		return false;
	}

	/**
	 * 
	 * @param	pHitBoxA boite englobante principale
	 * @param	pHitBoxB boite englobante principale
	 * @param	pPointsA liste de points de collision
	 * @param	pPointsB liste de points de collision
	 * @return  résultat de la collision
	 */
	public static function hasCollision (pHitBoxA:DisplayObject, pHitBoxB:DisplayObject, pPointsA:Array<Point> = null, pPointsB:Array<Point> = null): Bool {
		if (pHitBoxA == null || pHitBoxB == null) return false;
		
		// test des boites de collision principale
		if (!hitTestObject(pHitBoxA,pHitBoxB)) return false;
		
		// si il n'y a pas de boites de collision plus précises on valide
		if (pPointsA == null && pPointsB == null) return true;			
		
		// test points vers la forme de la boite principale 
		if (pPointsA!=null) return testPoints(pPointsA, pHitBoxB);
		if (pPointsB!=null) return testPoints(pPointsB, pHitBoxA);
		
		return false;

	}
	
	/**
	 * teste l'intersection des boites englobantes
	 * @param	pRectA rectangle à tester
	 * @param	pRectB rectangle à tester
	 * @return résultat de l'intersection
	 */
	private static function getIntersection (pRectA:Rectangle, pRectB:Rectangle): Bool {
		return !(pRectB.x > (pRectA.x + pRectA.width) || (pRectB.x + pRectB.width) < pRectA.x || pRectB.y > (pRectA.y + pRectA.height) || (pRectB.y + pRectB.height) < pRectA.y);
	}
	
	/**
	 * 
	 * @param	pHitPoints liste de points de collision (dont le repère est déjà converti en global)
	 * @param	pHitBox boite englobante
	 * @return  résultat de la collision
	 */
	private static function testPoints (pHitPoints:Array<Point>, pHitBox:DisplayObject): Bool {
		var lLength:Int = pHitPoints.length;
		for (i in 0...lLength) {
			if (hitTestPoint(pHitBox,pHitPoints[i])) return true;
		}
			
		return false;
		
	}
	
}