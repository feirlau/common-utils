/**
 * @author risker
 * Oct 24, 2013
 **/
package com.fl.component {
    import com.fl.constants.PositionConstants;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    
    import org.as3commons.collections.framework.IIterator;
    import org.as3commons.ui.layout.Display;
    import org.as3commons.ui.layout.HGroup;
    import org.as3commons.ui.layout.VGroup;
    import org.as3commons.ui.layout.framework.ILayout;
    import org.as3commons.ui.layout.framework.ILayoutItem;
    import org.as3commons.ui.layout.shortcut.hgroup;

    public class Box extends ScrollBase {
        public function Box() {
            super();
            
            autoContentSize = true;
        }
        
        protected var _layout:ILayout = hgroup();
        /**
         * Gets / sets the scrollbar direction.
         */
        public function set layout(v:ILayout):void {
            if(_layout != v) {
                _layout = v;
                reset = true;
                invalidate(INVALIDATE_PROP);
            }
        }
        public function get layout():ILayout {
            return _layout;
        }
        
        private var reset:Boolean = true;
        private var _items:Array = [];
        public function get items():Array {
            return _items;
        }
        public function addAllItem(v:Array, i:int = -1):void {
            if(i < 0 || i > _items.length) i = _items.length;
            for each(var item:DisplayObject in v) {
                addItemAt(item, i++);
            }
        }
        public function addItem(item:DisplayObject):DisplayObject {
            var n:int = getItemIndex(item);
            if(n == -1) {
                addItemAt(item, _items.length);
            }
            
            return item;
        }
        public function addItemAt(item:DisplayObject, i:int):DisplayObject {
            if(null == item) return item;
            
            var n:int = getItemIndex(item);
            if(i < 0 || i > _items.length) {
                i = _items.length;
            }
            if(n == -1) {
                if(reset) {
                } else if(i == 0) {
                    if(_layout) {
                        _layout.addFirst(item);
                    }
                } else if(i == _items.length) {
                    if(_layout) {
                        _layout.add(item);
                    }
                } else {
                    reset = true;
                }
                if(item is BaseSprite) {
                    item.addEventListener(EVENT_RESIZE, itemResizeHandler, false, 0, true);
                }
                _items.splice(i, 0, item);
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
        public function removeItem(item:DisplayObject):DisplayObject {
            var n:int = getItemIndex(item);
            if(n != -1) {
                removeItemAt(n);
            }
            return item;
        }
        public function removeItemAt(i:int):DisplayObject {
            if(i < 0 || i >= _items.length) return null;
            
            var item:DisplayObject = _items[i];
            _items.splice(i, 1);
            
            if(item is BaseSprite) {
                item.removeEventListener(EVENT_RESIZE, itemResizeHandler);
            }
            
            if(reset) {
                
            } else {
                if(_layout) {
                    var dis:Display = _layout.getLayoutItem(item) as Display;
                    if(dis) {
                        if(dis.displayObject && container.contains(dis.displayObject)) {
                            container.removeChild(dis.displayObject);
                        }
                    }
                    _layout.remove(item);
                }
            }
            invalidate(INVALIDATE_PROP);
            
            return item;
        }
        public function removeAllItem(v:Array = null):void {
            v ||= _items;
            for each(var item:DisplayObject in v) {
                removeItem(item);
            }
        }
        
        public function getItemAt(i:int):DisplayObject {
            return _items[i];
        }
        public function getItemIndex(item:DisplayObject):int {
            return _items.indexOf(item);
        }
        
        protected function itemResizeHandler(env:Event):void {
            invalidate(INVALIDATE_PROP);
        }
        
        protected function resetLayout():void {
            if(null == _layout) return;
            var iterator:IIterator = _layout.iterator();
            while(container.numChildren > 0) {
                container.removeChildAt(0);
            }
            while(iterator.hasNext()) {
                _layout.remove(iterator.next());
            }
            for each(var item:DisplayObject in _items) {
                _layout.add(item);
            }
        }
        public function relayout():void {
            reset = true;
            invalidate(INVALIDATE_PROP);
        }
        
        override public function get contentWidth():Number {
            return _layout && _layout.contentRect ? _layout.contentRect.width : 0;
        }
        override public function get contentHeight():Number {
            return _layout && _layout.contentRect ? _layout.contentRect.height : 0;
        }
        
        protected var container:Sprite = new Sprite();
        override protected function createChildren():void {
            super.createChildren();
            
            addChild(container);
            content = container;
        }
        
        override protected function onProp():void {
            super.onProp();
            
            layoutContent();
            updateContentSize();
        }
        
        protected function layoutContent():void {
            if(_layout) {
                if(reset) {
                    resetLayout();
                    reset = false;
                }
                _layout.layout(container);
            }
        }
    }
}
