package data;

import flixel.math.FlxVector;
import art.Bullet;

// typedef BulletGroup = TypedBulletGroup<Bullet>;

class BulletGroup extends flixel.group.FlxGroup.FlxTypedGroup<Bullet> {
// class TypedBulletGroup<T:Bullet> extends flixel.group.FlxGroup.FlxTypedGroup<T> {
    
    public var defaultGraphic:String = null;
    
    public function new (defaultGraphic:String = "assets/images/global/Bullet.png") {
        super();
        
        this.defaultGraphic = defaultGraphic;
    }
    
    public function shoot(x:Float, y:Float, vx:Float, vy:Float, ?graphic:String):Bullet {
        
        if (graphic == null)
            graphic = defaultGraphic;
        
        return recycle(Bullet).shoot(x, y, vx, vy, graphic);
    }
    
    
    inline public function shootWithOffsets
    ( x         :Float
    , y         :Float
    , vx        :Float
    , vy        :Float
    , parOffset :Float
    , perpOffset:Float
    , ?graphic
    ):Bullet {
        
        if ((vx != 0 || vy != 0) && (parOffset != 0 || perpOffset != 0)) {
            
            var v = FlxVector.get(vx, vy).normalize();
            
            x += (v.x * parOffset) + (-v.y * perpOffset);
            y += (v.y * parOffset) + ( v.x * perpOffset);
            
            v.put();
        }
        
        return shoot(x, y, vx, vy, graphic);
    }
}