package com.fl.component {
    import com.fl.event.GlobalEvent;
    import com.senocular.display.Layout;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Rectangle;
    
    /***
    * @see LayoutConstraint
    **/
    public class LayoutCanvas extends ScrollBase {
        public function LayoutCanvas() {
            super();
        }
        
        protected var _layout:Layout = new Layout();
        public function get layout():Layout {
            return _layout;
        }

        private var reset:Boolean = true;
        private var _items:Array = [];
        public function get items():Array {
            return _items;
        }

        public function addAllItem(v:Array, i:int = -1):void {
            if(i < 0 || i > _items.length)
                i = _items.length;
            for each(var item:Layout in v) {
                addItemAt(item, i++);
            }
        }

        public function addItem(item:Layout):Layout {
            var n:int = getItemIndex(item);
            if(n == -1) {
                addItemAt(item, _items.length);
            }

            return item;
        }

        public function addItemAt(item:Layout, i:int):Layout {
            if(null == item)
                return item;

            var n:int = getItemIndex(item);
            if(i < 0 || i > _items.length) {
                i = _items.length;
            }
            if(n == -1) {
                _layout.addChild(item);
                _items.splice(i, 0, item);
                var o:DisplayObject = item.target;
                if(null == o) {
                    reset = true;
                } else if(!reset && o && !container.contains(o)) {
                    i = Math.min(i, container.numChildren);
                    container.addChildAt(o, i);
                }
                invalidate(INVALIDATE_PROP);
            } else if(n == i) {
                //do nothing
            } else {
                _items.splice(n, 1);
                i = Math.min(i, _items.length);
                _items.splice(i, 0, item);
                reset = true;
                invalidate(INVALIDATE_PROP);
            }

            return item;
        }

        public function removeItem(item:Layout):Layout {
            var n:int = getItemIndex(item);
            if(n != -1) {
                removeItemAt(n);
            }
            return item;
        }

        public function removeItemAt(i:int):Layout {
            if(i < 0 || i >= _items.length)
                return null;

            var item:Layout = _items[i];
            _items.splice(i, 1);

            _layout.removeChild(item);

            var o:DisplayObject = item.target;
            if(null == o) {
                reset = true;
            } else if(!reset && o && container.contains(o)) {
                container.removeChild(o);
            }

            invalidate(INVALIDATE_PROP);

            return item;
        }

        public function removeAllItem(v:Array = null):void {
            v ||= _items;
            for each(var item:Layout in v) {
                removeItem(item);
            }
        }

        public function getItemAt(i:int):Layout {
            return _items[i];
        }

        public function getItemIndex(item:Layout):int {
            return _items.indexOf(item);
        }

        protected function resetLayout():void {
            while(container.numChildren > 0) {
                container.removeChildAt(0);
            }
            for each(var item:Layout in _items) {
                if(item.target) {
                    container.addChild(item.target);
                }
            }
        }

        public function relayout():void {
            reset = true;
            invalidate(INVALIDATE_PROP);
        }
        
        protected var container:BaseSprite = new BaseSprite();
        override protected function createChildren():void {
            super.createChildren();
            
            container.rawChangeEnable = true;
            container.addEventListener(EVENT_RAW_RESIZE, rawResizeHandler);
            addChild(container);
            content = container;
            _layout.target = this;
        }
        protected function rawResizeHandler(env:GlobalEvent):void {
            invalidate(INVALIDATE_PROP);
        }
        
        override public function get contentWidth():Number {
            return container.rawWidth;
        }
        override public function get contentHeight():Number {
            return container.rawHeight;
        }
        
        override protected function onProp():void {
            super.onProp();
            
            if(!autoContentSize) {
                if(reset) {
                    resetLayout();
                    reset = false;
                }
                _layout.draw();
                updateContentSize();
            }
        }
    }
}
