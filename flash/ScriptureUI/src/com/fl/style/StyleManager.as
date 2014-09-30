package com.fl.style {
    import flash.utils.Dictionary;

    public class StyleManager {
        public function StyleManager() {
        }
        
        private static var styles:Dictionary = new Dictionary();
        public static function registerStyle(name:String, style:*, reset:Boolean = false):IStyle {
            var s:IStyle = styles[name];
            if(null == s || reset) {
                s = new Style();
                styles[name] = s;
            }
            s.copyStyle(style);
            return s;
        }
        
        public static function unregisterStyle(name:String):IStyle {
            var s:IStyle = styles[name];
            if(s) {
                delete styles[name];
            }
            return s;
        }
        
        public static function getStyle(name:String, copy:Boolean = true):IStyle {
            var s:IStyle;
            if(copy) {
                s = new Style();
                s.copyStyle(styles[name]);
            } else {
                s = styles[name];
                s ||= new Style();
            }
            return s;
        }
        
        public static function getStyleItem(key:String, name:String = "common"):* {
            var s:IStyle = styles[name];
            return s ? s.getStyle(key) : null;
        }
        
        public static function setStyleItem(key:String, value:*, name:String = "common"):void {
            var s:IStyle = styles[name];
            if(!s) {
                styles[name] = s = new Style();
            }
            s.setStyle(key, value);
        }
    }
}
