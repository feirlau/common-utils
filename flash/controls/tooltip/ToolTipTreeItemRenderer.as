/* Copyright (c) 2010-2011 Vitria Technology, Inc.  All rights reserved. */
package controls.tooltip
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import mx.controls.treeClasses.TreeItemRenderer;
    import mx.core.IToolTip;
    import mx.events.ToolTipEvent;
    import mx.logging.ILogger;
    import mx.logging.Log;

    /**
    * The tooltip should be an xml string like:
    *   <root formToolTip='true'><item label="label1" text="value1"/><item label="label2" text="value2"/></root>
    * with formToolTip='true'.
    **/
    public class ToolTipTreeItemRenderer extends TreeItemRenderer
    {
        public function ToolTipTreeItemRenderer()
        {
            super();
        }
        
        private static const logger_:ILogger = Log.getLogger("ToolTipTreeItemRenderer");
        
        override protected function createChildren():void {
            super.createChildren();
            addEventListener(ToolTipEvent.TOOL_TIP_SHOW, toolTipShowHandler, false, 1);
            addEventListener(ToolTipEvent.TOOL_TIP_CREATE, toolTipCreateHandler);
        }
        
        private function toolTipCreateHandler(event:ToolTipEvent):void {
            try {
                var tipData:XML = new XML(toolTip);
                if(tipData.@formToolTip.toString() == "true") {
                    event.toolTip = CustomFormToolTip.getInstance(tipData.item.length());
                }
            } catch(err:Error) {
                logger_.debug(err.message);
            }
        }
        
        private function toolTipShowHandler(event:ToolTipEvent):void {
            try {
                event.stopImmediatePropagation();
                var toolTip:IToolTip = event.toolTip;
                if(toolTip) {
                    // Calculate global position of label.
                    var pt:Point = new Point(0, 0);
                    pt = label.localToGlobal(pt);
                    pt = stage.globalToLocal(pt);
                    var tmpX:int = pt.x + 8;
                    var tmpY:int = pt.y + height + 1;
                    
                    var screen:Rectangle = systemManager.screen;
                    var screenRight:Number = screen.x + screen.width;
                    var screenBottom:Number = screen.y + screen.height;
                    if (tmpX + toolTip.width > screenRight)
                        tmpX = screenRight - toolTip.width;
                        
                    if (tmpY + toolTip.height > screenBottom)
                        tmpY = pt.y - toolTip.height - 1;
                    
                    toolTip.move(tmpX, tmpY);
                }
            } catch(err:Error){
                logger_.error(err.getStackTrace());
            }
        }
    }
}
