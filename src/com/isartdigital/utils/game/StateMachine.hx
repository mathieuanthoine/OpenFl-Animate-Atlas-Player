package com.isartdigital.utils.game;
import haxe.extern.EitherType;
import pixi.core.display.DisplayObject.DestroyOptions;

/**
 * Implémentation de base d'une Machine à état
 * expose de façon publique sa méthode doAction qui peut faire référence à différentes méthodes prévues (doActionVoid, doActionNormal) ou spécifiques définies par ses classes filles
 * Par convention le changement de référence de doAction se fait via des méthodes setMode (setModeVoid, setModeAction) qui peuvent aussi contenir des paramètres d'initialisation
 * @author Mathieu ANTHOINE
 */
class StateMachine extends GameObject implements IStateMachine
{
	
	/**
	 * méthode appelée à chaque gameLoop. Elle peut faire référence à différentes méthodes au cours du temps
	 */
	public var doAction:Void->Void;
	
	public function new() 
	{
		super();
		setModeVoid();	
	}
		
	/**
	 * applique le mode "ne fait rien"
	 */
	private function setModeVoid (): Void {
		doAction = doActionVoid;
	}
	
	/**
	 * fonction vide destinée à maintenir la référence de doAction sans rien faire
	 */
	private function doActionVoid (): Void {}

	
	/**
	 * applique le mode normal (mode par defaut)
	 */
	private function setModeNormal(): Void {
		doAction = doActionNormal;
	}
	
	/**
	 * fonction destinée à appliquer un comportement par defaut
	 */
	private function doActionNormal (): Void {}
	
	/**
	 * Activation
	 */
	public function start (): Void {
		setModeNormal();
	}
	
	/**
	 * nettoie et détruit l'instance
	 */
	override public function destroy (?pOptions:EitherType<Bool, DestroyOptions>): Void {
		setModeVoid();
		super.destroy(pOptions);
	}

	
}