package com.fl.utils {
    import com.adobe.utils.UIDUtil;
    
    import flash.events.TimerEvent;
    import flash.utils.Dictionary;
    import flash.utils.Timer;
    import flash.utils.getTimer;
    
    /**
     * Timer Manager supply a easy way to operate timer. Timer manager is not
     * a collection of timer, acturlly, It's ONE timer indeed, but this manager's minimize is 1 sec.
     *
     * How to use:
     * <pre>
     *              you could simply use such phase:
     *              <code>TimerManager.getInstance().addVisualTimer(handler, 2, 1, true);</code>
     *
     *              handler is the handler function name.
     *              the handler func is like this, cur is the current repeat count:
     *
     *              <code>private function handler(cur:Number):void {
     *                              // todo something.
     *              }</code>
     * </pre>
     *
     * When you create a visual-timer using timerManager, you could get a unique id for such visual
     * timer, whenever you want stop that visual timer or destory it, you could use such UID.
     */
    public class TimerManager {
        
        private var dictionary:Dictionary;
        private var timer:Timer;
        
        /**
         * @Private constructor.
         */
        public function TimerManager(interval:int = 200) {
            // init properties: create a timer and add event listener for her.
            timeInterval_ = interval;
            timer = new Timer(timeInterval_);
            timer.addEventListener(TimerEvent.TIMER, interalHandler);
            dictionary = new Dictionary;
        }
        
        /**
         * Singleton.
         */
        private static var instances_:Dictionary = new Dictionary();
        public static function getInstance(interval:int = 200):TimerManager {
            // get the singleton instance.
            var instance:TimerManager = instances_[interval];
            if(!instance) {
                instance = new TimerManager(interval);
            }
            return instance;
        }
        
        private var timeInterval_:int = 100;
        public function get timeInterval():int {
            return timeInterval_;
        }
        /**
         * This function is called every sec.
         */
        private function interalHandler(event:TimerEvent):void {
            // loop the dictionary, get all the running handler
            for each(var item:* in dictionary) {
                // if in turn, run the handler.
                if(item.running && inTurn(item)) {
                    item.cur = item.lastCount + Math.floor((getTimer() - item.start) / item.interval);
                    null != item.func && item.func(item.cur);
                    item.last = getTimer();
                    if(item.repeat > 0 && item.cur >= item.repeat) {
                        removeVisualTimer(item.uid);
                    }
                }
            }
        }
        
        /**
         * Judge if item in current turns.
         */
        private function inTurn(item:Object):Boolean {
            // if current item in turn.
            return  (getTimer() - item.last) >= item.interval;
        }
        
        /**
         * By default, when you add a timer handler, the timer is start.
         *
         * @param handler: handler function, the handler func is like this, cur is the current repeat count:
         * <code>private function handler(cur:Number):void {
         * // todo something.
         * }</code>
         * @param interval: timer interval, this param must be an int and the item.interval will be n*timeInterval.
         * @param repeat: the repeat count of the timer
         * 
         * @return UID, the unique ID of such timer.
         */
        public function addVisualTimer(handler:Function, interval:int=1, repeat:int=0, autoRun:Boolean = true):String {
            var uid:String = UIDUtil.createUID();
            var item:Object = {};
            
            item.uid = uid;
            item.func = handler;
            item.interval = timeInterval_ * interval;
            item.repeat = repeat;
            item.running = false;
            item.cur = 0;
            dictionary[uid] = item;
            
            // if this method has been called for the first time and auto-run property is true.
            // call start func to start the timer.
            if(autoRun) {
                startVisualTimer(uid);
            }
            
            // at last return the UID.
            return uid;
        }
        
        /**
         * Remove timer manully by UID.
         *
         * @param uid:  unique id.
         *
         */
        public function removeVisualTimer(uid:String):void {
            var timerCount:int = 0;
            for(var item:String in dictionary) {
                // get the count of all timers.
                timerCount++;
                
                if(item == uid) {
                    delete dictionary[item];
                    timerCount--;
                }
            }
            // if such visual timer is the last timer, stop running.
            if(!timerCount && isRunning()) {
                timer.stop();
            }
        }
        
        /**
         * Start the timer by UID manully.
         */
        public function startVisualTimer(uid:String):void {
            // if cannot find the item by uid in dictionary, return.
            var item:Object = getItem(uid);
            if(!item)
                return;
            // get it by uid, then set running status to be true (running)
            if(!item.running) {
                item.running = true;
                item.lastCount = item.cur;
                item.cur = 0;
                item.last = item.start = getTimer();
            }
            // run.
            if(!timer.running)
                timer.start();
        }
        
        /**
         * Stop the timer by UID manully.
         */
        public function stopVisualTimer(uid:String):void {
            // if cannot find the item by uid in dictionary, return.
            var item:Object = getItem(uid);
            if(!item)
                return;
            // get it by uid, then set running status to be false (stop)
            item.running = false;
        }
        
        /**
         * Check if the uid exists.
         */
        private function getItem(uid:String):Object {
            for(var item:String in dictionary) {
                if(item == uid)
                    return dictionary[item];
            }
            return null;
        }
        
        /**
         * Judge if timer manager is running.
         */
        public function isRunning():Boolean {
            return timer.running;
        }
        
        /**
         * Judge if the special timer is running.
         */
        public function isItemRunning(uid:String):Boolean {
            var item:Object = getItem(uid);
            return item ? item.running : false;
        }
    }
}