package com.fl.component {
    import com.adobe.utils.ObjectUtil;
    import com.fl.utils.FLUtil;

    public class TileItemRenderer extends Button implements IItemRenderer {
        public function TileItemRenderer() {
            super();
        }
        
        override public function set data(value:*):void {
            super.data = value;
            
            if(null == value) label = "";
            else if(ObjectUtil.isSimple(value)) label = String(value);
            else FLUtil.copy(value, this);
        }
    }
}
