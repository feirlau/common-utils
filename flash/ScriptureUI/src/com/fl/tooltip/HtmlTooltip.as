/**
 * @author risker
 * Dec 20, 2013
 **/
package com.fl.tooltip {
    import com.fl.extension.ImageText;

    public class HtmlTooltip extends ImageText implements ITooltip {
        public function HtmlTooltip() {
            super();
            
            html = true;
            autoContentSize = true;
        }
        
        override public function set data(value:*):void {
            text = value == null ? "" : String(value);
            super.data = value;
        }
    }
}
