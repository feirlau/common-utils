/**
 * @author risker
 * Oct 15, 2013
 **/
package com.fl.component {
    import com.fl.constants.PositionConstants;
    import com.fl.constants.StatefulConstants;
    import com.fl.event.GlobalEvent;
    
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;

    public class Slider extends BaseComponent {
        public static const EVENT_VALUE_CHANGED:String = "EVENT_VALUE_CHANGED";
        
        override protected function initStyle():void {
            _selfStyles.push("thumbStyle", "trackStyle");
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
        /**0-1*/
        public function set value(v:Number):void {
            if(_value != v) {
                updateValue(v);
            }
        }
        public function get value():Number {
            return _value;
        }
        private var oldValue:Number = 0;
        /**
        * @fireEvent, used by ScrollBar or others to avoid the dump update
        * @toInvalidate, when slide by drag, no need to update the thumb position 
        **/
        public function updateValue(v:Number, fireEvent:Boolean = true, toInvalidate:Boolean = true):void {
            oldValue = _value;
            
            _value = v;
            
            if(toInvalidate) {
                invalidate(INVALIDATE_PROP);
            }
            if(fireEvent) {
                dispatchEvent(new GlobalEvent(Slider.EVENT_VALUE_CHANGED, oldValue));
            }
        }
        private var _minimum:Number = 0;
        /**0-1*/
        public function set minimum(v:Number):void {
            if(_minimum != v) {
                _minimum = v;
                invalidate(INVALIDATE_PROP);
            }
        }
        public function get minimum():Number {
            return _minimum;
        }
        
        private var _maximum:Number = 1;
        /**0-1*/
        public function set maximum(v:Number):void {
            if(_maximum != v) {
                _maximum = v;
                invalidate(INVALIDATE_PROP);
            }
        }
        public function get maximum():Number {
            return _maximum;
        }
        
        private var _thumbHeight:Number = 16;
        public function set thumbHeight(v:Number):void {
            if(_thumbHeight != v) {
                _thumbHeight = v;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        public function get thumbHeight():Number {
            return _thumbHeight;
        }
        
        public function set thumbVisible(v:Boolean):void {
            thumb.visible = v;
        }
        public function get thumbVisible():Boolean {
            return thumb.visible;
        }
        
        protected var track:StatefulComponent = new StatefulComponent();
        protected var thumb:StatefulComponent = new StatefulComponent();
        override protected function createChildren():void {
            super.createChildren();
            
            track.acceptStates = [StatefulConstants.UP, StatefulConstants.DISABLED];
            track.addEventListener(MouseEvent.MOUSE_DOWN, trackDownHandler);
            addChild(track);
            
            thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumbDownHandler);
            addChild(thumb);
        }
        protected function trackDownHandler(env:MouseEvent):void {
            var n:Number = env.localY - thumbHeight / 2;
            n = Math.max(0, n);
            n = Math.min(trackHeight, n);
            value = n / trackHeight;
        }
        public function get trackHeight():Number {
            return Math.max(1, height - thumbHeight);
        }
        /**
         * Internal mouseDown handler. Starts dragging the handle.
         * @param event The MouseEvent passed by the system.
         */
        protected function thumbDownHandler(env:MouseEvent):void {
            stage.addEventListener(MouseEvent.MOUSE_UP, thumbUpHandler, false, 0, true);
            stage.addEventListener(Event.DEACTIVATE, thumbUpHandler, false, 0, true);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, thumbMoveHandler, false, 0, true);
            var n:Number = trackHeight;
            thumb.startDrag(false, new Rectangle(0, n * minimum, 0, n * maximum));
        }
        
        /**
         * Internal mouseUp handler. Stops dragging the handle.
         * @param event The MouseEvent passed by the system.
         */
        protected function thumbUpHandler(env:Event):void {
            stage.removeEventListener(MouseEvent.MOUSE_UP, thumbUpHandler);
            stage.removeEventListener(Event.DEACTIVATE, thumbUpHandler);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumbMoveHandler);
            thumb.stopDrag();
        }
        protected function thumbMoveHandler(env:MouseEvent):void {
            updateValue(thumb.y / trackHeight, true, false);
        }
        
        override protected function onResize():void {
            super.onResize();
            
            thumb.setSize(width, thumbHeight);
            track.setSize(width, height);
        }
        
        override protected function onProp():void {
            super.onProp();
            
            track.enabled = enabled;
            thumb.enabled = enabled;
            
            thumb.y = value * trackHeight;
            
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
                if(styleP == null || styleP == "thumbStyle") {
                    thumb.style = getStyle("thumbStyle");
                }
                if(styleP == null || styleP == "trackStyle") {
                    track.style = getStyle("trackStyle");
                }
            }
        }
    }
}
