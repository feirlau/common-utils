/**
 * @author risker
 * Dec 30, 2013
 **/
package com.fl.component {
    import com.fl.constants.PositionConstants;
    import com.fl.event.GlobalEvent;
    
    import flash.events.MouseEvent;
    import flash.geom.Point;

    public class Menu extends ScrollTile {
        public function Menu() {
            super();
            
            autoContentSize = true;
            row = 0;
        }
        
        override protected function itemClickHandler(env:MouseEvent):void {
            super.itemClickHandler(env);
            //stop to prevent popup again when click the item
            if(_isOpen) {
                env.stopPropagation();
                hide();
            }
        }
        
        protected var _isOpen:Boolean = false;
        public function get isOpen():Boolean {
            return _isOpen;
        }
        
        public function show(p:Point):void {
            _isOpen = true;
            
            move(p.x, p.y);
            UIGlobal.popup.createPopUp(this);
            
            stage.addEventListener(MouseEvent.MOUSE_DOWN, outDownHandler, false, 0, true);
        }
        public function hide():void {
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, outDownHandler);
            
            _isOpen = false;
            UIGlobal.popup.removePopUp(this);
        }
        protected function outDownHandler(env:MouseEvent):void {
            if(env && env.target != this && !hitTestPoint(env.stageX, env.stageY)) {
                hide();
            }
        }
    }
}
