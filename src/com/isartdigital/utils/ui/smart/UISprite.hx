package com.isartdigital.utils.ui.smart;
import com.isartdigital.utils.game.stateObjects.StateFlumpSprite;


/**
 * ...
 * @author Mathieu Anthoine
 */
class UISprite extends StateFlumpSprite
{

	public function new(pAssetName:String) 
	{
		super();
		assetName = pAssetName;
		setState(STATE_DEFAULT);
	}
	
}