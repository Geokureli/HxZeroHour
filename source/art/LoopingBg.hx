package art;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;

class LoopingBg extends FlxTypedGroup<FlxSprite>
{
    public function new (graphic:FlxGraphicAsset, x = 0.0, y = 0.0, maxSize = 2)
    {
        super(maxSize);
        
        var width:Float;
        while (maxSize > 0)
        {
            width = add(new FlxSprite(x + width * maxSize, y, graphic)).width;
            maxSize--;
        }
    }
}