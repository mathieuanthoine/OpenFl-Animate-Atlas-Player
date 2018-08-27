package com.isartdigital.utils.game.stateObjects;
import haxe.Json;
import pixi.core.math.ObservablePoint;
import pixi.core.textures.Texture;
import pixi.extras.AnimatedSprite;

/**
 * ...
 * @author Mathieu Anthoine
 */
class StateAnimatedSprite extends StateObject<AnimatedSprite> 
{
	
	public function new() 
	{
		super();		
	}
	
	/**
	 * Crée le renderer
	 */
	override private function createRenderer ():Void {
		var lID:String = getID();
		renderer = new AnimatedSprite(StateManager.getTextures(lID));
		renderer.anchor = StateManager.getAnchor(lID);
		super.createRenderer();
	}
	
	/**
	 * Met à jour le renderer
	 */
	override private function updateRenderer ():Void {
		var lID:String = getID();
		renderer.textures = StateManager.getTextures(lID);
		renderer.anchor = StateManager.getAnchor(lID);
		super.updateRenderer();
	}
	
	override private function setBehavior (?pLoop:Bool = false, ?pAutoPlay:Bool=true, ?pStart:UInt = 0):Void {
		renderer.loop = pLoop;
		renderer.gotoAndStop(pStart);
		if (pAutoPlay) renderer.play();
		super.setBehavior();
	}
	
	override private function get_isAnimEnd ():Bool {
		if (renderer == null) return super.get_isAnimEnd();
		if (renderer.loop) return super.get_isAnimEnd();
		if (renderer.currentFrame == renderer.totalFrames-1) return true;
		return super.get_isAnimEnd();
	}
	
	/**
	 * met en pause l'anim
	 */
	override public function pause ():Void {
		if (renderer != null) renderer.stop();
	}
	
	/**
	 * relance l'anim
	 */
	override public function resume ():Void {
		if (renderer != null) renderer.play();
	}
	
	/**
	 * nettoie le renderer avant sa suppression
	 */
	override private function destroyRenderer ():Void {
		renderer.stop();
		super.destroyRenderer();
	}
	
}