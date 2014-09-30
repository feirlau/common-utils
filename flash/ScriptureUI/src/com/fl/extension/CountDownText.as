package com.fl.extension {
    import com.fl.component.Text;
    import com.fl.event.GlobalEvent;
    import com.fl.utils.StringUtil;
    import com.fl.utils.TimeCountDown;
    import com.fl.utils.TimeUtil;
    
    public class CountDownText extends Text {
        public static const EVENT_COUNTDOWN_UPDATE:String = "EVENT_COUNTDOWN_UPDATE";
		public static const EVENT_COUNTDOWN_OVER:String = "EVENT_COUNTDOWN_OVER";

		private var ct:TimeCountDown;
		public var  info:String;
        public function CountDownText(time:Number = 0, interval:Number = 500) {
            super();
            
            autoContentSize = true;
            
			ct = new TimeCountDown(time, interval);
			ct.addEventListener(TimeCountDown.EVENT_TIME_GO, onTimeGo);
			ct.addEventListener(TimeCountDown.EVENT_TIME_OVER, onTimeOver);
        }
        
        public function get curTime():Number {
            return ct.curTime;
        }
        public function set curTime(value:Number):void {
            ct.curTime = value;
        }
        
        private var preTimer:int = 0;
        public function start(curTime:Number = -1):void {
            ct.start(curTime);
			updateCurTime();
        }
        
        public function stop():void {
			ct.stop();
			updateCurTime();
        }
        
        public function pause():void {
			ct.pause();
        }
        
        public function resume():void {
            start();
        }
        
        public function get isRunning():Boolean {
            return ct.isRunning;
        }
        
		private function onTimeGo(evt:GlobalEvent):void{
			updateCurTime();
			dispatchEvent(new GlobalEvent(EVENT_COUNTDOWN_UPDATE, curTime));
		}
        
        private function updateCurTime():void {
			if(!info)
            	text = TimeUtil.getCountDown(curTime, true);
			else
				text = StringUtil.substitute(info, TimeUtil.getCountDown(curTime, true));
        }
		
		private function onTimeOver(evt:GlobalEvent):void{
			dispatchEvent(new GlobalEvent(EVENT_COUNTDOWN_OVER));
		}
    }
}
