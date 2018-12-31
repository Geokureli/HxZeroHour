package art;

import flixel.math.FlxVector;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.FlxG;

class Bullet extends flixel.FlxSprite {
    
    public function new () { super(); }
    
    inline public function shoot(x:Float, y:Float, vx:Float, vy:Float, graphic):Bullet {
        
        this.x = x;
        this.y = y;
        velocity.set(vx, vy);
        loadGraphic(graphic);
        offset.x = width  / 2;
        offset.y = height / 2;
        var v = FlxVector.get(vx, vy);
        angle = v.degrees;
        v.put();
        
        return this;
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if(!isOnScreen())
            kill();
    }
}