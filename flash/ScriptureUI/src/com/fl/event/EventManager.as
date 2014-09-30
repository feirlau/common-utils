package com.fl.event {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    
    public class EventManager extends EventDispatcher{
        private static var instance_:EventManager;
        
        public static function getInstance():EventManager {
            instance_ ||= new EventManager();
            return instance_;
        }
        
        /**优化没有listener的事件*/
        override public function dispatchEvent(event:Event):Boolean {
            if(hasEventListener(event.type) || event.bubbles) {
                return super.dispatchEvent(event);
            }
            return true;
        }
        
        private var eventListeners_:Dictionary = new Dictionary();
        override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
            var tmpType:String = type + "_" + useCapture;
            var listeners:Array = eventListeners_[tmpType];
            if(listeners == null) {
                listeners = new Array();
                eventListeners_[tmpType] = listeners;
            }
            var i:int = listeners.indexOf(listener);
            if(i == -1) {
                super.addEventListener(type, listener, useCapture, priority, useWeakReference);
                listeners.push(listener);
            }
        }
        
        override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
            var tmpType:String = type + "_" + useCapture;
            var listeners:Array = eventListeners_[tmpType];
            var i:int = listeners ? listeners.indexOf(listener) : -1;
            if(i != -1) {
                super.removeEventListener(type, listener, useCapture);
                listeners.splice(i, 1);
            }
        }
        
        /**
        * If type is null or empty, if will remove all listeners match the useCapture
        **/
        public function removeListeners(type:String = null, useCapture:Boolean = false):void {
            var tmpType:String;
            if(type) {
                tmpType = type + "_" + useCapture;
                var listeners:Array = eventListeners_[tmpType];
                for each(var listener:Function in listeners) {
                    removeEventListener(type, listener, useCapture);
                }
                delete eventListeners_[tmpType];
            } else {
                for(tmpType in eventListeners_) {
                    if(tmpType) {
                        removeListeners(tmpType, useCapture);
                    }
                }
            }
        }
        
        public function removeAllListeners():void {
            removeListeners(null, false);
            removeListeners(null, true);
        }
    }
}