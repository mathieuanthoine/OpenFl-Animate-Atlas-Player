package com.isartdigital.utils.game.stateObjects;
import com.isartdigital.utils.system.DeviceCapabilities;
import flump.MoviePlayer;
import pixi.flump.Movie;
import pixi.flump.Resource;

/**
 * ...
 * @author Mathieu Anthoine
 */
class StateFlumpMovie extends StateObject<Movie> 
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
		renderer = new Movie(lID);
		super.createRenderer();
	}
	
	/**
	 * Met à jour le renderer
	 */
	override private function updateRenderer ():Void {
		removeChild(renderer);
		renderer.destroy();
		createRenderer();
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
		return !renderer.playing;
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