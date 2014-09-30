package com.fl.component {
    import com.fl.event.GlobalEvent;
    import com.fl.vo.EdgeMetrics;
    
    import flash.events.MouseEvent;

    public class TitleWindow extends Canvas {
        public function TitleWindow() {
            super();
        }
        
        public function get dragable():Boolean {
            return _dragComp.enabled;
        }
        public function set dragable(value:Boolean):void {
            _dragComp.visible = _dragComp.enabled = value;
        }
        
        public function get resizable():Boolean {
            return _resizeComp.enabled;
        }
        public function set resizable(value:Boolean):void {
            _resizeComp.enabled = value;
        }
        
        public function get title():String {
            return _titleBtn.label;
        }
        public function set title(value:String):void {
            _titleBtn.label = value;
        }

        override protected function initStyle():void {
            _selfStyles.push("headerHeight", "dragBarStyle", "resizeBarStyle", "titleStyle", "closeStyle");
            super.initStyle();
        }
        
        protected var _dragComp:DragableComp = new DragableComp();
        protected var _resizeComp:ResizableComp = new ResizableComp();
        protected var _titleBtn:Button = new Button();
        public function get titleBtn():Button {
            return _titleBtn;
        }
        protected var _closeBtn:Button = new Button();
        public function get closeBtn():Button {
            return _closeBtn;
        }
        override protected function createChildren():void {
            super.createChildren();
            
            _dragComp.moveHandler = dragMoveHandler;
            addChild(_dragComp);
            _titleBtn.mouseEnabled = _titleBtn.mouseChildren = false;
            addChild(_titleBtn);
            _closeBtn.autoSkinSize = true;
            _closeBtn.addEventListener(MouseEvent.CLICK, closeHandler);
            _closeBtn.addEventListener(EVENT_RESIZE, closeResizeHandler);
            addChild(_closeBtn);
            _resizeComp.autoSkinSize = true;
            _resizeComp.moveHandler = resizeMoveHandler;
            _resizeComp.addEventListener(EVENT_RESIZE, resizeResizeHandler);
            addChild(_resizeComp);
        }
        
        protected function dragMoveHandler(env:MouseEvent, mx:Number, my:Number):void {
            move(mx + x, my + y);
        }
        protected function resizeMoveHandler(env:MouseEvent, mx:Number, my:Number):void {
            setSize(mx + width, my + height);
        }
        protected function closeHandler(env:MouseEvent):void {
            hide();
        }
        protected function closeResizeHandler(env:GlobalEvent):void {
            invalidate(INVALIDATE_RESIZE);
        }
        protected function resizeResizeHandler(env:GlobalEvent):void {
            invalidate(INVALIDATE_RESIZE);
        }
        
        public function get isPopUp():Boolean {
            return UIGlobal.popup.hasPopUp(this);
        }
        public function bringToFront():void {
            UIGlobal.popup.bringToFront(this);
        }
        public function show(center:Boolean = true, modal:Boolean = false, front:Boolean = true):void {
            UIGlobal.popup.createPopUp(this, center, modal);
            if(front) {
                bringToFront();
            }
        }
        public function hide():void {
            UIGlobal.popup.removePopUp(this);
        }
        
        override protected function onResize():void {
            super.onResize();
            
            _dragComp.setSize(width, _headerHeight);
            var pe:EdgeMetrics = _dragComp.paddings;
            _titleBtn.x = pe.left;
            _titleBtn.setSize(width - pe.left - pe.right, _headerHeight - pe.top - pe.bottom);
            _closeBtn.x = width - _closeBtn.width - pe.right;
            _closeBtn.y = (_headerHeight - pe.top - pe.bottom - _closeBtn.height) / 2;
            
            pe = _resizeComp.paddings;
            _resizeComp.x = width - _resizeComp.width - pe.right;
            _resizeComp.y = height - _resizeComp.height - pe.bottom;
        }
        
        protected var _headerHeight:Number = 26;
        override public function updateStyle(styleP:String = null):void {
            super.updateStyle(styleP);
            if(acceptStyle(styleP)) {
                if(styleP == null || styleP == "headerHeight") {
                    _headerHeight = getStyle("headerHeight");
                    invalidate(INVALIDATE_RESIZE);
                }
                if(styleP == null || styleP == "dragBarStyle") {
                    _dragComp.style = getStyle("dragBarStyle");
                    invalidate(INVALIDATE_RESIZE);
                }
                if(styleP == null || styleP == "titleStyle") {
                    _titleBtn.style = getStyle("titleStyle");
                }
                if(styleP == null || styleP == "closeStyle") {
                    _closeBtn.style = getStyle("closeStyle");
                }
                if(styleP == null || styleP == "resizeBarStyle") {
                    _resizeComp.style = getStyle("resizeBarStyle");
                    invalidate(INVALIDATE_RESIZE);
                }
            }
        }
    }
}
