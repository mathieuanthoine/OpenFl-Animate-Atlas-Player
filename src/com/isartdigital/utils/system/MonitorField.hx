package com.isartdigital.utils.system;
import haxe.extern.EitherType;
import pixi.core.math.Point;

/**
 * ...
 * @author Chadi Husser
 */
typedef MonitorField = {
	var name : String;
	@:optional var min : Dynamic;
	@:optional var max : Dynamic;
	@:optional var step : Dynamic;
	@:optional var constrain : Dynamic;
	@:optional var isColor : Bool;
	@:optional var onChange : Dynamic->Void;
}