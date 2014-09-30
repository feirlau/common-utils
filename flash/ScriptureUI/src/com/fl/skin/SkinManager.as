package com.fl.skin {
    import flash.utils.Dictionary;

    public class SkinManager {
        public function SkinManager() {
        }
        
        private static var skins:Dictionary = new Dictionary();
        public static function registerSkin(name:String, skin:*, reset:Boolean = true):* {
            var s:*;
            if(!(name in skins) || reset) {
                s = skins[name] = skin;
            } else {
                s = skins[name];
            }
            return s;
        }
        
        public static function unregisterSkin(name:String):* {
            var s:*;
            if(name in skins) {
                s = skins[name];
                delete skins[name];
            }
            return s;
        }
        
        public static function getSkin(name:String):* {
            return skins[name];
        }
        public static function hasSkin(name:String):Boolean {
            return name in skins;
        }
    }
}
