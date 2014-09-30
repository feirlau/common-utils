package com.fl.utils {
    import com.fl.event.GlobalEvent;
    import com.fl.utils.TimerManager;
    
    import flash.events.EventDispatcher;
    import flash.utils.getTimer;
    
    /**
    * time count down instance used by CountDownText ro others 
    **/
    public class TimeCountDown extends EventDispatcher {
        public static const EVENT_TIME_GO:String = "EVENT_TIME_GO";
        public static const EVENT_TIME_OVER:String = "EVENT_TIME_OVER";

        private var timerMgr:TimerManager;
        private var curTime_:Number = 0;
        private var interval_:Number = 500;
        private var timer_:String;

        public function TimeCountDown(time:Number = 0, interval:Number = 500) {
            timerMgr = TimerManager.getInstance(interval);
            curTime_ = time;
            interval_ = interval;
        }

        public function get curTime():Number {
            return curTime_;
        }

        public function set curTime(value:Number):void {
            if(curTime_ != value) {
                updateTime(value);
            }
        }

        private var preTimer:int = 0;
        public function start(curTime:Number = -1):void {
            if(curTime >= 0)
                curTime_ = curTime;
            preTimer = getTimer();
            if(!timer_) {
                timer_ = timerMgr.addVisualTimer(timerHandler);
            } else {
                timerMgr.startVisualTimer(timer_);
            }
        }

        public function stop():void {
            if(timer_ == null)
                return;
            timerMgr.removeVisualTimer(timer_);
            timer_ = null;
            curTime_ = 0;
            dispatchEvent(new GlobalEvent(EVENT_TIME_OVER));
        }

        public function pause():void {
            isRunning && timerMgr.stopVisualTimer(timer_);
        }

        public function resume():void {
            start();
        }

        public function get isRunning():Boolean {
            return timer_ && timerMgr.isItemRunning(timer_);
        }

        public function updateTime(curTime:Number):void {
            preTimer = getTimer();
            curTime_ = curTime;
            if(isRunning && curTime_ > 0 && curTime_ <= curTime_) {

            } else if(isRunning) {
                stop();
            }
            dispatchEvent(new GlobalEvent(EVENT_TIME_GO));
        }

        private function timerHandler(cur:Number):void {
            updateTime(curTime_ - (getTimer() - preTimer));
        }
    }
}