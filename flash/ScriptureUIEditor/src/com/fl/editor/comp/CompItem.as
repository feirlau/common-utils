/**
 * @author risker
 * Dec 24, 2013
 **/
package com.fl.editor.comp {
    import com.fl.utils.FLUtil;

    public class CompItem {
        public var name:String;
        public var icon:*;
        public var clz:Class;
        
        public function CompItem(_clz:Class, _name:String = null, _icon:* = null) {
            clz = _clz;
            name = _name;
            name ||= FLUtil.getClassName(clz);
            icon = _icon;
            icon ||= EditorComponentConfig.Comp;
        }
    }
}
