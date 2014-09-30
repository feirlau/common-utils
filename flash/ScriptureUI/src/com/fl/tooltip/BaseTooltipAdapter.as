/**
 * @author risker
 * Dec 20, 2013
 **/
package com.fl.tooltip {
    import com.fl.component.BaseSprite;
    import com.fl.component.UIGlobal;
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import org.as3commons.ui.layer.placement.PlacementAnchor;
    import org.as3commons.ui.layer.tooltip.ToolTipAdapter;
    
    public class BaseTooltipAdapter extends ToolTipAdapter {
        public function BaseTooltipAdapter() {
            super();
            
            _sourceAnchor = PlacementAnchor.TOP_RIGHT;
            _layerAnchor = PlacementAnchor.TOP_LEFT;
        }
        
        override protected function onContent(toolTip:DisplayObject, content:*) : void {
            super.onContent(toolTip, content);
            if(toolTip is ITooltip) {
                ITooltip(toolTip).data = content;
            }
            bounds = new Rectangle(0, 0, UIGlobal.tooltip.width, UIGlobal.tooltip.height);
        }

        override protected function onShow(toolTip:DisplayObject, local:Point):void {
            super.onShow(toolTip, local);
            updateHandlers();
        }

        override protected function onRemove(toolTip:DisplayObject):void {
            super.onRemove(toolTip);
            updateHandlers();
        }
        
        private var preS:DisplayObject;
        private var preL:DisplayObject;
        protected function updateHandlers():void {
            if(preS != _source) {
                if(preS) {
                    preS.removeEventListener(BaseSprite.EVENT_RESIZE, resizeHandler);
                }
                preS = _source;
                if(preS) {
                    preS.addEventListener(BaseSprite.EVENT_RESIZE, resizeHandler, false, 0, true);
                }
            }
            if(preL != _layer) {
                if(preL) {
                    preL.removeEventListener(BaseSprite.EVENT_RESIZE, resizeHandler);
                }
                preL = _layer;
                if(preL) {
                    preL.addEventListener(BaseSprite.EVENT_RESIZE, resizeHandler, false, 0, true);
                }
            }
        }
        
        protected function resizeHandler(env:Event):void {
            if(_source && _layer) {
                calculatePosition();
                
                _layer.x = _layerLocal.x;
                _layer.y = _layerLocal.y;
            }
        }
    }
}
