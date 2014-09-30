package com.feirlau.map.tilemap {
    import com.feirlau.global.GlobalUtils;
    import com.feirlau.global.ModelLocator;
    import com.feirlau.resourceLoader.GameResourceProvider;
    import com.pblabs.engine.resource.ImageResource;
    
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    public class TileMap {
        private static const BIG_MAP_NME:String = "bigMap.jpg";
        private var mapId_:String = "1001";
        private var width_:int = 600;
        private var height_:int = 300;
        private var column_:int = 10;
        private var row_:int = 10;
        private var tileWidth_:int = 60;
        private var tileHeight_:int = 30;
        private var tileWidthHalf_:int = 30;
        private var tileHeightHalf_:int = 15;
        private var mapItemCol_:int = 5;
        private var mapItemRow_:int = 5;
        private var mapItemWidth_:int = 240;
        private var mapItemHeight_:int = 120;
        private var mapDataWidth_:int = 240 * 5;
        private var mapDataHeight_:int =120 * 5;
        private var sceneCol_:int = 17;
        private var sceneRow_:int = 20;
        private var sceneColHalf_:int = 8;
        private var sceneRowHalf_:int = 10;
        private var sceneMinX_:int = 0;
        private var sceneMinY_:int = 0;
        private var sceneSize_:Point = new Point();
        private var tiles_:Vector.<TileMapItem> = new Vector.<TileMapItem>();
        private var mapLoader_:GameResourceProvider;
        
        public static function buildTileMap(mapId:String, mapInfo:XML, size:Point):TileMap {
            var result:TileMap = new TileMap(mapId, size, parseInt(mapInfo.@col.toString()), parseInt(mapInfo.@row.toString()),
                parseInt(mapInfo.@tileWidth), parseInt(mapInfo.@tileHeight), parseInt(mapInfo.@mapItemWidth), parseInt(mapInfo.@mapItemHeight));
            result.buildTiles(mapInfo.text().toString());
            return result;
        }
        
        
        public function TileMap(mapId:String, size:Point, col:int, row:int, tileW:int = 60, tileH:int = 30, mapItemW:int = 240, mapItemH:int = 120) {
            mapId_ = mapId;
            sceneSize_.x = size.x;
            sceneSize_.y = size.y;
            column_ = col;
            row_ = row;
            tileWidth_ = tileW;
            tileHeight_ = tileH;
            tileWidthHalf_ = tileWidth_ / 2;
            tileHeightHalf_ = tileHeight_ / 2;
            width_ = column_ * tileWidth_;
            height_ = row_ * tileHeight_;
            var tmpW:int = sceneSize_.x;
            var tmpH:int = sceneSize_.y;
            sceneCol_ = Math.ceil((tmpW - tileWidthHalf_) / tileWidth_) + 1;
            sceneRow_ = Math.ceil(tmpH / tileHeightHalf_) + 1 ;
            sceneColHalf_ = Math.floor(sceneCol_ / 2);
            sceneRowHalf_ = Math.floor(sceneRow_ / 2);
            sceneMinX_ = column_ - sceneCol_;
            if(sceneMinX_ < 0) sceneMinX_ = 0;
            sceneMinY_ = row_ - sceneRow_;
            if(sceneMinY_ < 0) sceneMinY_ = 0;
            mapItemWidth_ = mapItemW;
            mapItemHeight_ = mapItemH;
            mapItemCol_ = Math.ceil(tmpW / mapItemWidth_) + 1;
            mapItemRow_ = Math.ceil(tmpH / mapItemHeight_) + 1;
            mapDataWidth_ = mapItemWidth_ * mapItemCol_;
            mapDataHeight_ = mapItemHeight_ * mapItemRow_;
            mapRect_.width = sceneSize_.x;
            mapRect_.height = sceneSize_.y;
            mapLoader_ = new GameResourceProvider("TileMap_" + mapId_);
        }

        public function buildTiles(mapData:String):void {
            tiles_ = new Vector.<TileMapItem>();
            var dataArray:Array = mapData.split(",");
            for(var i:int = 0; i < row; i++) {
                for(var j:int = 0; j < column; j++) {
                    var dataItem:String = dataArray[i * column + j];
                    var dataValue:Number = dataItem?parseInt(dataItem):0;
                    if(isNaN(dataValue)) dataValue = 0;
                    var tileItem:TileMapItem = new TileMapItem();
                    tileItem.type = dataValue;
                    tiles_.push(tileItem);
                }
            }
            mapLoader_.load(null, null, onBigMapResources);
        }
        private function onBigMapResources(phase:int):Array {
            return [{url: bigMapUrl, type: ImageResource}];
        }
        private function get bigMapUrl():String {
            return GlobalUtils.contactPath(ModelLocator.getInstance().sceneRoot, mapId_, BIG_MAP_NME);
        }
        
        private var startX_:int = -1;
        private var startY_:int = -1;
        private var mapStartX_:int = -1;
        private var mapStartY_:int = -1;
        private var bigMapRect_:Rectangle = new Rectangle();
        private var mapRect_:Rectangle = new Rectangle();
        private var needUpdate_:Boolean = true;
        private var needUpdateMap_:Boolean = true;
        private var curPoint_:Point = new Point();
        public function moveSceneMap(curX:int, curY:int):void {
            curPoint_.x = curX;
            curPoint_.y = curY;
            var tmpX:int = curX - sceneColHalf_;
            if(tmpX < 0) tmpX = 0;
            else if(tmpX > sceneMinX_) tmpX = sceneMinX_;
            var tmpY:int = curY - sceneRowHalf_;
            if(tmpY < 0) tmpY = 0;
            else if(tmpY > sceneMinY_) tmpY = sceneMinY_;
            if(startX_ != tmpX) {
                startX_ = tmpX;
                needUpdate_ = true;
            }
            if(startY_ != tmpY) {
                startY_ = tmpY;
                needUpdate_ = true;
            }
            tmpX = startY_ * tileWidth_ + (startY_ & 1) * tileWidthHalf_;
            mapRect_.x = tmpX % mapItemWidth_;
            tmpX = Math.floor(tmpX / mapItemWidth_);
            if(tmpX != mapStartX_) {
                mapStartX_ = tmpX;
                needUpdateMap_ = true;
            }
            tmpY = startY_ * tileHeightHalf_;
            mapRect_.y = tmpY % mapItemHeight_;
            tmpY = Math.floor(tmpY / mapItemHeight_);
            if(tmpY != mapStartY_) {
                mapStartY_ = tmpY;
                needUpdateMap_ = true;
            }
            if(needUpdateMap_) {
                loadCurMapMedia();
            }
        }
        
        private function loadCurMapMedia():void {
            mapLoader_.load(onLoaded, null, onMapResources);
        }
        private function onLoaded(phase:int):void {
            updateMapData();
            needUpdateMap_ = false;
        }
        
        private function onMapResources(phase:int):Array {
            var result:Array = new Array();
            for(var i:int = 0; i < mapItemCol_; i++) {
                for(var j:int = 0; j < mapItemRow_; j++) {
                    var url:String = getMapItemUrl(mapStartX_ + i, mapStartY_ + j);
                    result.push({url: url, type: ImageResource});
                }
            }
            return result;
        }
        
        private var mapData_:BitmapData;
        public function get mapData():BitmapData {
            if(needUpdateMap_) {
                updateMapData();
                needUpdateMap_ = false;
            }
            return mapData_;
        }
        
        public var dirtyHandler:Function;
        private function updateMapData():void {
            if(mapData_ == null) mapData_ = new BitmapData(mapDataWidth_, mapDataHeight_, false);
            var resource:ImageResource = mapLoader_.getResource(bigMapUrl, ImageResource) as ImageResource;
            var matrix:Matrix = new Matrix();
            if(resource && resource.bitmapData) {
                var tmpScaleX:Number = resource.bitmapData.width/width_;
                var tmpScaleY:Number = resource.bitmapData.height/height_;
                if(bigMapRect_.isEmpty()) {
                    bigMapRect_.width = Math.round(tmpScaleX * mapDataWidth_);
                    bigMapRect_.height = Math.round(tmpScaleY * mapDataHeight_);
                }
                bigMapRect_.x = mapStartX_ * mapItemWidth_ * tmpScaleX;
                bigMapRect_.y = mapStartY_ * mapItemHeight_ * tmpScaleY;
                matrix.scale(1/tmpScaleX, 1/tmpScaleY);
                mapData_.draw(resource.bitmapData, matrix, null, null, bigMapRect_);
            }
            matrix = new Matrix();
            for(var i:int = 0; i < mapItemCol_; i++) {
                for(var j:int = 0; j < mapItemRow_; j++) {
                    var url:String = getMapItemUrl(mapStartX_ + i, mapStartY_ + j);
                    resource = mapLoader_.getResource(url, ImageResource) as ImageResource;
                    if(resource && resource.bitmapData) {
                        matrix.tx = i * mapItemWidth_;
                        matrix.ty = j * mapItemHeight_;
                        mapData_.draw(resource.bitmapData, matrix);
                    }
                }
            }
            if(dirtyHandler != null) {
                dirtyHandler(this);
            }
        }
        
        public function get mapRect():Rectangle {
            return mapRect_;
        }
        
        public function get curPoint():Point {
            return curPoint_;
        }
        
        private function getMapItemUrl(i:int, j:int):String {
            return GlobalUtils.contactPath(ModelLocator.getInstance().sceneRoot, mapId_, i + "_" + j + ".jpg");
        }
        
        public function getTileByPoint(x:int, y:int):TileMapItem {
            return tiles_[y * column_ + x];
        }
        /**
        * Convert mouse point to tile point
        **/
        public function getTilePoint(x:int, y:int):Point {
            var p1:Point = new Point(startX_, startY_);
            var p2:Point = new Point(startX_, startY_);
            var i:int = Math.floor(x/tileWidth);
            p1.x = startX_ + i;
            i = Math.floor(x/tileWidthHalf_);
            if((startY_ + i) & 1) {
                p2.x = p1.x + 1;
            } else {
                p2.x = p1.x;
            }
            var j:int = Math.floor(y/tileHeightHalf_);
            p1.y = startY_ + j;
            if(j & 1) {
                p2.y = p1.y - 1;
                j = y % tileHeightHalf_;
            } else {
                p2.y = p1.y + 1;
                j = tileHeightHalf_ - y % tileHeightHalf_;
            }
            i = tileWidthHalf_ / tileHeightHalf_ * j;
            var p:Point = p1;
            if((x % tileWidthHalf_) > i) {
                p = p2;
            }
            return p;
        }
        
        public function isPass(x:int, y:int):Boolean {
            
            return true;
        }
        
        public function get mapId():String {
            return mapId_;
        }
        
        public function get column():int {
            return column_;
        }

        public function get row():int {
            return row_;
        }
        
        public function get sceneColumn():int {
            return sceneCol_;
        }

        public function get sceneRow():int {
            return sceneRow_;
        }

        public function get tileWidth():int {
            return tileWidth_;
        }

        public function get tileHeight():int {
            return tileHeight_;
        }
        
        public function get tileWidthHalf():int {
            return tileWidthHalf_;
        }

        public function get tileHeightHalf():int {
            return tileHeightHalf_;
        }
        
        public function getPath(from:Point, to:Point):Vector.<Point> {
            var path:Vector.<Point> = new Vector.<Point>();
            return path;
        }
        
        public function dispose():void {
            mapLoader_.dispose();
            for each(var tileItem:TileMapItem in tiles_) {
                if(tileItem) tileItem.destory();
            }
            tiles_ = new Vector.<TileMapItem>();
            needUpdateMap_ = false;
            needUpdate_ = false;
            if(mapData_) {
                mapData_.dispose();
            }
            mapData_ = null;
            bigMapRect_.setEmpty();
            mapRect_.setEmpty();
        }
    }
}
