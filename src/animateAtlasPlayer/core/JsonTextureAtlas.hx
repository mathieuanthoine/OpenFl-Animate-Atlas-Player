package animateAtlasPlayer.core;

import Type.ValueType;
import animateAtlasPlayer.textures.SubTexture;
import animateAtlasPlayer.textures.TextureAtlas;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;


class JsonTextureAtlas extends TextureAtlas
{
    
	private static var helperRectangle:Rectangle = new Rectangle();
	
	public function new(texture : BitmapData, data : Dynamic = null)
    {
        super(texture, data);
    }

    override private function parseAtlasData(data : Dynamic) : Void
    {
        if (Type.typeof(data) == ValueType.TObject)
        {
            parseAtlasJson(data);
        }
        else
        {
            super.parseAtlasData(data);
        }
    }

    private function parseAtlasJson(data:Dynamic):Void
    {
        var region:Rectangle = helperRectangle;

        for (element in cast(data.ATLAS.SPRITES, Array<Dynamic>))
        {
            var node:Dynamic = element.SPRITE;
            region.setTo(node.x, node.y, node.w, node.h);
            var subTexture:SubTexture = new SubTexture(texture, region, false, null, node.rotated);
            addSubTexture(node.name, subTexture);
        }
    }

}