package com.isartdigital.utils.ui;
import com.isartdigital.utils.events.PointerEventType;
import com.isartdigital.utils.game.ColliderType;
import com.isartdigital.utils.game.StateObject;
import haxe.extern.EitherType;
import pixi.core.display.DisplayObject.DestroyOptions;
import pixi.core.text.Text;
import pixi.core.text.TextStyle;
import pixi.interaction.InteractionEvent;

/**
 * Classe de base des boutons
 * @author Mathieu ANTHOINE
 */
class Button extends StateObject
{
	
	private static inline var UP:Int = 0;
	private static inline var OVER:Int = 1;
	private static inline var DOWN:Int = 2;
	
	private var txt:Text;
	
	private var upStyle:TextStyle;
	private var overStyle:TextStyle;
	private var downStyle:TextStyle;
	
	public function new() 
	{
		
		super();
		colliderType = ColliderType.SELF;
		interactive = true;
		buttonMode = true;
		
		on(PointerEventType.POINTER_OVER, pointerOver);
		on(PointerEventType.POINTER_DOWN, pointerDown);
		on(PointerEventType.POINTER_UP, pointerUp);
		on(PointerEventType.POINTER_OUT, pointerOut);
		on(PointerEventType.POINTER_UPOUTSIDE, pointerOut);

		initStyle();
		txt = new Text("",upStyle);
		txt.anchor.set(0.5, 0.5);
		
		start();
		
	}
	
	private function initStyle ():Void {
		upStyle= new TextStyle({ fontFamily: "Arial", fontSize: 80, fill: 0x000000, align:"center"});
		overStyle=new TextStyle({ fontFamily: "Arial", fontSize: 80, fill: 0xAAAAAA, align:"center"});
		downStyle = new TextStyle({ fontFamily: "Arial", fontSize: 80, fill: 0xFFFFFF, align:"center" });
	}
	
	public function setText(pText:String):Void {
		txt.text=pText;
	}
	
	override private function setModeNormal ():Void {
		setState(STATE_DEFAULT);		
		renderer.gotoAndStop(UP);
		addChild(txt);
		super.setModeNormal();
	}

	private function pointerUp (pEvent:InteractionEvent): Void {
		renderer.gotoAndStop(UP);
		txt.style=upStyle;
	}	
	
	private function pointerDown (pEvent:InteractionEvent): Void {
		renderer.gotoAndStop(DOWN);
		txt.style=downStyle;
	}
	
	private function pointerOver (pEvent:InteractionEvent): Void {
		renderer.gotoAndStop(OVER);
		txt.style=overStyle;
	}
	
	private function pointerOut (pEvent:InteractionEvent): Void {
		renderer.gotoAndStop(UP);
		txt.style=upStyle;
	}
	
	override public function destroy (?pOptions:EitherType<Bool, DestroyOptions>):Void {
		off(PointerEventType.POINTER_OVER, pointerOver);
		off(PointerEventType.POINTER_DOWN, pointerDown);
		off(PointerEventType.POINTER_UP, pointerUp);
		off(PointerEventType.POINTER_OUT, pointerOut);
		off(PointerEventType.POINTER_UPOUTSIDE, pointerOut);
		
		super.destroy(pOptions);
	}
}