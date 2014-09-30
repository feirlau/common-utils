package com.fl.component {
    import com.fl.drag.DragManager;
    import com.fl.keyboard.KeyboardController;
    import com.fl.mouse.MouseController;
    import com.fl.tooltip.BaseTooltipAdapter;
    import com.fl.tooltip.BaseTooltipSelector;
    import com.fl.tooltip.HtmlTooltip;
    
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    
    import org.as3commons.ui.layer.PopUpManager;
    import org.as3commons.ui.layer.ToolTipManager;

    public class UIGlobal {
        public static var stage:Stage;
        
        public static var keyboard:KeyboardController;
        public static var mouse:MouseController;
        
        public static var popup:PopUpManager;
        public static var tooltip:ToolTipManager;
        public static var drag:DragManager;
        
        public static var compLayer:Sprite;
        public static var popupLayer:Sprite;
        public static var tooltipLayer:Sprite;
        public static function init(s:Stage, compL:Sprite = null, popupL:Sprite = null, tooltipL:Sprite = null):void {
            stage = s;
            
            keyboard = KeyboardController.getInstance();
            keyboard.init(stage);
            
            mouse = MouseController.getInstance();
            mouse.init(stage);
            
            if(null == compL) {
                compL ||= new Sprite();
                stage.addChild(compL);
            }
            compLayer = compL;
            
            if(null == popupL) {
                popupL ||= new Sprite();
                popupL.mouseEnabled = false;
                stage.addChild(popupL);
            }
            popupLayer = popupL;
            popup = new PopUpManager(popupLayer);
            
            if(null == tooltipL) {
                tooltipL ||= new Sprite();
                tooltipL.mouseEnabled = tooltipL.mouseChildren = false;
                stage.addChild(tooltipL);
            }
            tooltipLayer = tooltipL;
            tooltip = new ToolTipManager(tooltipLayer);
            tooltip.registerToolTip(new BaseTooltipSelector(), new BaseTooltipAdapter(), new HtmlTooltip());
            
            drag = new DragManager(stage);
            
            resizeHandler();
            stage.addEventListener(Event.RESIZE, resizeHandler);
            stage.addEventListener(Event.ENTER_FRAME, frameHandler);
        }
        private static function resizeHandler(env:Event = null):void {
            var w:Number = stage.stageWidth;
            var h:Number = stage.stageHeight;
            if(w > 0 && h > 0) {
                popup.setSize(w, h);
                tooltip.setSize(w, h);
            }
        }
        private static function frameHandler(env:Event = null):void {
            if(stage.focus == null) stage.focus = stage;
        }
    }
}
