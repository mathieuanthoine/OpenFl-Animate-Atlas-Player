package com.isartdigital.utils.game;

import com.isartdigital.utils.system.DeviceCapabilities;
import haxe.Json;
import haxe.extern.EitherType;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject.DestroyOptions;
import pixi.core.graphics.Graphics;
import pixi.core.math.ObservablePoint;
import pixi.core.math.Point;
import pixi.core.math.shapes.Circle;
import pixi.core.math.shapes.Ellipse;
import pixi.core.math.shapes.Rectangle;
import pixi.core.textures.Texture;
import pixi.extras.AnimatedSprite;

/**
 * Classe de base des objets interactifs ayant plusieurs états graphiques
 * Gère la représentation graphique (renderer) et les conteneurs utiles au gamePlay (collider) qui peuvent être de simples boites de collision ou beaucoup plus
 * suivant l'implémentation faite par le développeur dans les classes filles
 * @author Mathieu ANTHOINE
 * @version 2.0.1
 */
class StateObject<T:Container> extends StateMachine
{
	
	/**
	 * rendu de l'état courant
	 */
	public var renderer(default,null):T;
	
	/**
	 * Collider de l'état courant
	 */
	public var collider(default,null):Container;
	
	/**
	 * suffixe du nom d'export des symboles Animés
	 */
	private var RENDERER_SUFFIX (default,null):String = "";
	
	/**
	 * suffixe du nom d'export des symboles collider
	 */
	private var COLLIDER_SUFFIX (default,null):String = "collider";	
	
	/**
	 * etat par défaut
	 */
	private var STATE_DEFAULT (default, null): String = "";
	
	/**
	 * Nom de l'asset (sert à identifier les textures à utiliser)
	 * Prend le nom de la classe Fille par défaut
	 */
	private var assetName:String;
	
	/**
	 * état en cours
	 */
	private var state:String;
	
	/**
	 * Type de collider
	 * Si colliderType est égal à ColliderType.NONE, aucune collision ne se fait, il n'est pas nécessaire d'avoir une boite de collision définie
	 * Si colliderType est égal à ColliderType.SIMPLE, seul un symbole sert de Collider pour tous les états, son nom d'export etant assetName+"_"+COLLIDER_SUFFIX
	 * Si colliderType est égal à ColliderType.MULTIPLE, chaque state correspond à une boite de collision, chaque state va cherche la boite assetName+"_"+RENDERER_SUFFIX+"_"+COLLIDER_SUFFIX
	 * Si colliderType est égal à ColliderType.SELF, hitBox retourne l'AnimatedSprite renderer
	 */
	private var colliderType:ColliderType=ColliderType.NONE;
	
	/**
	 * l'anim est-elle terminée ?
	 */
	public var isAnimEnd (get_isAnimEnd, null):Bool;
	
	private function get_isAnimEnd ():Bool {
		return false;
	}
	
	public function new() 
	{
		super();
	}
	
	/**
	 * défini l'état courant du StateObject
	 * @param	pState nom de l'état (run, walk...)
	 * @param	pLoop l'anim boucle (isAnimEnd sera toujours false) ou pas
	 * @param	pAutoPlay lance l'anim automatiquement
	 * @param	pStart lance l'anim à cette frame
	 */
	private function setState (pState:String, ?pLoop:Bool = false, ?pAutoPlay:Bool=true, ?pStart:UInt = 0): Void {
		
		var lClassName:String = Type.getClassName(Type.getClass(this));
		
		if (state == pState) {
			if (renderer!=null) setBehavior (pLoop,pAutoPlay,pStart);
			return;
		}
		
		if (assetName == null) assetName = lClassName.split(".").pop();
		
		state = pState;
		
		if (renderer == null) {			
			if (colliderType == ColliderType.SELF) {
				if (collider !=null) removeChild(collider);
				collider = null;
			}
			createRenderer();
		} else {
			updateRenderer();
		}
		
		setBehavior(pLoop, pAutoPlay, pStart);
		
		if (collider == null) {
			if (colliderType == ColliderType.SELF) {
				collider = renderer;
				return;
			} else {
				collider = new Container();
				if (colliderType != ColliderType.NONE) createCollider();
			}
			addChild(collider);
		} else if (colliderType == ColliderType.MULTIPLE) {
			removeChild(collider);
			collider = new Container();
			createCollider();
			addChild(collider);
		}
		
	}
	
	/**
	 * Crée le renderer
	 */
	private function createRenderer ():Void {
		renderer.scale.set(1 /DeviceCapabilities.textureRatio , 1 / DeviceCapabilities.textureRatio);
		if (StateManager.rendererAlpha < 1) renderer.alpha = StateManager.rendererAlpha;
		addChild(renderer);
	}
	
	/**
	 * Met à jour le renderer
	 */
	private function updateRenderer ():Void {
		
	}
	
	private function setBehavior (?pLoop:Bool = false, ?pAutoPlay:Bool=true, ?pStart:UInt = 0):Void {

	}

	/**
	 * crée le(s) collider(s) de l'état
	 */
	private function createCollider ():Void {
		
		var lColliders:Map<String,Dynamic> = StateManager.getCollider(assetName+"_" +(colliderType == ColliderType.MULTIPLE && state!="" ? state+ "_": "" )  + COLLIDER_SUFFIX);
		
		var lChild:Graphics;
		
		for (lCollider in lColliders.keys()) {
			lChild = new Graphics();
			lChild.beginFill(0xFF2222);
			if (Std.is(lColliders[lCollider], Rectangle)) {
				lChild.drawRect(lColliders[lCollider].x, lColliders[lCollider].y, lColliders[lCollider].width, lColliders[lCollider].height);
			}
			else if (Std.is(lColliders[lCollider], Ellipse)) {
				lChild.drawEllipse(lColliders[lCollider].x, lColliders[lCollider].y, lColliders[lCollider].width, lColliders[lCollider].height);
			}
			else if (Std.is(lColliders[lCollider], Circle)) {
				lChild.drawCircle(lColliders[lCollider].x,lColliders[lCollider].y,lColliders[lCollider].radius);
			}
			else if (Std.is(lColliders[lCollider], Point)) {
				lChild.drawCircle(0, 0, 10);
			}
			lChild.endFill();
			
			lChild.name = lCollider;
			if (Std.is(lColliders[lCollider], Point)) lChild.position.set(lColliders[lCollider].x, lColliders[lCollider].y);
			else lChild.hitArea = lColliders[lCollider];
			 
			collider.addChild(lChild);
		}
		if (StateManager.colliderAlpha == 0) collider.renderable = false;
		else collider.alpha= StateManager.colliderAlpha;
	}		
	
	/**
	 * retourne l'identifiant complet de l'animation
	 * @return identifiant
	 */
	private function getID(): String {
		if (state == "") return assetName+RENDERER_SUFFIX;
		return assetName+"_" + state+RENDERER_SUFFIX;
	}		
	
	/**
	 * met en pause l'anim
	 */
	public function pause ():Void {
		
	}
	
	/**
	 * relance l'anim
	 */
	public function resume ():Void {
		
	}
	
	/**
	 * retourne la zone de hit de l'objet
	 */
	public var hitBox (get, null):Container;
	 
	private function get_hitBox (): Container {
		return collider;
		// Si on veut cibler une zone plus précise: return collider.getChildByName("nom d'instance du AnimatedSprite de type Rectangle ou Circle dans Animate");
	}

	/**
	 * retourne un tableau de points de collision dont les coordonnées sont exprimées dans le systeme global
	 */
	public var hitPoints (get, null): Array<Point>;
	 
	private function get_hitPoints (): Array<Point> {
		return null;
		// liste de Points : return [collider.toGlobal(collider.getChildByName("nom d'instance du AnimatedSprite de type Point dans Animate").position,collider.toGlobal(collider.getChildByName("nom d'instance du AnimatedSprite de type Point dans Animate").position];
	}
	
	/**
	 * nettoie le renderer avant sa suppression
	 */
	private function destroyRenderer ():Void {
		removeChild(renderer);
		renderer.destroy();
	}
	
	/**
	 * nettoyage et suppression de l'instance
	 */
	override public function destroy (?pOptions:EitherType<Bool, DestroyOptions>): Void {
		
		destroyRenderer();
		if (collider != renderer) {
			removeChild(collider);
			collider.destroy();
			collider = null;
		}
		renderer = null;
		
		super.destroy(pOptions);
	}
	
}