package com.feirlau.global {
    import mx.core.UIComponent;
    
    public class GlobalUtils {
        public static function setVisible(comp:UIComponent, visible:Boolean):void {
            if(comp) {
                comp.visible = visible;
                comp.includeInLayout = visible;
            }
        }
        
        public static function contactPath(...args):String {
            return args.join(GlobalConstants.PATH_SEP);
        }
    }
}
