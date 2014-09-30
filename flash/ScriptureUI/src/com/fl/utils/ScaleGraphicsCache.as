package com.fl.utils {
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;

    public class ScaleGraphicsCache {
        private static var _instance:ScaleGraphicsCache;
        public static function getInstance():ScaleGraphicsCache {
            _instance ||= new ScaleGraphicsCache();
            return _instance;
        }
        
        private var cachedGraphics:Dictionary = new Dictionary();
        private var cachedTimes:Dictionary = new Dictionary();
        public function getGraphics(source:*, bitmapData:BitmapData, scaleGrid:Rectangle):Graphics {
            var shape:Shape = cachedGraphics[source];
            if(shape) {
                cachedTimes[source] = getTimer();
            } else {
                shape = cachedGraphics[source] = new Shape();
                //位图scale9Grid, 需要分组绘制，即以九宫格的方式begin/end进行多次绘制
                shape.graphics.beginBitmapFill(bitmapData);
                shape.graphics.drawRect(0, 0, scaleGrid.left, scaleGrid.top);
                shape.graphics.beginBitmapFill(bitmapData);
                shape.graphics.drawRect(scaleGrid.left, 0, scaleGrid.right - scaleGrid.left, scaleGrid.top);
                shape.graphics.beginBitmapFill(bitmapData);
                shape.graphics.drawRect(scaleGrid.right, 0, bitmapData.width - scaleGrid.right, scaleGrid.top);
                //中
                shape.graphics.beginBitmapFill(bitmapData);
                shape.graphics.drawRect(0, scaleGrid.top, scaleGrid.left, scaleGrid.bottom - scaleGrid.top);
                shape.graphics.beginBitmapFill(bitmapData);
                shape.graphics.drawRect(scaleGrid.left, scaleGrid.top, scaleGrid.right - scaleGrid.left, scaleGrid.bottom - scaleGrid.top);
                shape.graphics.beginBitmapFill(bitmapData);
                shape.graphics.drawRect(scaleGrid.right, scaleGrid.top, bitmapData.width - scaleGrid.right, scaleGrid.bottom - scaleGrid.top);
                //下
                shape.graphics.beginBitmapFill(bitmapData);
                shape.graphics.drawRect(0, scaleGrid.bottom, scaleGrid.left, bitmapData.height - scaleGrid.bottom);
                shape.graphics.beginBitmapFill(bitmapData);
                shape.graphics.drawRect(scaleGrid.left, scaleGrid.bottom, scaleGrid.right - scaleGrid.left, bitmapData.height - scaleGrid.bottom);
                shape.graphics.beginBitmapFill(bitmapData);
                shape.graphics.drawRect(scaleGrid.right, scaleGrid.bottom, bitmapData.width - scaleGrid.right, bitmapData.height - scaleGrid.bottom);
                
                shape.graphics.endFill();
                
                updateCachedImages();
            }
            return shape.graphics;
        }
            
        public var maxCache:uint = 100;
        private function updateCachedImages():void {
            if(maxCache != 0 && maxCache < DictionaryUtil.length(cachedGraphics)) {
                var preS:*;
                var tmpS:*;
                var preT:uint = 0;
                var tmpT:uint = 0;
                for(tmpS in cachedGraphics) {
                    tmpT = cachedTimes[tmpS];
                    if(!preS || tmpT < preT) {
                        preS = tmpS;
                        preT = tmpT;
                    }
                }
                if(preS) {
                    flushCache(preS);
                }
            }
        }
        public function flushCache(source:*):void {
            delete cachedGraphics[source];
            delete cachedTimes[source];
        }
        
    }
}
