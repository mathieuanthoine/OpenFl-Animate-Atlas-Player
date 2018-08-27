package com.isartdigital.utils.ui.smart;

import com.isartdigital.utils.loader.GameLoader;
import com.isartdigital.utils.system.DeviceCapabilities;
import com.isartdigital.utils.ui.UIPosition;
import flump.filters.AnimateTintFilter;
import flump.json.FlumpJSON;
import flump.library.Keyframe;
import flump.library.Layer;
import flump.library.MovieSymbol;
import flump.library.SpriteSymbol;
import haxe.Json;
import js.Lib;
import pixi.core.display.Container;
import pixi.core.math.Point;
import pixi.flump.Movie;
import pixi.flump.Resource;
import pixi.flump.Sprite;

/**
 * Construit un SmartComponent depuis un Movie Flump
 * @author Mathieu Anthoine
 */
class UIBuilder
{
	
	private function new() {}	
	
	/**
	 * Crée les éléments composant un UIComponent ou SmartComponent
	 * @param	pId assetName de l'écran
	 */
	public static function build (pId:String,pFrame:Int=0) : Array<UIPositionable> {
		
		var lMovie:MovieSymbol=untyped Resource.getResourceForMovie(pId).library.movies.h[pId];
		
		var lObj:Container;
		var lUIPos:Array<UIPositionable> = [];
		var lLayer:Layer;
		var lKeyFrame:Keyframe;
		
		for (i in 0...lMovie.layers.length) {
			lObj = null;
			lLayer = lMovie.layers[i];
			
			lKeyFrame = lLayer.getKeyframeForFrame(pFrame);
			
			if (lKeyFrame == null || lKeyFrame.symbol==null) continue;		
			
			if (lKeyFrame.symbol.data != null && lKeyFrame.symbol.data.className != null) lObj=Type.createInstance(Type.resolveClass(lKeyFrame.symbol.data.className), []);
			else if (lKeyFrame.symbol.baseClass == "Flipbook") lObj = new UIMovie(lKeyFrame.symbolId);
			else if (lKeyFrame.symbol.baseClass == "TextSprite") lObj = new TextSprite(lKeyFrame.symbol.data);
			else if (Std.is (lKeyFrame.symbol, SpriteSymbol)) lObj = new UISprite(lKeyFrame.symbolId);
			else if (lKeyFrame.symbol.baseClass == "flash.display.SimpleButton") lObj = new SmartButton(lKeyFrame.symbolId);
			else {
				var lChild:MovieSymbol=untyped Resource.getResourceForMovie(lKeyFrame.symbolId).library.movies.h[lKeyFrame.symbolId];
				var lChildLayer:Layer;
				for (lChildLayer in lChild.layers) {
					if (lChildLayer.keyframes.length > 1) {
						lObj = new UIMovie(lKeyFrame.symbolId);
						break;
					}
				}
				
				if (lObj == null) {
					lObj = new SmartComponent(lKeyFrame.symbolId);
					cast(lObj,SmartComponent).modal = false;
				}

			}
			
			lObj.name = lLayer.name;
			
			lObj.position= new Point(lKeyFrame.location.x/DeviceCapabilities.textureRatio,lKeyFrame.location.y/DeviceCapabilities.textureRatio);
			lObj.scale= new Point(lKeyFrame.scale.x,lKeyFrame.scale.y);
			lObj.skew = new Point(-lKeyFrame.skew.x, lKeyFrame.skew.y);
			
			if (lKeyFrame.tintMultiplier!=null &&  lKeyFrame.tintMultiplier!= 0) lObj.filters= [new AnimateTintFilter(lKeyFrame.tintColor, lKeyFrame.tintMultiplier)];
			
			var lUIPosition:String = "";
			if (lKeyFrame.data != null) {
				if (Reflect.hasField(lKeyFrame.data,"UIPosition_"+DeviceCapabilities.system)) lUIPosition = Reflect.field(lKeyFrame.data,"UIPosition_"+DeviceCapabilities.system);
				else if (lKeyFrame.data.UIPosition != null) lUIPosition = lKeyFrame.data.UIPosition;
			}
			
			lUIPos.push(getUIPositionable(lObj,lUIPosition));
		
		}
		
		return lUIPos;
		
	}
	
	/**
	 * retourne un UIPositionable correctement construit
	 * @param	pObj Item d'interface
	 * @param	pPosition ancrage "UIPosition"
	 * @return un UIPositionable
	 */
	private static function getUIPositionable (pObj:Container,pPosition:String):UIPositionable {
		
		var lOffset:Point = new Point (0, 0);
		
		if (pPosition == UIPosition.TOP || pPosition == UIPosition.TOP_LEFT || pPosition == UIPosition.TOP_RIGHT ||
			pPosition == UIPosition.BOTTOM || pPosition == UIPosition.BOTTOM_LEFT || pPosition == UIPosition.BOTTOM_RIGHT) lOffset.y = pObj.y;
		if (pPosition == UIPosition.LEFT || pPosition == UIPosition.TOP_LEFT || pPosition == UIPosition.BOTTOM_LEFT ||
			pPosition == UIPosition.RIGHT || pPosition == UIPosition.TOP_RIGHT || pPosition == UIPosition.BOTTOM_RIGHT) lOffset.x = pObj.x;		
				
		return {item:pObj, align:pPosition, offsetX:lOffset.x, offsetY:lOffset.y, update:true};
	}
	
}

