package com.fl.vo {
    import com.fl.event.EventManager;
    import com.fl.event.GlobalEvent;
    
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.utils.Proxy;
    import flash.utils.flash_proxy;

    public dynamic class ArrayList extends Proxy implements IEventDispatcher {
        public static const EVENT_UPDATE:String = "EVENT_UPDATE";
        
        public function ArrayList(s:Array = null):void {
            super();
            
            source = s;
        }
        
        private var array:Array = [];
        override flash_proxy function callProperty(methodName:*, ... args):* {
            var res:*;
            switch(methodName.toString()) {
                default:
                    res = array[methodName].apply(array, args);
                    break;
            }
            return res;
        }

        override flash_proxy function getProperty(name:*):* {
            return array[name];
        }

        override flash_proxy function setProperty(name:*, value:*):void {
            array[name] = value;
        }
        
        public function get source():Array {
            return array;
        }
        public function set source(s:Array):void {
            removeAll(false);
            addItems(s);
        }
        
        public function addItem(v:*, toUpdate:Boolean = true):void {
            addItemAt(v, array.length, toUpdate);
        }
        public function addItemAt(v:*, i:int, toUpdate:Boolean = true):void {
            array.splice(i, 0, v);
            toUpdate && update();
        }
        public function addItems(v:Array, toUpdate:Boolean = true):void {
            addItemsAt(v, array.length, toUpdate);
        }
        public function addItemsAt(v:Array, i:int, toUpdate:Boolean = true):void {
            var m:int = v ? v.length : 0;
            for (var n:int = 0; n < m; n++) {
                addItemAt(v[n], i + n);
            }
            toUpdate && update();
        }
        
        public function removeItem(v:*, toUpdate:Boolean = true):void {
            var i:int = array.indexOf(v);
            if(i >= 0) {
                array.splice(i, 1);
            }
            toUpdate && update();
        }
        public function removeItemAt(i:int, toUpdate:Boolean = true):* {
            var v:*;
            if(i >= 0 && i < array.length) {
                v = array.splice(i, 1)[0];
            }
            toUpdate && update();
            return v;
        }
        public function removeAll(toUpdate:Boolean = true):void {
            array.splice(0, array.length);
            toUpdate && update();
        }
        
        public function update():void {
            dispatchEvent(new GlobalEvent(EVENT_UPDATE));
        }
        
        private var eventMgr:EventManager = new EventManager();
        public function dispatchEvent(event:Event):Boolean {
            return eventMgr.dispatchEvent(event);
        }
        
        public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
            eventMgr.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        
        public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
            eventMgr.removeEventListener(type, listener, useCapture);
        }
        
        public function hasEventListener(type:String):Boolean {
            return eventMgr.hasEventListener(type);
        }
        
        public function willTrigger(type:String):Boolean {
            return willTrigger(type);
        }
        
        /**
         * If type is null or empty, if will remove all listeners match the useCapture
         **/
        public function removeListeners(type:String = null, useCapture:Boolean = false):void {
            eventMgr.removeListeners(type, useCapture);
        }
        
        public function removeAllListeners():void {
            eventMgr.removeAllListeners();
        }
        
    }
}
