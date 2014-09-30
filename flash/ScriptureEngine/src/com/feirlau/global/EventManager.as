package com.feirlau.global {
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.utils.Dictionary;
    
    import mx.collections.ArrayCollection;
    import mx.logging.ILogger;
    import mx.logging.Log;
    
    public class EventManager {
        private static const logger_:ILogger = Log.getLogger("EventManager");
        private static var instance_:EventManager;
        
        public static function getInstance():EventManager {
            if(instance_ == null) {
                instance_ = new EventManager();
                instance_.dispatcher_ = new EventDispatcher();
                instance_.eventListeners_ = new Dictionary();
            }
            return instance_;
        }
        
        private var dispatcher_:IEventDispatcher;
        private var eventListeners_:Dictionary;
        
        public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
            var tmpType:String = type + "_" + useCapture;
            var listeners:ArrayCollection = eventListeners_[tmpType];
            if(listeners == null) {
                listeners = new ArrayCollection();
                eventListeners_[tmpType] = listeners;
            }
            if(!listeners.contains(listener)) {
                dispatcher_.addEventListener(type, listener, useCapture, priority, useWeakReference);
                listeners.addItem(listener);
            }
        }
        
        public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
            var tmpType:String = type + "_" + useCapture;
            var listeners:ArrayCollection = eventListeners_[tmpType];
            if(listeners != null && listeners.contains(listener)) {
                dispatcher_.removeEventListener(type, listener, useCapture);
                listeners.removeItemAt(listeners.getItemIndex(listener));
            }
        }
        
        public function dispatchEvent(event:GlobalEvent):void {
            dispatcher_.dispatchEvent(event);
        }
        
        /**
        * If type is null or empty, if will remove all listeners match the useCapture
        **/
        public function removeListeners(type:String = null, useCapture:Boolean = false):void {
            var tmpType:String;
            if(type) {
                tmpType = type + "_" + useCapture;
                var listeners:ArrayCollection = eventListeners_[tmpType];
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