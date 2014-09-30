package com.feirlau.global {
    import flash.events.Event;

    public class GlobalEvent extends Event {
        public var data:Object;
        
        public function GlobalEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
            super(type, bubbles, cancelable);
            this.data = data;
        }
        
        override public function clone():Event {
            var tmpEvent:GlobalEvent = new GlobalEvent(type, bubbles, cancelable);
            tmpEvent.data = data;
            return tmpEvent;
        }
    }
}
