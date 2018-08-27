package com.isartdigital.utils.loader;
import com.isartdigital.utils.events.LoadEventType;
import com.isartdigital.utils.game.StateManager;
import com.isartdigital.utils.sounds.SoundDef;
import com.isartdigital.utils.sounds.SoundManager;
import com.isartdigital.utils.system.DeviceCapabilities;
import howler.Howl;
import howler.Howler;
import js.html.XMLSerializer;
import pixi.flump.Parser;
import pixi.interaction.InteractionEvent;
import pixi.loaders.Loader;
import pixi.loaders.LoaderOptions;
import pixi.loaders.Resource;
import pixi.loaders.ResourceLoader;
import webfont.WebFontLoader;

/**
 * Classe de chargement
 * Cette classe permet de gérer des chargements par lot aussi bien de fichiers textes que de ressources graphiques ou du son
 * @author Mathieu ANTHOINE
 */
class GameLoader extends Loader
{

	/**
	 * liste des fichiers sons à charger
	 */
	private var soundsList:Array<String>;
	
	private var soundsSpecs:Map<String,HowlOptions>;
	
	/**
	 * liste des fichiers chargés
	 */
	private static var txtLoaded:Map<String,Dynamic> = new Map<String,Dynamic>();
	
	/**
	* retourne le contenu chargé pour le chemin de fichier passé en paramètre
	* @param	pFile chemin du fichier
	* @return	ressource (JSon ou Xml)
	*/
	public static function getContent (pFile:String):Dynamic {
		return txtLoaded[Config.txtsPath+pFile];
	}
	
	/**
	* retourne le contenu chargé pour le chemin de fichier passé en paramètre
	* @param	pFile chemin du fichier
	* @return	ressource (csv)
	 */
	public static function getLocalization (pFile:String):String {
		return txtLoaded[Config.langPath+pFile];
	}
	
	public function new() 
	{
		soundsList = [];
		soundsSpecs = new Map();
		super();
		once(LoadEventType.COMPLETE, onCompleted);

	}

	/**
	* ajoute un fichier de type texte à la liste de chargement (JSon ou Xml)
	* @param	pUrl chaine de caractères spécifiant le chemin vers le fichier
	*/
	public function addTxtFile (pUrl:String):Void {
		var lUrl:String = Config.txtsPath + pUrl;
		add(Config.url(lUrl));
	}
	
	/**
	 * ajoute un fichier de localisation csv à la liste de chargement
	 * @param	pUrl chaine de caractères spécifiant le chemin vers le fichier
	 */
	public function addLocalizationFile (pUrl:String):Void {
		var lUrl:String = Config.langPath + pUrl;
		add(Config.url(lUrl));
	}
	
	/**
	* ajoute un fichier d'assets à la liste de chargement
	* @param	pUrl chaine de caractère spécifiant le nom du fichier
	*/
	public function addAssetFile (pUrl:String):Void {	
		var lUrl:String = Config.assetsPath + pUrl;
		add(Config.url(lUrl));		
	}

	/**
	* ajoute une liste de sons à la liste de chargement
	* @param	pUrl chaine de caractère spécifiant le nom du fichier
	*/
	public function addSoundFile (pUrl:String):Void {	
		var lUrl:String = Config.soundsPath + pUrl;
		soundsList.push(lUrl);
		add(Config.url(lUrl));
	}	
	
	/**
	* ajoute un fichier css de polices de caractère
	* @param	pUrl chaine de caractère spécifiant le nom du fichier
	*/
	public function addFontFile (pUrl:String):Void {
		if (DeviceCapabilities.isCocoonJS) return;
		var lUrl:String = Config.fontsPath + pUrl;
		add(Config.url(lUrl));		
	}
	
	private function parseData (pResource:Resource, pNext:Void->Void): Void {
		
		trace (pResource.url + " loaded");
		
		var lUrl:String = pResource.url.split("?")[0];
		
		if (pResource.extension=="css") {
			
			var lData:Array<String> = pResource.data.split(";");
			var lFamilies:Array<String> = [];
			var lReg:EReg = ~/font-family:\s?(.*)/; 
			
			for (i in 0...lData.length) {
				if (lReg.match(lData[i])) lFamilies.push(lReg.matched(1));
			}
			
			var lWebFontConfig = {
				custom: {
					families: lFamilies,
					urls: [Config.fontsPath+"fonts.css"],
				},

				active: pNext
			};
		   
			WebFontLoader.load(lWebFontConfig);			
			return;
		}
		
		if (pResource.extension == "csv" || pResource.extension == "tsv") txtLoaded[lUrl] = pResource.data;
		else
		if (pResource.type==ResourceType.JSON) {
			
			txtLoaded[lUrl] = pResource.data;
			
			if (Reflect.hasField(pResource.data, "meta") && Reflect.hasField(Reflect.field(pResource.data,"meta"), "states") && Reflect.field(Reflect.field(pResource.data,"meta"), "states")) {
				StateManager.addTextures(pResource.data);
			} else if (Reflect.fields(pResource.data).length==1 && Reflect.hasField(pResource.data,"colliders")) {
				StateManager.addColliders(pResource.data);
			} else if(lUrl.substr(-12,12)=="library.json" && Reflect.hasField(pResource.data,"md5") && Reflect.hasField(pResource.data,"movies") && Reflect.hasField(pResource.data,"textureGroups") && Reflect.hasField(pResource.data,"frameRate")) {
				Parser.parse(1,Config.cache)(pResource, pNext);
				return;
			}
			else if (soundsList.length>0) { 
			
				var lData:SoundDef;
				
				for (i in 0...soundsList.length) {
					if (lUrl == soundsList[i]) {
						
						soundsList.splice(i, 1);
						
						lData = pResource.data;
						
						if (DeviceCapabilities.isCocoonJS) {
							if (lData.extensions.indexOf("ogg") == -1) throw "CocoonJs needs ogg sounds. No sound will be played in the application.";
							else lData.extensions = ["ogg"];
						}
					
						for (j in 0...lData.extensions.length) {
							if (Howler.codecs(lData.extensions[j])) {								
								addSounds(lData.fxs,false,lData.extensions,lData.extensions[i],pResource);
								addSounds(lData.musics,true,lData.extensions,lData.extensions[i],pResource);
								break;
							}
						}
						break;
					}
				}
			
			}
			
		} else if (pResource.type==ResourceType.XML) txtLoaded[lUrl] = Xml.parse(new XMLSerializer().serializeToString(pResource.data));
		
		pNext();
	}
	
	private function manageCache (pResource:Resource, pNext:Void->Void): Void {
		if  (pResource.name != pResource.url) pResource.url = Config.url(pResource.url);
		pNext();
	}
	
	private function addSounds (pList:Dynamic, pLoop:Bool, pExtensions:Array<String>, pCodec:String,pResource:Resource): Void {	
		
		var lUrl:String;
		for (lID in Reflect.fields(pList)) {
			//lUrl = Config.url(Config.soundsPath + lID + "." + pCodec);
			// WARNING: Obligé de ne pas ajouter la version dans ce cas précis (bug de Pixi v4)
			lUrl = Config.soundsPath + lID + "." + pCodec;
			soundsSpecs.set(lID, {src:[lUrl], volume:Reflect.field(pList, lID) / 100, loop:pLoop} );
			var lOptions:LoaderOptions = {
				crossOrigin: pResource.crossOrigin,
				parentResource: pResource
			};
			
			add(lUrl , lOptions);
			
		}
	}

	override public function load (?cb:Dynamic):ResourceLoader {
		pre(manageCache); // before
		use(parseData); // after
		
		return super.load();
	}
	
	private function onCompleted (pEvent:InteractionEvent):Void {
		for (lID in soundsSpecs.keys()) {
			SoundManager.addSound(lID, new Howl (soundsSpecs[lID]));
		}
	}
	
}