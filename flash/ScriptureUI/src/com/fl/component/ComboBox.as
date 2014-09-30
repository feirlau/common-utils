package com.fl.component {
    import com.fl.event.GlobalEvent;
    
    import flash.events.MouseEvent;
    import flash.geom.Point;

    public class ComboBox extends Button {
        public static const EVENT_ITEM_CHANGED:String = "EVENT_ITEM_CHANGED";
        
        public function ComboBox() {
            super();
        }
        
        override protected function initStyle():void {
            _selfStyles.push("listStyle");
            super.initStyle();
        }
        
        protected var _editable:Boolean = false;
        public function get editable():Boolean {
            return _editable;
        }
        public function set editable(value:Boolean):void {
            if(_editable != value) {
                _editable = value;
                _text.editable = _editable;
            }
        }
        
        protected var _list:ScrollTile = new ScrollTile();
        public function get list():ScrollTile {
            return _list;
        }
        
        override protected function createChildren():void {
            super.createChildren();
            
            _list.addEventListener(ScrollTile.EVENT_ITEM_SELECT, itemSelectHandler);
            updateSelectedItem();
        }
        
        public var labelFunc:Function;
        protected function itemSelectHandler(env:GlobalEvent):void {
            closeList();
            updateSelectedItem();
        }
        public function updateSelectedItem():void {
            var v:* = _list.selectedItems ? _list.selectedItems[0] : null;
            label = null == labelFunc ? defaultLabelFunc(v) : labelFunc(v) ;
        }
        protected function defaultLabelFunc(v:Object):String {
            var s:String = "";
            if(v) {
                if(v.hasOwnProperty("label")) {
                    s = v["label"];
                } else if(v.hasOwnProperty("@label")) {
                    s = v["@label"];
                } else {
                    s = String(v);
                }
            }
            return s;
        }
        
        override public function set label(v:String):void {
            var oldL:String = label;
            super.label = v;
            dispatchEvent(new GlobalEvent(EVENT_ITEM_CHANGED, oldL));
        }
        override protected function downHandler(env:MouseEvent):void {
            super.downHandler(env);
            
            if(isOpen) {
                closeList();
            } else {
                openList();
            }
        }
        
        protected var isOpen:Boolean = false;
        protected function openList():void {
            isOpen = true;
            
            var p:Point = new Point(0, height);
            p = localToGlobal(p);
            _list.move(p.x, p.y);
            UIGlobal.popup.createPopUp(_list);
            
            stage.addEventListener(MouseEvent.MOUSE_DOWN, outDownHandler, false, 0, true);
        }
        protected function closeList():void {
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, outDownHandler);
            
            isOpen = false;
            UIGlobal.popup.removePopUp(_list);
        }
        protected function outDownHandler(env:MouseEvent):void {
            if(env && env.target != this && !_list.hitTestPoint(env.stageX, env.stageY)) {
                closeList();
            }
        }
        
        override public function updateStyle(styleP:String = null):void {
            super.updateStyle(styleP);
            
            if(acceptStyle(styleP)) {
                if(styleP == null || styleP == "listStyle") {
                    _list.copyStyle(getStyle("listStyle"));
                }
            }
        }
    }
}
