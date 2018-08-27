package com.isartdigital.utils.system;
import com.isartdigital.utils.Config;
import com.isartdigital.utils.system.MonitorField;
import dat.controllers.Controller;
import dat.gui.GUI;
import haxe.Json;
import haxe.ds.ObjectMap;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;

/**
 * Classe permettant de manipuler des parametres du projet au runtime
 * Si la propriété Config.debug et à false aucun code n'est executé à l'exception de la méthode setSettings.
 * Il n'est pas nécessaire de retirer ou commenter le code du Monitor dans la version "release" du jeu
 * @version 2.2.1
 * @author Mathieu ANTHOINE
 * @author Chadi HUSSER
 */
class Monitor 
{
	/**
	 * map des instances surveillé associés à leur GUI respectifs
	 */
	private static var guiMap : ObjectMap<Dynamic,GUI> = new ObjectMap<Dynamic, GUI>();
	
	private static function isPoint(pDynamic:Dynamic) : Bool {
		return Reflect.hasField(pDynamic, "x") || Reflect.hasField(pDynamic, "_x");
	}
	
	private static function getName(pDynamic:Dynamic) : String {
		var lClass = Type.getClass(pDynamic);
		if (lClass == null) return "NotAClass";
		return Type.getClassName(lClass).split(".").pop();
	}
	
	/**
	 * Affecte les réglages contenu dans le Json à l'instance
	 * @param	pJson Json de réglage
	 * @param	pTarget Instance à régler
	 */
	public static function setSettings(pJson:Json, pTarget:Dynamic): Void {
		
		var lPoints : Array<Dynamic> = new Array<Dynamic>();
		
		var lRemembered = Reflect.field(pJson, "remembered");
		
		var lPreset = Reflect.field(pJson, "preset");
		
		var lDefault = Reflect.field(lRemembered, lPreset);
		
		var lObject;
		
		for (lObjectName in Reflect.fields(lDefault)) {
			lObject = Reflect.field(lDefault, lObjectName);
			lPoints.push(lObject);
		}
		
		var lSimpleObjectContainer = lPoints[0];
		
		for (lObjectName in Reflect.fields(lSimpleObjectContainer)) {
			lObject = Reflect.field(lSimpleObjectContainer, lObjectName);
			Reflect.setField(pTarget, lObjectName, lObject); 
		}
		
		var lFolders = Reflect.field(pJson, "folders");	
		var lTargetFolder = Reflect.fields(lFolders)[0];
		var lPlayerFolders = Reflect.field(lTargetFolder, "folders");
		
		var lPropertyNames : Array<String> = new Array<String>();
		for (lFolderName in Reflect.fields(lPlayerFolders)) {
			lPropertyNames.push(lFolderName);
		}

		for (i in 1...lPoints.length) {
			Reflect.setField(pTarget, lPropertyNames[i-1], new Point(Reflect.field(lPoints[i], "x"), Reflect.field(lPoints[i], "y")));
		}
	}
	
	/**
	 * Surveille les propriétés d'une instance et affiche le GUI associé
	 * @param	pTarget Instance à surveiller
	 * @param	pGuiFields Tableau des propriétés à surveiller
	 * @param	pJson Json 
	 * @param	pName Nom optionnel à affichager dans le Monitor
	 */
	public static function start(pTarget:Dynamic, ?pFields:Array<MonitorField>, ?pJson:Json,?pName:String) : Void {
		
		if (!Config.debug) return;
		
		if (pFields == null) {
			if (Std.is(pTarget, DisplayObject)) {
				pFields = [{ name:"position",step:1}];
			} else pFields = [];
		}
		
		var lCurrentGui : GUI;
		if (pJson != null) lCurrentGui = new GUI({load:pJson});
		else lCurrentGui = new GUI();

		var lName : String = pName==null ? getName(pTarget) : pName;
		
		guiMap.set(pTarget, lCurrentGui);
		
		var lField;
		var lDataField;
		var lFolder:GUI;
		
		var lController:Controller;
		
		lCurrentGui.remember(pTarget);
		
		var lPointMap : Map<MonitorField, Dynamic> = new Map<MonitorField, Dynamic>();
		
		var lTargetFolder : GUI = lCurrentGui.addFolder(lName);
		if (pJson == null) lTargetFolder.open();
		
		var lTargetField;
		for (lGuiField in pFields) {
			lTargetField = Reflect.field(pTarget, lGuiField.name);
		
			if (lTargetField == null) throw "La propriété " + lGuiField.name + " n'est pas présente sur l'objet " + lName;
			
			if (lGuiField.isColor == null || !lGuiField.isColor) {
				if(isPoint(lTargetField)) {
					lPointMap.set(lGuiField, lTargetField);
				} else {
					lController = lTargetFolder.add(pTarget, lGuiField.name, lGuiField.constrain);
					setFieldInGui(lController, lGuiField.min, lGuiField.max, lGuiField.step, lGuiField.onChange);
				}
			} else {
				lController = lTargetFolder.addColor(pTarget, lGuiField.name);
				setFieldInGui(lController, lGuiField.min, lGuiField.max, lGuiField.step, lGuiField.onChange);
			}
		}
	
		for (lGuiField in lPointMap.keys()) 
		{
			lField = lPointMap.get(lGuiField);
			lCurrentGui.remember(lField);
			lFolder = lTargetFolder.addFolder(lGuiField.name);
			if (pJson == null) lFolder.open();
			
			var lPointValue : Map<String, Dynamic> = new  Map<String, Dynamic>();
			lPointValue.set("x", null);
			lPointValue.set("y", null);
			
			if (lGuiField.constrain != null) {
				if (Std.is(lGuiField.constrain, Array)) {
					lPointValue.set("x", []);
					lPointValue.set("y", []);
					for (i in 0...lGuiField.constrain.length) {
						lPointValue.get("x").push(lGuiField.constrain[i].x);
						lPointValue.get("y").push(lGuiField.constrain[i].y);
					}
				}
				else {
					lPointValue.set("x", {});
					lPointValue.set("y", {});
					for (lValueName in Reflect.fields(lGuiField.constrain)) {
						Reflect.setField(lPointValue["x"], lValueName, Reflect.field(lGuiField.constrain, lValueName).x);
						Reflect.setField(lPointValue["y"], lValueName, Reflect.field(lGuiField.constrain, lValueName).y);
					}
				}
			}
			
			lController = lFolder.add(lField, "x", lPointValue["x"]);
			setFieldInGui(lController,
				lGuiField.min == null ? null : lGuiField.min.x, 
				lGuiField.max == null ? null : lGuiField.max.x, 
				lGuiField.step == null ? null : lGuiField.step.x, 
				lGuiField.onChange
			);

			lController = lFolder.add(lField, "y", lPointValue["y"]);
			setFieldInGui(lController,
				lGuiField.min == null ? null : lGuiField.min.y, 
				lGuiField.max == null ? null : lGuiField.max.y, 
				lGuiField.step == null ? null : lGuiField.step.y, 
				lGuiField.onChange
			);
		}
		
		//Bouton removeGUI 
		Reflect.setField(pTarget, "removeGUI", function() {stop(pTarget); });
		lCurrentGui.add(pTarget, "removeGUI");
	}

	private static function setFieldInGui(pController:Controller, pMin:Dynamic, pMax:Dynamic, pStep:Dynamic, pOnChange:Dynamic) : Void {
		if (pMin != null) pController.min(pMin);
		if (pMax != null) pController.max(pMax);
		if (pStep != null) pController.step(pStep);
		if (pOnChange != null) pController.onChange(pOnChange);
		
		pController.listen();
	}
	
	/**
	 * Arrète de surveiller les propriétés d'une instance et supprime le GUI associé
	 * @param	pTarget Référence vers l'objet monitoré
	 */
	public static function stop(pTarget:Dynamic) : Void {
		if (!Config.debug) return;
		 
		var lGui:GUI = guiMap.get(pTarget);
		if (lGui == null) throw "L'instance " + getName(pTarget) + " n'est pas surveillée";
		
		lGui.destroy();
		guiMap.remove(pTarget);
	}
	
	/**
	 * vide le Monitor
	 */
	public static function clear ():Void {
		
		if (!Config.debug) return;

		for (lGui in guiMap) lGui.destroy();
		guiMap = null;
	}	

}
