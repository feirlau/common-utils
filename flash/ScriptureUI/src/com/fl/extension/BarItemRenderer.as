/**
 * @author risker
 * Dec 30, 2013
 **/
package com.fl.extension {
    import com.adobe.utils.ObjectUtil;
    import com.fl.component.IItemRenderer;
    import com.fl.component.RadioButton;
    import com.fl.utils.FLUtil;

    public class BarItemRenderer extends RadioButton implements IItemRenderer {
        public function BarItemRenderer() {
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
