package com.isartdigital.utils.ui;

import pixi.core.display.Container;

/**
 * @author Mathieu Anthoine
 */
typedef UIPositionable = {
	var item:Container;
	var align:String;
	var offsetX:Float;
	var offsetY:Float;
	@:optional var update:Bool;
}