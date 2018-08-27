package com.isartdigital.utils.game.stateObjects;
import pixi.flump.Sprite;

/**
 * ...
 * @author Mathieu Anthoine
 */
class StateFlumpSprite extends StateObject<Sprite> 
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
		renderer = new Sprite(lID);
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
	
}