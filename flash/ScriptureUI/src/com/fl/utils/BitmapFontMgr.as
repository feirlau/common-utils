/**
 * @author risker
 * Dec 31, 2013
 **/
package com.fl.utils {
    import flash.display.BitmapData;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;

    public class BitmapFontMgr {
        public function BitmapFontMgr() {
        }
        
        private static var categories:Dictionary = new Dictionary();
        public static function addFont(cat:String, f:String, bmp:BitmapData):void {
            if(!cat || !f || !bmp) return;
            var fc:Dictionary = categories[cat] ||= new Dictionary();
            fc[f] = bmp;
        }
        public static function addFonts(cat:String, fs:Array, bmps:Array):void {
            if(!cat || !fs || !bmps) return;
            for(var i:int = 0; i < fs.length; i++) {
                addFont(cat, fs[i], bmps[i]);
            }
        }
        
        /**helper rect*/
        private static var hr:Rectangle = new Rectangle();
        /**helper point**/
        private static var hp:Point  = new Point();
        /**
        * @param cat, the font category
        * @param fs, the font array to draw
        * @param bmp, the bmp to use, if null, create a new one
        * @param fp, the start point to draw the font, only used when bmp not null
        * @return the font bmp
        ***/
        public static function createFont(cat:String , fs:Array, bmp:BitmapData = null, fp:Point = null):BitmapData {
            var fc:Dictionary = categories[cat];
            if(!fc) return bmp;
            
            var fbs:Array = [];
            var tw:Number = 0;
            var th:Number = 0;
            var fb:BitmapData;
            var i:int = 0;
            if(!bmp) {
                for(i = 0; i < fs.length; i++) {
                    fb = fc[fs[i]];
                    if(fb) {
                        fbs.push(fb);
                        tw += fb.width;
                        th = Math.max(th, fb.height);
                    }
                }
                bmp = new BitmapData(tw, th, true, 0);
                fp = null;
            } else {
                tw = bmp.width;
                th = bmp.height;
            }
            
            bmp.lock();
            fp ||= new Point();
            hp.x = fp.x;
            hp.y = fp.y;
            for each(fb in fbs) {
                hr.width = fb.width;
                hr.height = fb.height;
                hp.y = fp.y + (th - hr.height) >> 1;
                
                bmp.copyPixels(fb, hr, hp);
                
                hp.x += hr.width;
            }
            bmp.unlock();
            
            return bmp;
        }
    }
}
