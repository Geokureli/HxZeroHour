package states;

import art.Pico;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;

import haxe.io.Path;
import haxe.Json;

import openfl.Assets;

class PlayStateTiled extends TiledState
{
    var pico:Pico;
    var ground:FlxTilemap;
    
    // public function new(data:Dynamic, directory:String)
    // {
    //     super(data, directory);
    // }
    
    override function create()
    {
        super.create();
        
        var reticle = new FlxSprite(0, 0, "assets/images/global/Reticle.png");
        FlxG.mouse.load(reticle.pixels, Main.zoom, Std.int(reticle.width / 2), Std.int(reticle.height / 2));
        
        pico = find("pico");
        findGroup("Hero").add(pico.bullets);
        ground = find("Tiles");
    }
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        FlxG.collide(pico, ground);
    }
    
    inline static public function fromJson(data:String, directory:String):PlayStateTiled
    {
        return new PlayStateTiled(Json.parse(data), directory);
    }
    
    inline static public function loadJsonAsset(path:String):PlayStateTiled
    {
        return fromJson(Assets.getText(path), new Path(path).dir);
    }
    
    inline static public function loadJsonFile(path:String):PlayStateTiled
    {
        
        return fromJson(Assets.getText(path), new Path(path).dir);
    }
}