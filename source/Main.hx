package;

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
            , states.IntroState
            , Std.int(stage.frameRate)
            , Std.int(stage.frameRate)
            )
        );
	}
}
