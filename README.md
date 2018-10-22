OpenFl Animate Atlas Player
===========================

Player for Adobe Animate Atlas export format based on the [Starling version][1].

Usage
=====

Loads an atlas
-------------- 

		public function new() {}
			var assets:AssetManager = new AssetManager();
			// target the folder that contains the Animation.json, spritemap.json and spritemap.png
			assets.enqueue("assets/MyAtlas"); 
			assets.loadQueue(start);
		}
	
* you can replace Animation.json by a zip version : Animation.zip
* the Atlas folder needs to be in an assets folder that is embed with the project (loaded resources in the next version)
* If you want several animations in the same Atlas, in Animate, create a MovieClip that contains MovieClips you want to add to the Atlas.
* A MovieClip is considered as an Animation if its timeline has 2 frames minimum
* The atlas (MyAtlas) is the name of the MovieClip container
	
Launch an animation
-------------------
	
		private function start(assetsMgr:AssetManager):Void {
		
			var myAnimation:Animation = assetsMgr.createAnimation("player_run");
			addChild(myAnimation);
		}

* The name of the animation (player_run) is the name of the MovieClip Atlas or its children	
* classic MovieClip methods are availables (play, stop, gotoAndPlay, gotoAndStop, nextFrame...) and properties (currentFrame, totalFrames...)

Dynamic change in an animation
------------------------------
You can dynamically attach an element in the animation, like swaping a weapon in the hand of the player with an other.
* The MovieClip that will contains the new asset has to be in a layer prefixed by an asterisk.
<img src="https://github.com/mathieuanthoine/OpenFl-Animate-Atlas-Player/blob/dev/imgs/layer.PNG">

* You can have several layers with the same name in differents MovieClips of the Animation and or on different layers.

		var anItem:AnItem = new AnItem(); // Can be any DisplayObject including Animations
		myAnimation.addItem("*aTag",anItem);
	
* You can remove the attached item

		myAnimation.removeItem("*aTag");

Version 1.7
===========
* support for windows and mobile exports
	
TODO List
---------
* Clean Code
* Implements disabled parts of code

History
========
Version 1.6
-----------
* value of currentFrame similar to Animate (1 to totalFrames)

Version 1.5
-----------
* Support for animation in asset folder embed or not

Version 1.4
-----------
* Bugs Fix
* Support for dynamic changes in assets added to an Animation

Version 1.3
-----------
* support for Animation.zip file (Animation.json zip)

Earlier versions
----------------
* conversion of Starling version




[1]: https://github.com/Gamua/Starling-Extension-Adobe-Animate]
