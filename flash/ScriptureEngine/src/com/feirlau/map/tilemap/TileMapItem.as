package com.feirlau.map.tilemap {

    public class TileMapItem {
        public static const TYPE_PASS:int = 0;
        public static const TYPE_BLOCK:int = 1;
        public static const TYPE_SHIELD:int = 2;
        public var type:int = TYPE_PASS;
        private var elements_:Vector = new Vector();
        
        public function destory():void {
            elements_ = new Vector();
        }
    }
}
