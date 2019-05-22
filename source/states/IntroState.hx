package states;

import haxe.io.Bytes;
import openfl.utils.ByteArray;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import art.ui.ButtonGroup;

import flixel.FlxG;

import haxe.Json;
import haxe.Http;
import haxe.io.Path;

import openfl.Assets;

class IntroState extends TiledState
{
    inline static var UI_PATH = "assets/data/MainMenu.json";
    inline static var LEVEL_PATH = "assets/data/TestLevel.json";
    
    var debug:{?assetsPath:String};
    var levelJson:String;
    var group:ButtonGroup;
    
    public function new ()
    { 
        super(Json.parse(Assets.getText(UI_PATH)), new Path(UI_PATH).dir);
    }
    
    override function create()
    {
        super.create();
        
        var start = findText("start");
        var load = findText("load");
        var save = findText("save");
        var oldGroup = findGroup("Buttons");
        remove(oldGroup);
        group = cast new ButtonGroup(oldGroup.length)
            .addButton(start, selectStart)
            .addButton(load, selectLoad)
            .addButton(save, selectSave);
        add(group);
        
        levelJson = Assets.getText(LEVEL_PATH);
        
        #if cpp
        debug = Json.parse(Assets.getText("assets/data/debug.json"));
        if (debug.assetsPath != null)
        {
            load.visible = false;
            save.visible = false;
            start.text = "LOADING...";
            group.selected = 1;
            
            levelJson = sys.io.File.getContent(debug.assetsPath + "data/TestLevel.json");
            
            load.visible = true;
            save.visible = true;
            start.text = "START";
            group.selected = 0;
        }
        #end
    }
    
    function selectStart():Void
    {
        if (levelJson == null)
            FlxG.switchState(PlayStateTiled.loadJsonAsset(LEVEL_PATH));
        else
            FlxG.switchState(PlayStateTiled.fromJson(levelJson, new Path(LEVEL_PATH).dir));
    }
    
    function selectLoad():Void
    {
        group.active = false;
        // findText("load").text = "COMING SOON";
        var file = new FileReference();
        file.addEventListener(Event.SELECT, (e)->file.load());
        file.addEventListener(Event.COMPLETE,
            (e)->
            {
                levelJson = file.data.toString();
                trace(levelJson);
                selectStart();
            }
        );
        file.browse([new FileFilter("Tiled Level", "*.json")]);
    }
    
    function selectSave():Void
    {
        new FileReference().save(ByteArray.fromBytes(Bytes.ofString(levelJson)), "TestLevel.json");
    }
}