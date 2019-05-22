package art;

import flixel.FlxCamera;
import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;

typedef GroupEntity = TypedGroupEntity<FlxSprite>;

class TypedGroupEntity<T:FlxSprite> extends FlxTypedSpriteGroup<T>
{
    public var groupWidth(get, never):Float;
    public var groupHeight(get, never):Float;
    
    public function new (x = 0.0, y = 0.0, maxSize = 0)
    {
        super(x, y, maxSize);
        
        collideAsSprite = true;
    }
    
	#if FLX_DEBUG
    override function add(sprite:T):T
    {
        sprite.ignoreDrawDebug = true;
        return super.add(sprite);
    }
    #end
    
    override function getScreenPosition(?point:FlxPoint, ?Camera:FlxCamera):FlxPoint
    {
        return super.getScreenPosition(point, Camera);
    }
    
    public function get_groupWidth():Float
    {
        return super.get_width();
    }
    
    public function get_groupHeight():Float
    {
        return super.get_height();
    }
    
    override function get_width():Float
    {
        return width;
    }
    
    override function set_width(Width:Float):Float
    {
        // copied from FlxObject
        
        #if FLX_DEBUG
        if (Width < 0)
        {
            FlxG.log.warn("An object's width cannot be smaller than 0. Use offset for sprites to control the hitbox position!");
            return Width;
        }
        #end
        
        return width = Width;
    }
    
    override function get_height():Float
    {
        return height;
    }
    
    override function set_height(Height:Float):Float
    {
        // copied from FlxObject
        
        #if FLX_DEBUG
        if (Height < 0)
        {
            FlxG.log.warn("An object's height cannot be smaller than 0. Use offset for sprites to control the hitbox position!");
            return Height;
        }
        #end
        
        return height = Height;
    }
}