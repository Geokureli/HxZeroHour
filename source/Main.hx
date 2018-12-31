package;

import flixel.FlxSprite;
import flixel.FlxG;
import art.Pico;

class Main extends openfl.display.Sprite {
    
    static inline public var zoom = 2;
    
    public function new() {
        
        super();
        
        if (stage == null)
            addEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToStage);
        else
            onAddedToStage();
    }
    
    function onAddedToStage(e = null) {
        
        addChild
        ( new flixel.FlxGame
            ( Std.int(stage.stageWidth  / zoom)
            , Std.int(stage.stageHeight / zoom)
            , PlayState
            , Std.int(stage.frameRate)
            , Std.int(stage.frameRate)
            )
        );
	}
}

class PlayState extends flixel.FlxState {
    
    var _pico:Pico;
    
    override public function create():Void {
        super.create();
        
        var bg = new FlxSprite(0, 0, "assets/images/stage4/Background.png");
        FlxG.worldBounds.set(0, 0, bg.width, bg.height);
        FlxG.camera.minScrollX = 0;
        FlxG.camera.minScrollY = 0;
        FlxG.camera.maxScrollX = bg.width;
        FlxG.camera.maxScrollY = bg.height;
        add(bg);
        
        add(_pico = new Pico());
        add(_pico.bullets);
        
        var reticle = new FlxSprite(0, 0, "assets/images/global/Reticle.png");
        FlxG.mouse.load(reticle.pixels, Main.zoom, Std.int(reticle.width / 2), Std.int(reticle.height / 2));
        
        // FlxG.debugger.drawDebug = true;
        if (FlxG.debugger.drawDebug)
            _pico.addDebugDrawObjects(this);
    }
    
    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        
    }
}
