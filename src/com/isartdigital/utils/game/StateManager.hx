package com.isartdigital.utils.game;
import haxe.Json;
import pixi.core.math.ObservablePoint;
import pixi.core.math.Point;
import pixi.core.math.shapes.Circle;
import pixi.core.math.shapes.Ellipse;
import pixi.core.math.shapes.Rectangle;
import pixi.core.textures.Texture;

typedef CollidersDef = {
	colliders:Dynamic
}

/**
 * Manager chargé de gérer des opérations globales sur les StateObjects et les ressources associées
 * @author Mathieu Anthoine
 */
class StateManager 
{
	/**
	 * définition des textures (nombre d'images)
	 */
	private static var texturesDefinition:Map<String,Int>;
	
	/**
	 * définition des ancres des textures
	 */
	private static var texturesAnchor:Map<String,ObservablePoint>;
	
	/**
	 * cache des textures de tous les StateObject
	 */
	private static var texturesCache:Map<String,Array<Texture>>;
	
	/**
	 * nombre de zéro à ajouter pour construire un nom de frame
	 */
	private static var digits:String;	
	
	/**
	 * longueur de la numérotation des textures
	 */
	public static var textureDigits (default, set) :UInt = 4;
	
	private static function set_textureDigits (pDigits:UInt) : UInt {
		digits = "";
		for (i in 0...pDigits) digits += "0";
		return textureDigits = pDigits;	
	}
	
	/**
	 * niveau d'alpha des rendus
	 */
	public static var rendererAlpha:Float = 1;
	
	/**
	 * niveau d'alpha des colliders
	 */
	public static var colliderAlpha:Float = 0;
	
	/**
	 * cache des colliders de tous les StateObject
	 */
	private static var collidersCache:Map<String,Map<String,Dynamic>>;
	
	/**
	 * Analyse et crée les définitions de textures
	 * @param	pJson objet contenant la description des assets
	 */
	static public function addTextures (pJson:Json): Void {
		
		var lFrames:Dynamic = Reflect.field(pJson, "frames");
		
		if (texturesDefinition == null) texturesDefinition = new Map<String,Int>();
		if (texturesAnchor == null) texturesAnchor = new Map<String,ObservablePoint>();
		if (texturesCache == null) texturesCache = new Map<String,Array<Texture>>();
		if (digits == null) textureDigits = textureDigits;
		
		var lID:String;
		var lNum:Int;
		
		for (lName in Reflect.fields(lFrames)) {
			
			lID = lName.split(".")[0];
			lNum = Std.parseInt(lID.substr(-1*textureDigits));
			if (lNum != null) lID = lID.substr(0, lID.length - textureDigits);
			
			if (texturesDefinition[lID] == null) texturesDefinition[lID] = lNum == null ? 1 : lNum;
			else if (lNum > texturesDefinition[lID]) texturesDefinition[lID] = lNum;
			
			if (texturesAnchor[lID] == null) texturesAnchor[lID] = Reflect.field(lFrames, lName).pivot;
			
		}
		
	}
	
	/**
	 * Cherche dans le cache général de textures le tableau de textures correspondant au state et le retourne.
	 * Si le tableau de texture n'éxiste pas, il le crée et le stocke dans le cache
	 * @param	pID ID complet de l'anim
	 * @return	le tableau de texture correspondant au state de l'instance
	 */
	public static function getTextures(pID:String):Array<Texture> {
		if (texturesCache[pID] == null) {
			var lFrames:UInt = texturesDefinition[pID];
			if (lFrames == 1) texturesCache[pID] =[Texture.fromFrame(pID+".png")];
			else {
				texturesCache[pID] = new Array<Texture>();
				for (i in 1...lFrames+1) texturesCache[pID].push(Texture.fromFrame(pID+(digits + i).substr(-1*textureDigits) + ".png"));
			}
			
		}
		
		return texturesCache[pID];
	}
	
	/**
	 * Vide le cache de textures correspondant à la description passée en paramètres
	 * @param	pJson objet contenant la description des assets
	 */
	static public function clearTextures (pJson:Json): Void {
		
		var lFrames:Dynamic = Reflect.field(pJson, "frames");
		
		if (texturesDefinition == null) return;
		
		var lID:String;
		var lNum:Int;
		
		for (lID in Reflect.fields(lFrames)) {
			
			lID = lID.split(".")[0];
			lNum = Std.parseInt(lID.substr(-1*textureDigits));
			if (lNum != null) lID = lID.substr(0, lID.length - textureDigits);
			
			texturesDefinition[lID] = null;
			texturesAnchor[lID] = null;
			texturesCache[lID] = null;
		}
	}
	
	/**
	 * Créer tous les Colliders
	 * @param	pJson Nom du fichier contenant la description des colliders
	 */
	static public function addColliders (pColliderDef:CollidersDef): Void {
		
		if (collidersCache == null) collidersCache = new Map<String,Map<String,Dynamic>>();
		
		var lItem;
		var lObj;
		
		for (lName in Reflect.fields(pColliderDef.colliders)) {
			lItem = Reflect.field(pColliderDef.colliders, lName);
			collidersCache[lName] = new Map<String,Dynamic>();			
			
			for (lObjName in Reflect.fields(lItem)) {
				lObj = Reflect.field(lItem, lObjName);
				
				if (lObj.type == "Rectangle") collidersCache[lName][lObjName] = new Rectangle(lObj.x, lObj.y, lObj.width, lObj.height);
				else if (lObj.type == "Ellipse") collidersCache[lName][lObjName] = new Ellipse(lObj.x, lObj.y, lObj.width/2, lObj.height/2);
				else if (lObj.type == "Circle") collidersCache[lName][lObjName] = new Circle(lObj.x, lObj.y, lObj.radius);
				else if (lObj.type == "Point") collidersCache[lName][lObjName] = new Point(lObj.x, lObj.y);

			}
			
		}
		
	}
	
	/**
	 * Cherche dans le cache général d'ancres l'ancre correspondant au state et la retourne.
	 * @param	pID ID complet de l'anim
	 * @return	l'ancre correspondant au state de l'instance
	 */
	public static function getAnchor(pID:String):ObservablePoint {
		return texturesAnchor[pID];
	}
	
	/**
	 * Cherche dans le cache général des colliders, celui correspondant au state demandé
	 * @param	pState State de l'instance
	 * @return	le collider correspondant
	 * @return
	 */
	public static function getCollider (pState:String):Map<String,Dynamic> {
		return collidersCache[pState];
	}
	
}