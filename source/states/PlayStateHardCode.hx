package states;

import art.Pico;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

class PlayStateHardCode extends flixel.FlxState {
    
    var pico:Pico;
    var ground:FlxObject;
    
    override public function create():Void {
        super.create();
        
        FlxG.camera.setScrollBoundsRect(0, 0, FlxG.width * 4, FlxG.height * 2, true);
        
        var bg = new FlxSprite(0, 0, "assets/images/stage4/Background.png");
        bg.scrollFactor.set(0.5, 0.5);
        add(bg);
        
        ground = new FlxObject(FlxG.worldBounds.x, FlxG.height - 80, FlxG.worldBounds.width, 80);
        ground.immovable = true;
        
        add(pico = new Pico(50));
        add(pico.bullets);
        
        var reticle = new FlxSprite(0, 0, "assets/images/global/Reticle.png");
        FlxG.mouse.load(reticle.pixels, Main.zoom, Std.int(reticle.width / 2), Std.int(reticle.height / 2));
        
        FlxG.debugger.drawDebug = true;
        if (FlxG.debugger.drawDebug) {
            
            add(ground);
            pico.addDebugDrawObjects(this);
        }
    }
    
    override public function update(elapsed:Float):Void {
        
        FlxG.collide(pico, ground);
        
        super.update(elapsed);
    }
    
    inline static function getBounds(obj:FlxObject):String {
        
        return '(${obj.x}, ${obj.y}, ${obj.width}, ${obj.height})';
    }
}