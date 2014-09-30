package com.feirlau.component {
    import com.feirlau.map.tilemap.TileMap;
    import com.feirlau.map.tilemap.TileMapItem;
    import com.pblabs.rendering2D.DisplayObjectRenderer;
    
    import flash.display.Graphics;
    import flash.display.GraphicsPathCommand;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    public class TileMapEditorRenderer extends DisplayObjectRenderer {
        public static const COMP_NAME:String = "TileMapEditorRenderer";
        private var mapRenderer_:TileMapRenderer;
        
        override protected function onAdd():void {
            displayObject = new Sprite();
            layerIndex = 10;
            super.onAdd();
        }
        
        override protected function onReset():void {
            super.onReset();
            displayObject.width = size.x;
            displayObject.height = size.y;
            displayObject.addEventListener(MouseEvent.CLICK, onClicked);
            mapRenderer_ = owner.lookupComponentByName(TileMapRenderer.COMP_NAME) as TileMapRenderer;
            owner.eventDispatcher.addEventListener(TileMapRenderer.MAP_DIRTY_EVENT, mapDirtyHandler);
        }
        
        private function onClicked(event:MouseEvent):void {
            if(mapRenderer_ && mapRenderer_.tileMap) {
                var tileMap:TileMap = mapRenderer_.tileMap;
                var curTile:Point = tileMap.getTilePoint(event.localX, event.localY);
                if(event.ctrlKey) {
                    var tileItem:TileMapItem = tileMap.getTileByPoint(curTile.x, curTile.y);
                    tileItem.type = switchTileType(tileItem.type);
                } else {
                    mapRenderer_.tileMap.moveSceneMap(curTile.x, curTile.y);
                }
            }
        }
        
        private var isDirty_:Boolean = true;
        private function mapDirtyHandler(event:Event):void {
            isDirty_ = true;
        }
        
        override protected function onRemove():void {
            if(displayObject && displayObject.hasEventListener(MouseEvent.CLICK)) {
                displayObject.removeEventListener(MouseEvent.CLICK, onClicked);
            }
            mapRenderer_ = null;
            super.onRemove();
        }
        
        override public function onFrame(elapsed:Number):void {
            if(mapRenderer_ && mapRenderer_.tileMap) {
                var tileMap:TileMap = mapRenderer_.tileMap;
                var curX:int = tileMap.curPoint.x;
                var curY:int = tileMap.curPoint.y;
                var tileWidth:int = tileMap.tileWidth;
                var tileWidthHalf:int = tileMap.tileWidthHalf;
                var tileHeight:int = tileMap.tileHeight;
                var tileHeightHalf:int = tileMap.tileHeightHalf;
                var graphic:Graphics = Sprite(displayObject).graphics;
                graphic.clear();
                for(var i:int = 0 ; i < tileMap.sceneColumn; i++) {
                    for(var j:int = 0 ; j < tileMap.sceneRow; j++) {
                        var tileItem:TileMapItem = tileMap.getTileByPoint(i + curX, j + curY);
                        var x:int = i * tileWidth - tileWidthHalf + (i & 1) * tileWidthHalf;
                        var y:int = j * tileHeightHalf;
                        var color:uint = getTileColor(tileItem.type);
                        var commands:Vector.<int> = new Vector.<int>();
                        commands.push(GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO,
                            GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO);
                        var data:Vector.<Number> = new Vector.<Number>();
                        data.push(x, y);
                        data.push(x + tileWidthHalf, y - tileHeightHalf);
                        data.push(x + tileWidth, y);
                        data.push(x + tileWidthHalf, y + tileHeightHalf);
                        graphic.beginFill(color, 0.5);
                        graphic.lineStyle(1, 0x000000, 0.8);
                        graphic.drawPath(commands, data);
                        graphic.endFill();
                    }
                }
            }
            super.onFrame(elapsed);
        }
        
        private function getTileColor(type:int = 0):uint {
            var tmpResult:int = TileMapItem.TYPE_PASS;
            switch(type) {
                case TileMapItem.TYPE_PASS:
                    tmpResult = TileMapItem.TYPE_BLOCK;
                    break;
                case TileMapItem.TYPE_BLOCK:
                    tmpResult = TileMapItem.TYPE_SHIELD;
                    break;
                case TileMapItem.TYPE_SHIELD:
                    tmpResult = TileMapItem.TYPE_PASS;
                    break;
            }
            return tmpResult;
        }
        
        private function switchTileType(type:int = 0):uint {
            var tmpResult:uint = 0xFFFFFF;
            switch(type) {
                case TileMapItem.TYPE_PASS:
                    tmpResult = 0xFFFFFF;
                    break;
                case TileMapItem.TYPE_BLOCK:
                    tmpResult = 0xFF0000;
                    break;
                case TileMapItem.TYPE_SHIELD:
                    tmpResult = 0xFFFF00;
                    break;
            }
            return tmpResult;
        }
    }
}
