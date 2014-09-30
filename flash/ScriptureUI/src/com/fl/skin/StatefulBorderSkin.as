package com.fl.skin {
    import com.fl.style.StyleEvent;
    
    import flash.display.DisplayObjectContainer;
    
    /***
     * styles {
     *  upSkin: url/class, overSkin: url/class, downSkin: url/class, disabledSkin: url/class,
     *  state: 'up'
     * }
     */
    public class StatefulBorderSkin extends ImageBorderSkin {
        override protected function initStyle():void {
            _selfStyles.push("upSkin", "overSkin", "downSkin", "disabledSkin", "focusSkin", "state");
            super.initStyle();
        }
        
        private var _state:String;
        public function get state():String {
            return _state;
        }
        public function set state(value:String):void {
            if(_state != value) {
                _state = value;
                invalidate(INVALIDATE_PROP);
            }
        }
        
        override protected function updateSource():void {
            if(state) {
                source = getStyle(_state + "Skin");
            } else {
                super.updateSource();
            }
        }
        
        override protected function styleHandler(env:StyleEvent=null):void {
            super.styleHandler(env);
            var styleProp:* = env.data;
            if(acceptStyle(styleProp)) {
                state = getStyle("state");
                invalidate(INVALIDATE_PROP);
            }
        }
    }
}
