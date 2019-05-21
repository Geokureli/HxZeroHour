package states;

import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;

import haxe.Json;
import haxe.io.Path;

import openfl.Assets;

import art.Pico;
import data.TiledData;

class PlayStateTiled extends FlxState
{
    var data:TiledData;
    var directory:String;
    
    var tilesets:Array<TiledTileset>;
    var objectsByName:Map<String, Dynamic>;
    var pico:Pico;
    var ground:FlxTilemap;
    
    public function new(data:Dynamic, directory:String)
    {
        this.data = data;
        this.directory = Path.removeTrailingSlashes(directory) + "/";
        
        super();
    }
    
    override function create()
    {
        super.create();
        
        var reticle = new FlxSprite(0, 0, "assets/images/global/Reticle.png");
        FlxG.mouse.load(reticle.pixels, Main.zoom, Std.int(reticle.width / 2), Std.int(reticle.height / 2));
        
        parseData();
        
        pico = find("pico");
        findGroup("Hero").add(pico.bullets);
        ground = find("Tiles");
    }
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        FlxG.collide(pico, ground);
    }
    
    function parseData():Void
    {
        objectsByName = new Map();
        
        FlxG.camera.setScrollBoundsRect(0, 0, data.width * data.tilewidth, data.height * data.tileheight, true);
        
        for (layerData in data.layers)
        {
            switch(layerData.type)
            {
                case "objectgroup":
                    var objectLayerData:TiledObjectLayer = cast layerData;
                    var layer = new FlxGroup();
                    objectsByName[layerData.name] = layer;
                    for (objData in objectLayerData.objects)
                    {
                        layer.add(createObject(objData, objectLayerData));
                    }
                    add(layer);
                    
                case "tilelayer":
                    var layer = new TiledTilemap();
                    var tileLayerData:TiledTileLayer = cast layerData;
                    var tileset = getTileset(tileLayerData.data[0]);
                    
                    layer.loadMap(tileLayerData, tileset, pathFromMap(tileset.image));
                    add(layer);
                    objectsByName[layerData.name] = layer;
                    
                default:
                    throw 'unexpected layer.type: ${layerData.type}';
            }
        }
    }
    
    function createObject(data:TiledObject, layerData:TiledObjectLayer):FlxObject
    {
        var pos = FlxPoint.get();
        pos.x = data.x + layerData.x;
        pos.y = data.y + layerData.y;
        
        var obj:FlxObject;
        switch(data.type)
        {
            case "Pico":
                pos.y -= data.height;
                obj = new Pico(pos.x, pos.y);
            default:
                if (data.text != null)
                {
                    inline function nonNull<T>(property:Null<T>, backup:T):T
                    {
                        return property != null ? property : backup;
                    }
                    
                    var text = new FlxText(pos.x, pos.y, data.width, data.text.text);
                    text.font       = nonNull(data.text.fontfamily, FlxAssets.FONT_DEFAULT);
                    text.size       = nonNull(data.text.pixelsize , 16);
                    text.bold       = nonNull(data.text.bold      , false);
                    text.italic     = nonNull(data.text.italic    , false);
                    text.wordWrap   = nonNull(data.text.wrap      , false);
                    text.alignment  = nonNull(data.text.halign    , "left");
                    text.color      = FlxColor.fromString(nonNull(data.text.color , "#000000"));
                    obj = text;
                }
                else if (data.gid != null)
                {
                    pos.y -= data.height;
                    obj = new FlxSprite(pos.x, pos.y, getImagePath(data.gid));
                }
                else 
                    obj = new FlxObject(pos.x, pos.y, data.width, data.height);
        }
        
        obj.angle = data.rotation;
        if (data.properties != null)
        {
            for (property in data.properties)
            {
                switch (property.name)
                {
                    case "scrollFactor.x": obj.scrollFactor.x = property.value;
                    case "scrollFactor.y": obj.scrollFactor.y = property.value;
                    case "borderSize":
                        (cast obj:FlxText).borderSize = property.value;
                        (cast obj:FlxText).borderStyle = OUTLINE;
                    case "borderColor":
                        (cast obj:FlxText).borderColor = FlxColor.fromString(property.value);
                        (cast obj:FlxText).borderStyle = OUTLINE;
                }
            }
        }
        pos.put();
        
        if (data.name != null || data.name != "")
            objectsByName[data.name] = obj;
        
        return obj;
    }
    
    inline function addNamedObject(name:String, obj):Void
    {
        if (name != null || name != "")
            objectsByName[name] = obj;
    }
    
    inline function pathFromMap(path:String):String
    {
        return Path.normalize(directory + path);
    }
    
    public function getTileset(gid:Int):Null<TiledTileset>
    {
        for (tileset in data.tilesets)
        {
            if (tileset.firstgid <= gid && tileset.firstgid + tileset.tilecount > gid)
                return tileset;
        }
        
        return null;
    }
    
    public function getImagePath(gid:Int):Null<String>
    {
        var tileset = getTileset(gid);
        if (tileset != null)
        {
            var image:String;
            if (tileset.tiles == null)
                image = tileset.image;
            else
                image = tileset.tiles[gid - tileset.firstgid].image;
            
            return pathFromMap(image);
        }
        
        return null;
    }
    
    inline public function find(name:String):Dynamic
    {
        return objectsByName[name];
    }
    
    inline public function findSprite(name:String):FlxSprite
    {
        return cast objectsByName[name];
    }
    
    inline public function findGroup<T:FlxBasic>(name:String):FlxTypedGroup<T>
    {
        return cast objectsByName[name];
    }
    
    inline public function findTilemap(name:String):FlxTilemap
    {
        return cast objectsByName[name];
    }
    
    inline static public function fromJson(data:String, directory:String):PlayStateTiled
    {
        return new PlayStateTiled(Json.parse(data), directory);
    }
    
    inline static public function loadJson(path:String):PlayStateTiled
    {
        return fromJson(Assets.getText(path), new Path(path).dir);
    }
}

@:forward
abstract TiledTilemap(FlxTilemap) to FlxTilemap
{
    public function new()
    {
        this = new FlxTilemap();
    }
    
    inline public function loadMap(layerData:TiledTileLayer, tileset:TiledTileset, imagePath:String, buffer = 2):Void
    {
        var tileData = layerData.data;
        for (i in 0...tileData.length)
            if (tileData[i] > 0)
                tileData[i] -= tileset.firstgid;
        
        this.loadMapFromArray
            ( layerData.data
            , layerData.width
            , layerData.height
            , FlxTileFrames.fromBitmapAddSpacesAndBorders
                ( imagePath
                , FlxPoint.get(tileset.tilewidth, tileset.tileheight)
                , FlxPoint.get()
                , FlxPoint.get(buffer, buffer)
			    )
            , tileset.tilewidth
            , tileset.tileheight
            );
	}
}