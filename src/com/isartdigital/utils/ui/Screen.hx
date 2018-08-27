package com.isartdigital.utils.ui;


/**
 * Classe de base des Ecrans
 * Tous les écrans d'interface héritent de cette classe
 * @author Mathieu ANTHOINE
 */
class Screen extends UIComponent 
{
	
	public function new(pID:String=null) 
	{
		super(pID);
		modalImage = "assets/black_bg.png";
		
	}
	
}