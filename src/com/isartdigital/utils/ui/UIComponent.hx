package com.isartdigital.utils.ui;

import com.greensock.TweenLite;
import com.isartdigital.utils.events.EventType;
import com.isartdigital.utils.events.MouseEventType;
import com.isartdigital.utils.events.TouchEventType;
import com.isartdigital.utils.events.UIEventType;
import com.isartdigital.utils.game.GameObject;
import com.isartdigital.utils.game.GameStage;
import com.isartdigital.utils.ui.UIPositionable;
import com.isartdigital.utils.ui.smart.UIBuilder;
import haxe.extern.EitherType;
import pixi.core.display.DisplayObject;
import pixi.core.display.DisplayObject.DestroyOptions;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.interaction.InteractionEvent;

/**
 * Base de tous les conteneurs d'interface
 * @author Mathieu ANTHOINE
 */
class UIComponent extends GameObject
{

	private var positionables:Array<UIPositionable> = [];
	
	private var isOpened:Bool;
	
	private var modalZone:Sprite;
	
	private var componentName:String;
	
	public var modalImage(default, set):String = "assets/alpha_bg.png";
	
	private var openTween:TweenLite;
	private var closeTween:TweenLite;
	
	
	private function set_modalImage(pImage:String):String {
		modalImage = pImage;

		if (modalZone != null) {
			modalZone.texture = Texture.fromImage(modalImage);
		}
		return modalImage;
	}
	
	public function new(pID:String=null) 
	{
		super();
		if (pID == null) {
			componentName = Type.getClassName(Type.getClass(this));
			componentName = componentName.substring(componentName.lastIndexOf(".") + 1);
		} else componentName = pID;

	}
	
	/**
	 * permet de construire l'UIComponent à partir de l'UIBuilder
	 */
	public function build (pFrame:Int=0) : Void {
		var lItems:Array<UIPositionable> = UIBuilder.build(componentName,pFrame);
		
		for (lItem in lItems) {
			addChild(lItem.item);
			if (lItem.align != "") positionables.push(lItem);
		}
	}

	public function open (): Void {
		if (isOpened) return;
		isOpened = true;
		set_modal(modal);
		GameStage.getInstance().on(EventType.RESIZE, onResize);
		onResize();
		
		emit (UIEventType.OPEN,{target:this});
		
		if (openTween != null) openTween.play();
		else onOpen();
		
	}
	
	private function clearOpenTween (): Void {
		if (openTween != null) {
			openTween.kill();
			openTween = null;
		}
	}
	
	private function onOpen ():Void {
		clearOpenTween();
		emit (UIEventType.OPENED,{target:this});
	}
	
	public var modal (default, set):Bool=true;
	
	private function set_modal (pModal:Bool):Bool {
		modal = pModal;
		
		if (modal) {
			if (modalZone == null) {
				modalZone = new Sprite(Texture.fromImage(Config.url(modalImage)));
				modalZone.interactive = true;
				modalZone.on(MouseEventType.CLICK, stopPropagation);
				modalZone.on(TouchEventType.TAP, stopPropagation);
				positionables.unshift({ item:modalZone, align:UIPosition.FIT_SCREEN, offsetX:0, offsetY:0});
			}
			if (parent != null) parent.addChildAt(modalZone, parent.getChildIndex(this));
		} else {	
			if (modalZone != null) {
				if (modalZone.parent != null) modalZone.parent.removeChild(modalZone);
				modalZone.off(MouseEventType.CLICK, stopPropagation);
				modalZone.off(TouchEventType.TAP, stopPropagation);
				if (positionables[0].item == modalZone) positionables.shift();
				modalZone = null;
			}
		}
		
		return modal;
	}
	
	private function stopPropagation (pEvent:InteractionEvent): Void {}
	
	public function close ():Void {
		if (!isOpened) return;
		isOpened = false;

		emit (UIEventType.CLOSE,{target:this});
		
		if (closeTween != null) closeTween.play();
		else onClose();

	}
	
	private function clearCloseTween (): Void {
		if (closeTween != null) {
			closeTween.kill();
			closeTween = null;	
		}
	}
	
	private function onClose ():Void {
		clearCloseTween();
		modal = false;
		
		emit(UIEventType.CLOSED,{target:this});
		destroy();
	}
	
	/**
	 * déclenche le positionnement des objets
	 * @param pEvent
	 */
	private function onResize (pEvent:InteractionEvent = null): Void {
		for (lObj in positionables) {
			if (lObj.update) {
				if (lObj.align==UIPosition.TOP || lObj.align==UIPosition.TOP_LEFT || lObj.align==UIPosition.TOP_RIGHT) {
					lObj.offsetY = parent.y + lObj.item.y;
				} else if (lObj.align==UIPosition.BOTTOM || lObj.align==UIPosition.BOTTOM_LEFT || lObj.align==UIPosition.BOTTOM_RIGHT) {	
					lObj.offsetY = GameStage.getInstance().safeZone.height - parent.y - lObj.item.y;
				}
				
				if (lObj.align==UIPosition.LEFT || lObj.align==UIPosition.TOP_LEFT || lObj.align==UIPosition.BOTTOM_LEFT) {
					lObj.offsetX = parent.x + lObj.item.x;
				} else if (lObj.align==UIPosition.RIGHT || lObj.align==UIPosition.TOP_RIGHT || lObj.align==UIPosition.BOTTOM_RIGHT) {	
					lObj.offsetX = GameStage.getInstance().safeZone.width - parent.x - lObj.item.x;
				}
				
				lObj.update = false;
			}
			
			UIPosition.setPosition(lObj.item, lObj.align, lObj.offsetX, lObj.offsetY);
		}
	}
	
	/**
	 * nettoie l'instance
	 */
	override public function destroy (?pOptions:EitherType<Bool, DestroyOptions>): Void {
		clearOpenTween();
		clearCloseTween();
		modal = false;
		GameStage.getInstance().off(EventType.RESIZE, onResize);
		super.destroy(pOptions);
	}
	
}