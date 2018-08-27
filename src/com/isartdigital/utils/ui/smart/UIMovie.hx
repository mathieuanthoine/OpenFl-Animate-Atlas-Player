package com.isartdigital.utils.ui.smart;
import com.isartdigital.utils.game.stateObjects.StateFlumpMovie;

/**
 * ...
 * @author Mathieu Anthoine
 */
class UIMovie extends StateFlumpMovie
{

	public function new(pAssetName:String) 
	{
		super();
		assetName = pAssetName;
		setState(STATE_DEFAULT,true);
	}
	
}