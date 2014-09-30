/**
 * @author risker
 * Dec 20, 2013
 **/
package com.fl.tooltip {
    import com.fl.component.BaseSprite;
    
    import flash.display.DisplayObject;
    
    import org.as3commons.ui.layer.tooltip.IToolTipSelector;

    public class BaseTooltipSelector implements IToolTipSelector {
        private var toolTipType:int = 0;
        public function BaseTooltipSelector(t:int = 0) {
            toolTipType = t;
        }

        public function approve(displayObject:DisplayObject):Boolean {
            if(toolTipType == 0 || !(displayObject is BaseSprite)) return true;
            
            var bs:BaseSprite = displayObject as BaseSprite;
            return bs.tooltipType == toolTipType;
        }
    }
}
