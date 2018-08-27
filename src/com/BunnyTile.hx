package com;

import openfl.display.Tile;

/**
 * ...
 * @author Mathieu Anthoine
 */
class BunnyTile extends Tile
{

	private var rotSpeed:Float;
	
	public function new(type:Int, x:Float, y:Float ) 
	{

		super(type, x, y);
		
		rotSpeed = 1 + Math.random() * 360 / 60;

	}
	
	public function doAction () : Void {
		rotation += rotSpeed;
	}
	

}