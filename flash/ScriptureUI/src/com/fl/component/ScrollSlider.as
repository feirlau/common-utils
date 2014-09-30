package com.fl.component {
    import com.fl.utils.TimerManager;
    
    import flash.events.Event;
    import flash.events.MouseEvent;

    public class ScrollSlider extends Slider {
        public function ScrollSlider() {
            super();
        }
        
        override protected function trackDownHandler(env:MouseEvent):void {
            startScroll();
        }
        protected function pageScroll():void {
            var m:Number = thumb.y + thumbHeight / 2;
            var n:Number = Math.abs(mouseY - m);
            if(n > 0) {
                n = Math.max(0, n);
                n = Math.min(trackHeight, n);
                n = n / trackHeight;
                n = Math.min(n, _pageSize);
                if(mouseY > m) {
                    value += n;
                } else {
                    value -= n;
                }
            }
        }
        private var timerMgr:TimerManager = TimerManager.getInstance(200);
        private var scrollTimer:String;
        protected function startScroll():void {
            stage.addEventListener(MouseEvent.MOUSE_UP, arrowUpHandler, false, 0, true);
            stage.addEventListener(Event.DEACTIVATE, arrowUpHandler, false, 0, true);
            pageScroll();
            if(!scrollTimer) {
                scrollTimer = timerMgr.addVisualTimer(scrollTimeHandler);
            }
        }
        private function scrollTimeHandler(v:Number):void {
            pageScroll();
        }
        protected function arrowUpHandler(env:Event):void {
            stage.removeEventListener(MouseEvent.MOUSE_UP, arrowUpHandler);
            stage.removeEventListener(Event.DEACTIVATE, arrowUpHandler);
            if(scrollTimer) {
                timerMgr.removeVisualTimer(scrollTimer);
                scrollTimer = null;
            }
        }
        
        private var _pageSize:Number = 4;
        /**visible unit, unit per track scroll*/
        public function set pageSize(v:Number):void {
            if(_pageSize != v) {
                _pageSize = v;
            }
        }
        public function get pageSize():Number {
            return _pageSize;
        }
    }
}
