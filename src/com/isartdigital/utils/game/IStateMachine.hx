package com.isartdigital.utils.game;

/**
 * Interface permettant à des classes d'implémenter le modèle Machine à état en respectant les convention de la structure
 * @author Mathieu ANTHOINE
 */

interface IStateMachine 
{
  	/**
	 * méthode appelée à chaque gameLoop. Elle peut faire référence à différentes méthodes au cours du temps
	 */
	public var doAction:Void->Void;
	
	/**
	 * Activation
	 */
	public function start (): Void ;
}