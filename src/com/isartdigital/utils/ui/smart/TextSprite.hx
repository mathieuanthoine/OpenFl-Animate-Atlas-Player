package com.isartdigital.utils.ui.smart;

import pixi.core.display.Container;
import pixi.core.graphics.Graphics;
import pixi.core.math.Point;
import pixi.core.text.Text;
import pixi.core.text.TextStyle;

typedef UITextStyle = {
	var x: Float;
	var y: Float;
	var width: Float;
	var height: Float;
	var align: String;
	var fontFamily: String;
	var fontSize: Float;
	var fontWeight: String;
	var fontStyle: String;
	var fill: String;
	var text:String;
	var wordWrap:Int;
	var verticalAlign:String;
}

/**
 * ...
 * @author Mathieu Anthoine
 */
class TextSprite extends Container
{

	/**
	 * assigner la méthode de parsing des textes pour localiser comme traiter des flags personnalisés
	 */
	public static var parseText:String->String=defaultParseText;
	
	/**
	 * accès en lecture à l'instance de Text
	 */
	public var textField(default, null):Text;
	
	/**
	 * raccourci pour acceder à la propriété text de l'instance de texte
	 */
	public var text (get, set):String;
	
	private function get_text ():String {
		return textField.text;
	}
	
	private function set_text (pText:String):String {
		textField.text = pText;
		return pText;
	}
	
	public function new(pData:UITextStyle) {
		super();
		
		var lStyle:TextStyle = new TextStyle();
		
		lStyle.fontFamily = pData.fontFamily;
		lStyle.fontSize = pData.fontSize;
		lStyle.fill = pData.fill;
		lStyle.align = pData.align;
		lStyle.fontStyle = pData.fontStyle;
		lStyle.fontWeight = pData.fontWeight;
		lStyle.wordWrap = pData.wordWrap == 1;
		lStyle.wordWrapWidth = pData.width;
		
		textField = new Text(parseText(StringTools.replace(pData.text,"</BR>","\r")), lStyle);
		if (pData.align == "center") {
			textField.anchor.x = 0.5;
			textField.x = pData.x + pData.width/2;
		}
		else if (pData.align == "right") {
			textField.anchor.x = 1;
			textField.x = pData.x + pData.width;
		}
		else textField.x = pData.x;
		
		if (pData.verticalAlign == "top") textField.y = pData.y;
		else if (pData.verticalAlign == "bottom") {
			textField.y = pData.y+pData.height;
			textField.anchor.y = 1;
		}
		else {
			textField.anchor.y = 0.5;
			textField.y = pData.y+pData.height/2;
		}
		
		
		if (Config.debug) {
			var lGraph:Graphics = new Graphics();
			lGraph.beginFill(0x00FFFF);
			lGraph.drawRect(pData.x, pData.y, pData.width, pData.height);
			lGraph.endFill();
			lGraph.alpha = 0.5;
			addChild(lGraph);
		}
		
		addChild(textField);		
		
	}
	
	private static function defaultParseText (pTxt:String):String {
		return pTxt;
	}
	
}