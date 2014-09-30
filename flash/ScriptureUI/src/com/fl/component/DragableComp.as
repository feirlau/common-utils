package com.fl.component {
    import com.fl.mouse.IMouseHandler;
    import com.fl.mouse.MouseSequence;
    
    import flash.events.MouseEvent;

    public class DragableComp extends BaseComponent implements IMouseHandler {
        public function DragableComp() {
            super();
            
            addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        }
        
        private var _moveMouse:MouseSequence = new MouseSequence(MouseEvent.MOUSE_MOVE, "", 0, 0, 0, true);
        private var _upMouse:MouseSequence = new MouseSequence(MouseEvent.MOUSE_UP, "", 0, 0, 0, true);
        /** 是否接收该鼠标事件 */
        public function acceptMouse(env:MouseEvent, data:Object = null):Boolean {
            return true;
        }
        /** 处理鼠标事件 */
        public function handleMouse(env:MouseEvent, data:Object = null):void {
            if(env == null) {
                stage_mouseUpHandler(env);
            } else if(_moveMouse.isPressed(env)) {
                stage_mouseMoveHandler(env);
            } else if(_upMouse.isPressed(env)) {
                stage_mouseUpHandler(env);
            }
        }
        
        protected function mouseDownHandler(env:MouseEvent):void {
            if(enabled && isNaN(_regX)) {
                startDragging(env);
            }
        }
        
        /**
         *  @private
         *  Horizontal location where the user pressed the mouse button
         *  on the titlebar to start dragging, relative to the original
         *  horizontal location of the Panel.
         */
        private var _regX:Number;
        public function get regX():Number {
            return _regX;
        }
        /**
         *  @private
         *  Vertical location where the user pressed the mouse button
         *  on the titlebar to start dragging, relative to the original
         *  vertical location of the Panel.
         */
        private var _regY:Number;
        public function get regY():Number {
            return _regY;
        }
        /**
         *  Called when the user starts dragging a Panel
         *  that has been popped up by the PopUpManager.
         */
        protected function startDragging(event:MouseEvent):void {
            _regX = event.stageX;
            _regY = event.stageY;
            
            UIGlobal.mouse.addHandler(this);
        }
        /**
         *  Called when the user stops dragging a Panel
         *  that has been popped up by the PopUpManager.
         */
        protected function stopDragging():void {
            _regX = NaN;
            _regY = NaN;
            
            UIGlobal.mouse.removeHandler(this);
        }
        
        public var moveHandler:Function;
        private function stage_mouseMoveHandler(event:MouseEvent):void {
            if(isNaN(_regX) || isNaN(_regY)) {
                return;
            }
            
            // during a drag, only the Panel should get mouse move events
            // (e.g., prevent objects 'beneath' it from getting them -- see bug 187569)
            // we don't check the target since this is on the systemManager and the target
            // changes a lot -- but this listener only exists during a drag.
            event.stopImmediatePropagation();
            
            var sx:Number = event.stageX;
            var sy:Number = event.stageY;
            doMove(event, sx - _regX, sy - _regY);
            _regX = sx;
            _regY = sy;
        }
        protected function doMove(env:MouseEvent, mx:Number, my:Number):void {
            if(null == moveHandler) {
                move(mx + x, my + y);
            } else {
                moveHandler(env, mx, my);
            }
        }
        
        private function stage_mouseUpHandler(event:MouseEvent):void {
            // trace("systemManager_mouseUpHandler: " + event);
            if(isNaN(_regX) || isNaN(_regY)) {
                return;
            }
            stopDragging();
        }
    }
}
