package com.fl.mouse {
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.EventPhase;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    public class MouseController {
        private static var instance_:MouseController;
        public static function getInstance():MouseController {
            if(null == instance_)
                instance_ = new MouseController();
            return instance_;
        }
        
        private var comp:DisplayObject;
        public function init(obj:DisplayObject = null):void {
            comp = obj;
            comp.addEventListener(MouseEvent.MOUSE_MOVE, mouseHandler);
            comp.addEventListener(MouseEvent.MOUSE_MOVE, mouseHandler, true);
            comp.addEventListener(MouseEvent.CLICK, mouseHandler);
            comp.addEventListener(MouseEvent.CLICK, mouseHandler, true);
            comp.addEventListener(MouseEvent.DOUBLE_CLICK, mouseHandler);
            comp.addEventListener(MouseEvent.DOUBLE_CLICK, mouseHandler, true);
            comp.addEventListener(MouseEvent.MOUSE_WHEEL, mouseHandler);
            comp.addEventListener(MouseEvent.MOUSE_WHEEL, mouseHandler, true);
            
            comp.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
            comp.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler, true);
            comp.addEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
            comp.addEventListener(MouseEvent.MOUSE_OUT, mouseHandler, true);
            
            comp.addEventListener(MouseEvent.ROLL_OVER, mouseHandler);
            comp.addEventListener(MouseEvent.ROLL_OVER, mouseHandler, true);
            comp.addEventListener(MouseEvent.ROLL_OUT, mouseHandler);
            comp.addEventListener(MouseEvent.ROLL_OUT, mouseHandler, true);
            
            comp.addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
            comp.addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler, true);
            comp.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
            comp.addEventListener(MouseEvent.MOUSE_UP, mouseHandler, true);
            
            comp.addEventListener(Event.DEACTIVATE, deactiveHandler);
            comp.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, mouseFocusChange);
        }
        
        private var curStagePoint_:Point = new Point(0, 0);
        public function get curStagePoint():Point {
            return curStagePoint_;
        }
        
        private function mouseHandler(env:MouseEvent):void {
            if(!enabled_) return;
            if(env && env.type == MouseEvent.MOUSE_MOVE && env.eventPhase != EventPhase.CAPTURING_PHASE) {
                curStagePoint_.x = env.stageX;
                curStagePoint_.y = env.stageY;
            }
            for each(var handler:IMouseHandler in handlerCache_) {
                if(handler && handler.acceptMouse(env)) {
                    handler.handleMouse(env);
                }
            }
        }
        
        private var handlerCache_:Array = new Array();
        public function addHandler(handler:IMouseHandler):void {
            var i:int = handler ? handlerCache_.indexOf(handler) : 0;
            if(i == -1 ) {
                handlerCache_.push(handler);
            }
        }
        public function removeHandler(handler:IMouseHandler):void {
            var i:int = handler ? handlerCache_.indexOf(handler) : -1;
            if(i != -1) {
                handlerCache_.splice(i, 1);
            }
        }
        
        private function mouseFocusChange(env:FocusEvent):void {
        }
        private function deactiveHandler(env:Event):void {
            mouseHandler(null);
        }
        
        private var enabled_:Boolean = true;
        public function set enabled(v:Boolean):void {
            enabled_ = v;
        }
        public function get enabled():Boolean {
            return enabled_;
        }
    }
}
