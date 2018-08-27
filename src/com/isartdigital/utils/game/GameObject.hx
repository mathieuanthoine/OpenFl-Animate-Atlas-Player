package com.isartdigital.utils.game;

import com.isartdigital.utils.events.EventType;
import haxe.extern.EitherType;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject.DestroyOptions;

/**
 * Classe de base des objets interactifs dans le jeu
 * Met à jour automatiquement ses données internes de position et transformation
 * 
 * @author Mathieu ANTHOINE
 */
class GameObject extends Container
{

	public function new() 
	{
		super();
		// Force la mise à jour de la matrices de transformation des éléments constituant le GameObject
		on(EventType.ADDED, updateTransform);	
	}
	
	/**
	 * nettoie et détruit l'instance
	 */
	override public function destroy (?pOptions:EitherType<Bool, DestroyOptions>): Void {
		off(EventType.ADDED, updateTransform);
		super.destroy(pOptions);
	}
	
}