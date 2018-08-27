package com.isartdigital.utils.game.stateObjects;
import com.isartdigital.utils.game.stateObjects.StateAnimatedSprite;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;

/**
 * ...
 * @author Mathieu Anthoine
 */
class StateSprite extends StateObject<Sprite> 
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
		renderer = new Sprite(StateManager.getTextures(lID)[0]);
		renderer.anchor = StateManager.getAnchor(lID);
		super.createRenderer();
	}
	
	/**
	 * Met à jour le renderer
	 */
	override private function updateRenderer ():Void {
		var lID:String = getID();
		renderer.texture = StateManager.getTextures(lID)[0];
		renderer.anchor = StateManager.getAnchor(lID);
		super.updateRenderer();
	}
	
}