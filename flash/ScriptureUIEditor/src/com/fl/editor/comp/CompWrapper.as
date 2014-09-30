/**
 * @author risker
 * Dec 24, 2013
 **/
package com.fl.editor.comp {
    import com.fl.component.BaseSprite;
    import com.fl.component.DragableComp;
    import com.fl.component.ResizableComp;
    import com.fl.event.EventManager;
    import com.fl.event.GlobalEvent;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import mx.core.UIComponent;

    public class CompWrapper extends UIComponent {
        public static const EVENT_WRAPPER_CLICK:String = "EVENT_WRAPPER_CLICK";
        private var _comp:DisplayObject;
        public function CompWrapper(clz:Class) {
            _comp = new clz();
        }
        
        protected var _wrapper:Sprite = new Sprite();
        protected var _dragComp:DragableComp = new DragableComp();
        protected var _resizeComp:ResizableComp = new ResizableComp();
        override protected function createChildren():void {
            super.createChildren();
            
            _comp.addEventListener(BaseSprite.EVENT_RESIZE, compResizeHandler);
            _wrapper.addChild(_comp);
            _wrapper.mouseChildren = false;
            _wrapper.mouseEnabled = false;
            addChild(_wrapper);
            
            _dragComp.moveHandler = dragMoveHandler;
            addChild(_dragComp);
            _resizeComp.autoSkinSize = true;
            _resizeComp.moveHandler = resizeMoveHandler;
            _resizeComp.addEventListener(BaseSprite.EVENT_RESIZE, resizeResizeHandler);
            addChild(_resizeComp);
            
            addEventListener(MouseEvent.CLICK, clickHandler);
        }
        
        protected function dragMoveHandler(env:MouseEvent, mx:Number, my:Number):void {
            move(mx + x, my + y);
        }
        protected function resizeMoveHandler(env:MouseEvent, mx:Number, my:Number):void {
            width = mx + width;
            height = my + height;
        }
        protected function resizeResizeHandler(env:Event):void {
            invalidateDisplayList();
        }
        protected function clickHandler(env:MouseEvent):void {
            EventManager.getInstance().dispatchEvent(new GlobalEvent(EVENT_WRAPPER_CLICK, this));
        }
        protected function compResizeHandler(env:Event):void {
            width = _comp.width;
            height = _comp.height;
        }
        
        override public function get width():Number {
            return _comp.width;
        }
        override public function set width(v:Number):void {
            _comp.width = v;
        }
        
        override public function get height():Number {
            return _comp.height;
        }
        override public function set height(v:Number):void {
            _comp.height = v;
        }
        
        override protected function updateDisplayList(unscaledWidth:Number,
                                                      unscaledHeight:Number):void {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            _dragComp.setSize(width, height);
            
            _resizeComp.x = width - _resizeComp.width;
            _resizeComp.y = height - _resizeComp.height;
        }
    }
}
