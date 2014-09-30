/**
 * @author risker
 * Oct 19, 2013
 **/
package com.fl.utils {
    import com.fl.component.IComponentConfig;

    public class ComponentConfig implements IComponentConfig {
        private static var loaded:Boolean = false;
        public function load():void {
            if(loaded) return;
            loaded = true;
            
            /**
            var name:String;
            var skin:*;
            var style:Object;
            
            name = FLUtil.getClassName(StatefulComponent)
            skin = StatefulBorderSkin;
            SkinManager.registerSkin(name, skin);;
            style = {};
            StyleManager.registerStyle(name, style);
            ***/
        }
        
        public function unload():void {
            if(!loaded) return;
            loaded = false;
        }
    }
}
