/**
 * @author risker
 * Oct 16, 2013
 **/
package com.fl.component {
    import com.fl.constants.StatefulConstants;
    import com.fl.skin.ISkin;
    import com.fl.style.IStyle;
    
    import flash.events.Event;
    import flash.events.MouseEvent;

    public class StatefulComponent extends BaseComponent {
        public function StatefulComponent() {
            super();
        }
        
        public var acceptStates:Array = [StatefulConstants.UP, StatefulConstants.OVER, StatefulConstants.DOWN, StatefulConstants.FOCUS, StatefulConstants.DISABLED];
        private var _state:String = StatefulConstants.UP;
        public function get state():String {
            return _state;
        }
        public function set state(value:String):void {
            if(-1 == acceptStates.indexOf(value)) return;
            
            if(_state != value) {
                _state = value;
                removeStageEvent();
                invalidate(INVALIDATE_STYLE);
            }
        }
        
        override public function set enabled(value:Boolean):void {
            if(enabled != value) {
                super.enabled = value;
                if(value) {
                    state = StatefulConstants.UP;
                } else {
                    state = StatefulConstants.DISABLED;
                }
            }
        }
        
        override protected function init():void {
            super.init();
            
            addEventListener(MouseEvent.ROLL_OVER, overHandler);
            addEventListener(MouseEvent.ROLL_OUT, outHandler);
            addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
            addEventListener(MouseEvent.MOUSE_UP, upHandler);
        }
        protected function overHandler(env:MouseEvent):void {
            state = StatefulConstants.OVER;
        }
        protected function outHandler(env:MouseEvent):void {
            if(_enabled) {
                state = StatefulConstants.UP;
            }
        }
        protected function downHandler(env:MouseEvent):void {
            state = StatefulConstants.DOWN;
            
            addStageEvent();
        }
        protected function addStageEvent():void {
            if(!stage) return;
            stage.addEventListener(MouseEvent.MOUSE_UP, stage_upHandler, false, 0, true);
            stage.addEventListener(Event.DEACTIVATE, stage_upHandler, false, 0, true);
            stage.addEventListener(Event.MOUSE_LEAVE, stage_upHandler, false, 0, true);
        }
        protected function removeStageEvent():void {
            if(!stage) return;
            stage.removeEventListener(MouseEvent.MOUSE_UP, stage_upHandler);
            stage.removeEventListener(Event.DEACTIVATE, stage_upHandler);
            stage.removeEventListener(Event.MOUSE_LEAVE, stage_upHandler);
        }
        protected function stage_upHandler(env:*):void {
            state = StatefulConstants.UP;
        }
        protected function upHandler(env:MouseEvent):void {
            state = StatefulConstants.OVER;
        }
        
        override protected function onStyle():void {
            super.onStyle();
            
            if(skin is IStyle) {
                IStyle(skin).setStyle(StatefulConstants.STATE, state); 
            }
        }
    }
}
