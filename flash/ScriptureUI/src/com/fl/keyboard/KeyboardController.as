package com.fl.keyboard {
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.EventPhase;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;

    public class KeyboardController {
        private static var instance_:KeyboardController;

        public static function getInstance():KeyboardController {
            if(null == instance_)
                instance_ = new KeyboardController();
            return instance_;
        }
        
        private var comp:DisplayObject;
        public function init(obj:DisplayObject = null):void {
            comp = obj;
            comp.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler, true);
            comp.addEventListener(KeyboardEvent.KEY_UP, keyHandler, true);
            comp.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
            comp.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
            comp.addEventListener(Event.DEACTIVATE, deactiveHandler);
            comp.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFoucsChange);
        }
        
        private function keyHandler(env:KeyboardEvent):void {
            if(!enabled_) return;
            for each(var handler:IKeyboardHandler in handlerCache_) {
                if(handler && handler.acceptKey(env)) {
                    handler.handleKey(env);
                }
            }
        }
        
        private var handlerCache_:Array = new Array();
        public function addHandler(handler:IKeyboardHandler):void {
            var i:int = handler ? handlerCache_.indexOf(handler) : 0;
            if(i == -1 ) {
                handlerCache_.push(handler);
            }
        }
        public function removeHandler(handler:IKeyboardHandler):void {
            var i:int = handler ? handlerCache_.indexOf(handler) : -1;
            if(i != -1) {
                handlerCache_.splice(i, 1);
            }
        }
        
        private function keyFoucsChange(env:FocusEvent):void {
        }
        
        private function deactiveHandler(env:Event):void {
            keyHandler(null);
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
