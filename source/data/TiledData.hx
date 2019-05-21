package data;

import flixel.text.FlxText.FlxTextAlign;

typedef TiledData =
{ type      :String
, width     :Int
, height    :Int
, tilewidth :Int
, tileheight:Int
, tilesets  :Array<TiledTileset>
, layers    :Array<TiledLayer>
}

typedef TiledText =           // defaults
{ text          :String
, ?fontfamily   :String       // sans-seriff
, ?color        :String       // #000000
, ?pixelsize    :Int          // 16
, ?bold         :Bool         // false
, ?italic       :Bool         // false
, ?strikeout    :Bool         // false
, ?underline    :Bool         // false
, ?wrap         :Bool         // false
, ?kerning      :Bool         // true
, ?halign       :FlxTextAlign // left
, ?valign       :String       // top
}

typedef TiledObject =
{ name          :String
, type          :String
, x             :Int
, y             :Int
, width         :Int
, height        :Int
, rotation      :Float
, visible       :Bool
, id            :Int
, ?gid          :Int
, ?text         :TiledText
, properties    :Array<{name:String, type:String, value:Dynamic}>
}

typedef TiledLayer =
{ name      :String
, type      :String
, x         :Float
, y         :Float
, visible   :Bool
, opacity   :Float
}

typedef TiledObjectLayer =
{ > TiledLayer
, draworder:String
, objects  :Array<TiledObject>
}

typedef TiledTileLayer =
{ > TiledLayer
, data  :Array<Int>
, width :Int
, height:Int
}

typedef TiledTileset =
{ name          :String
, firstgid      :Int
, spacing       :Int
, margin        :Int
, columns       :Int
, tilecount     :Int
, tilewidth     :Int
, tileheight    :Int
// tiled
, ?image        :String
, ?imageheight  :Int
, ?imagewidth   :Int
// collection
, ?grid:
    { height     :Int
    , orientation:String
    , width      :Int
    }
, ?tiles:Array
    <   { id         :Int
        , image      :String
        , imageheight:Int
        , imagewidth :Int
        }
    >
}