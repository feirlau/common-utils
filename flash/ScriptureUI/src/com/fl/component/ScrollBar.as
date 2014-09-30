/**
 * @author risker
 * Oct 15, 2013
 **/
package com.fl.component {
    import com.fl.constants.PositionConstants;
    import com.fl.event.GlobalEvent;
    import com.fl.utils.TimerManager;
    
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.Timer;

    public class ScrollBar extends BaseComponent {
        override protected function initStyle():void {
            _selfStyles.push("topArrowStyle", "bottomArrowStyle", "thumbIcon", "sliderStyle");
            super.initStyle();
        }
        
        private var _direction:String = PositionConstants.VERTICAL;
        /**
         * Gets / sets the scrollbar direction.
         */
        public function set direction(v:String):void {
            if(_direction != v) {
                _direction = v;
                invalidate(INVALIDATE_PROP);
            }
        }
        public function get direction():String {
            return _direction;
        }
        
        private var _value:Number = 0;
        public function set value(v:Number):void {
            if(_value != v) {
                updateValue(v);
            }
        }
        public function get value():Number {
            return _value;
        }
        private var oldValue:Number = 0;
        public function updateValue(v:Number):void {
            oldValue = _value;
            
            v = Math.max(v, 0);
            v = Math.min(v, _maximum);
            _value = v;
            slider.updateValue(_maximum == 0 ? 0 : v / _maximum, false, true);
            
            invalidate(INVALIDATE_RESIZE);
            dispatchEvent(new GlobalEvent(Slider.EVENT_VALUE_CHANGED, oldValue));
        }
        
        private var _maximum:Number = 0;
        public function set maximum(v:Number):void {
            v = Math.max(v, 0);
            if(_maximum != v) {
                _maximum = v;
                if(value > v) {
                    value = v;
                }
                updatePageInfo();
            }
        }
        public function get maximum():Number {
            return _maximum;
        }
        
        protected var _pageSize:Number = 1;
        /**visible unit, unit per track scroll*/
        public function set pageSize(v:Number):void {
            if(_pageSize != v) {
                _pageSize = v;
                updatePageInfo();
            }
        }
        public function get pageSize():Number {
            return _pageSize;
        }
        
        private var _thumbPercent:Number = 1;
        public function updatePageInfo():void {
            slider.pageSize = _maximum > 0 ? _pageSize / _maximum : 1;
            _thumbPercent = _maximum > 0 && _pageSize > 0 ? _pageSize / (_pageSize + _maximum) : 1;
            invalidate(INVALIDATE_RESIZE);
        }
        
        private var _lineSize:Number = 10;
        /**unit per arrow scroll*/
        public function set lineSize(v:Number):void {
            if(_lineSize != v) {
                _lineSize = v;
            }
        }
        public function get lineSize():Number {
            return _lineSize;
        }
        
        private var _arrowHeight:Number = 16;
        public function set arrowHeight(v:Number):void {
            if(_arrowHeight != v) {
                _arrowHeight = v;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        public function get arrowHeight():Number {
            return _arrowHeight;
        }
        
        protected function updateState():void {
            slider.thumbVisible = maximum > 0;
            topArrow.enabled = enabled && maximum > 0;
            bottomArrow.enabled = enabled && maximum > 0;
            slider.enabled = enabled && maximum > 0;
        }
        
        protected var topArrow:StatefulComponent = new StatefulComponent();
        protected var bottomArrow:StatefulComponent = new StatefulComponent();
        protected var slider:ScrollSlider = new ScrollSlider();
        protected var thumbIcon:Image = new Image();
        override protected function createChildren():void {
            super.createChildren();
            
            slider.direction = PositionConstants.VERTICAL;
            slider.addEventListener(Slider.EVENT_VALUE_CHANGED, slideValueHandler);
            addChild(slider);
            
            thumbIcon.enabled = false;
            thumbIcon.autoImgSize = true;
            thumbIcon.addEventListener(EVENT_RESIZE, thumbSizeHandler);
            addChild(thumbIcon);
            
            topArrow.addEventListener(MouseEvent.MOUSE_DOWN, topDownHandler);
            addChild(topArrow);
            bottomArrow.addEventListener(MouseEvent.MOUSE_DOWN, bottomDownHandler);
            addChild(bottomArrow);
        }
        protected function slideValueHandler(env:GlobalEvent):void {
            updateValue(slider.value * maximum);
        }
        protected function thumbSizeHandler(env:GlobalEvent):void {
            invalidate(INVALIDATE_RESIZE);
        }
        protected function topDownHandler(env:MouseEvent):void {
            startScroll(-1 * _lineSize);
        }
        protected function bottomDownHandler(env:MouseEvent):void {
            startScroll(1 * _lineSize);
        }
        protected function pageScroll(v:int):void {
            var n:Number = value + v;
            value = n;
        }
        private var timerMgr:TimerManager = TimerManager.getInstance(200);
        private var scrollTimer:String;
        private var scrollV:int = 0;
        protected function startScroll(v:int):void {
            stage.addEventListener(MouseEvent.MOUSE_UP, arrowUpHandler, false, 0, true);
            stage.addEventListener(Event.DEACTIVATE, arrowUpHandler, false, 0, true);
            scrollV = v;
            pageScroll(v);
            if(!scrollTimer) {
                scrollTimer = timerMgr.addVisualTimer(scrollTimeHandler);
            }
        }
        private function scrollTimeHandler(v:Number):void {
            pageScroll(scrollV);
        }
        protected function arrowUpHandler(env:Event):void {
            stage.removeEventListener(MouseEvent.MOUSE_UP, arrowUpHandler);
            stage.removeEventListener(Event.DEACTIVATE, arrowUpHandler);
            if(scrollTimer) {
                timerMgr.removeVisualTimer(scrollTimer);
                scrollTimer = null;
            }
        }
        
        private var minThumbH:Number = 12;
        override protected function onResize():void {
            super.onResize();
            
            updateState();
            
            topArrow.setSize(width, arrowHeight);
            bottomArrow.y = height - arrowHeight;
            bottomArrow.setSize(width, arrowHeight);
            slider.y = arrowHeight;
            slider.setSize(width, height - 2 * arrowHeight);
            slider.thumbHeight = int(_thumbPercent * slider.height);
            thumbIcon.x = (width - thumbIcon.width) / 2;
            thumbIcon.y = slider.y + slider.value * slider.trackHeight + (slider.thumbHeight - thumbIcon.height) / 2;
        }
        
        override protected function onProp():void {
            super.onProp();
            
            updateState();
            
            if(_direction == PositionConstants.HORIZONTAL) {
                scaleX = -1.0;
                rotation = -90;
            } else {
                scaleX = 1;
                rotation = 0;
            }
        }
        
        override public function updateStyle(styleP:String=null):void {
            super.updateStyle(styleP);
            if(acceptStyle(styleP)) {
                if(styleP == null || styleP == "sliderStyle") {
                    slider.style = getStyle("sliderStyle");
                }
                if(styleP == null || styleP == "topArrowStyle") {
                    topArrow.style = getStyle("topArrowStyle");
                }
                if(styleP == null || styleP == "bottomArrowStyle") {
                    bottomArrow.style = getStyle("bottomArrowStyle");
                }
                if(styleP == null || styleP == "thumbIcon") {
                    thumbIcon.source = getStyle("thumbIcon");
                }
            }
        }
    }
}
