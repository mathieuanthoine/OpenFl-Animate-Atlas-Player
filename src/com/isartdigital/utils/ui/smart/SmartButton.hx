package com.isartdigital.utils.ui.smart;
import com.isartdigital.utils.events.MouseEventType;
import com.isartdigital.utils.events.PointerEventType;
import com.isartdigital.utils.events.TouchEventType;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.interaction.InteractionEvent;
import haxe.extern.EitherType;

/**
 * ...
 * @author Mathieu Anthoine
 */
class SmartButton extends SmartComponent
{
	
	public function new(pID:String=null) 
	{
		super(pID);
		modal = false;
		interactive = true;
		buttonMode = true;
		
		on(PointerEventType.POINTER_OVER, pointerOver);
		on(PointerEventType.POINTER_DOWN, pointerDown);
		on(PointerEventType.POINTER_UP, pointerUp);
		on(PointerEventType.POINTER_OUT, pointerOut);
		on(PointerEventType.POINTER_UPOUTSIDE, pointerOut);
	}
	
	override public function build(pFrame:Int = 0):Void 
	{
		super.build(3);		
		hitArea = getBounds().clone();
		pointerOut();
	}
	
	private function clear(): Void {
		while (children.length > 0) removeChildAt(0);
	}
	
	private function pointerUp (pEvent:InteractionEvent=null): Void {
		pointerOut();
	}
	
	private function pointerDown (pEvent:InteractionEvent=null): Void {
		clear();
		super.build(2);
	}
	
	private function pointerOver (pEvent:InteractionEvent=null): Void {
		clear();
		super.build(1);
	}
	
	private function pointerOut (pEvent:InteractionEvent=null): Void {
		clear();
		super.build();
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