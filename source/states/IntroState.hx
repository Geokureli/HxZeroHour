package states;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxState;

class IntroState extends FlxState
{
    override function create()
    {
        super.create();
        
        var text = new FlxText(0, 0, 0, "START", 72);
        text.x = (FlxG.width  - text.width ) / 2;
        text.y = (FlxG.height - text.height) / 2;
        add(text);
    }
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if (FlxG.mouse.justPressed)
            FlxG.switchState(PlayStateTiled.loadJson("assets/data/Tiled/TestLevel.json"));
            // FlxG.switchState(new PlayStateHardCode());
    }
}