/**
 * @author risker
 * Oct 28, 2013
 **/
package com.fl.component {
    import com.fl.constants.PositionConstants;
    import com.fl.event.GlobalEvent;
    import com.fl.utils.ClassFactory;
    import com.fl.vo.ArrayList;
    
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    
    import org.as3commons.ui.layout.CellConfig;
    import org.as3commons.ui.layout.HLayout;
    import org.as3commons.ui.layout.VLayout;
    import org.as3commons.ui.layout.framework.ILayout;
    import org.as3commons.ui.layout.framework.core.AbstractLayout;
    import org.as3commons.ui.layout.framework.core.AbstractMultilineLayout;
    import org.as3commons.ui.layout.shortcut.hlayout;
    import org.as3commons.ui.layout.shortcut.vlayout;
    
    public class ScrollTile extends Box {
        public static const EVENT_ITEM_SELECT:String = "EVENT_ITEM_SELECT";
        
        public function ScrollTile() {
            super();
            
            autoContentSize = false;
            
            updateLayout();
        }
        
        override public function set layout(v:ILayout):void {
            //do nothing
        }
        
        private var _direction:String = PositionConstants.HORIZONTAL;
        /**
         * Gets / sets the tile direction.
         */
        public function set direction(v:String):void {
            if(_direction != v) {
                _direction = v;
                updateLayout();
            }
        }
        public function get direction():String {
            return _direction;
        }
        public function updateLayout():void {
            if(_direction == PositionConstants.HORIZONTAL) {
                _layout = hlayout();
            } else {
                _layout = vlayout();
            }
            updateRendersNum();
            invalidate(INVALIDATE_PROP);
        }
        public function updateLayoutInfo():void {
            var b:Boolean = false;
            if(_layout is HLayout) {
                var hl:HLayout = _layout as HLayout;
                if(hl.maxItemsPerRow != itemNum) {
                    hl.maxItemsPerRow = itemNum;
                    b = true;
                }
            } else if(_layout is VLayout) {
                var vl:VLayout = _layout as VLayout;
                if(vl.maxItemsPerColumn != itemNum) {
                    vl.maxItemsPerColumn = itemNum;
                    b = true;
                }
            }
            if(_layout) {
                var cc:CellConfig = _layout.getCellConfig();
                cc ||= new CellConfig();
                if(cc.width != itemWidth || cc.height != itemHeight) {
                    cc.width = itemWidth;
                    cc.height = itemHeight;
                    _layout.setCellConfig(cc);
                    b = true;
                }
                updateScrollPageSize();
            }
            b && invalidate(INVALIDATE_PROP);
        }
        
        override public function get contentWidth():Number {
            return _contentWidth;
        }
        override public function get contentHeight():Number {
            return _contentHeight;
        }
        
        private var _row:int = 4;
        public function get row():int {
            return _row;
        }
        public function set row(value:int):void {
            if(_row != value) {
                _row = value;
                updateRendersNum();
            }
        }
        
        private var _column:int = 1;
        public function get column():int {
            return _column;
        }
        public function set column(value:int):void {
            if(_column != value) {
                _column = value;
                updateRendersNum();
            }
        }
        
        private var _itemHeight:int = 20;
        public function get itemHeight():int {
            return _itemHeight;
        }
        public function set itemHeight(value:int):void {
            if(_itemHeight != value) {
                _itemHeight = value;
                updateRendersNum();
                updateRenderSize();
            }
        }
        protected function updateScrollPageSize():void {
            /** **/
            var ly:AbstractMultilineLayout = _layout as AbstractMultilineLayout;
            if(hScrollBar) hScrollBar.lineSize = _itemWidth + ly.hGap;
            if(vScrollBar) vScrollBar.lineSize = _itemHeight + ly.vGap;
        }
        
        private var _itemWidth:int = 80;
        public function get itemWidth():int {
            return _itemWidth;
        }
        public function set itemWidth(value:int):void {
            if(_itemWidth != value) {
                _itemWidth = value;
                updateRendersNum();
                updateRenderSize();
            }
        }
        
        protected var rendererChanged:Boolean = true;
        protected var _itemRenderer:ClassFactory = new ClassFactory(TileItemRenderer);
        public function get itemRenderer():ClassFactory {
            return _itemRenderer;
        }
        public function set itemRenderer(value:ClassFactory):void {
            if(_itemRenderer != value) {
                _itemRenderer = value;
                rendererChanged = true;
                invalidate(INVALIDATE_PROP);
            }
        }
        
        protected var rawW:Number = _width;
        override public function set width(w:Number):void {
            rawW = w;
            super.width = w;
        }
        protected var rawH:Number = _width;
        override public function set height(h:Number):void {
            rawH = h;
            super.height = h;
        }
        
        protected var itemNum:int = 0;
        protected var rendersNum:int = 0;
        protected function updateRendersNum():void {
            if(!_layout) return;
            var n:int = 0;
            var m:int = _dataProvider ? _dataProvider.length : 0;
            var k:int = 0;
            n = _row * _column;
            var hP:Number =  + _paddings.left + _paddings.right + scrollEdges.left + scrollEdges.right;
            var vP:Number = _paddings.top + _paddings.bottom + scrollEdges.top + scrollEdges.bottom;
            if(_direction == PositionConstants.HORIZONTAL) {
                var hl:HLayout = _layout as HLayout;
                if(_column <= 0) {
                    if(autoContentSize) {
                        itemNum = 0;
                    } else if(width > 0) {
                        itemNum = Math.floor((width - hP) / _itemWidth);
                        itemNum = Math.max(1, itemNum);
                    } else {
                        itemNum = 0;
                    }
                } else {
                    itemNum = _column;
                }
                
                k = itemNum == 0 ? m : itemNum;
                contentWidth = getLen(k, _itemWidth, hl.hGap);
                
                k = itemNum == 0 ? 1 : Math.ceil(m / itemNum);
                contentHeight = getLen(k, _itemHeight, hl.vGap);
                
                if(autoContentSize) {
                    n = m;
                } else {
                    if(rawW == 0) {
                        super.width = _unscrollWidth;
                    }
                    if(rawH == 0) {
                        super.height = _row == 0 ? _unscrollHeight : getLen(_row, _itemHeight, hl.vGap, true) + vP;
                    }
                    if(rawH == 0 && _row > 0) {
                        n = itemNum * _row;
                    } else {
                        n = itemNum * Math.ceil(height / _itemHeight);
                    }
                }
            } else {
                var vl:VLayout = _layout as VLayout;
                if(_row <= 0) {
                    if(autoContentSize) {
                        itemNum = 0;
                    } else if(height > 0) {
                        itemNum = Math.floor((height - vP) / _itemHeight);
                        itemNum = Math.max(1, itemNum);
                    } else {
                        itemNum = 0;
                    }
                } else {
                    itemNum = _row;
                }
                
                k = itemNum == 0 ? m : itemNum;
                contentHeight = getLen(k, _itemHeight, vl.vGap);
                
                k = itemNum == 0 ? 1 : Math.ceil(m / itemNum);
                contentWidth = getLen(k, _itemWidth, vl.hGap);
                
                if(autoContentSize) {
                    n = m;
                } else {
                    if(rawH == 0) {
                        super.height = _unscrollHeight;
                    }
                    if(rawW == 0) {
                        super.width = _column == 0 ? _unscrollWidth : getLen(_column, _itemWidth, vl.hGap, true) + hP;
                    }
                    if(rawW == 0 && _column > 0) {
                        n = itemNum * _column;
                    } else {
                        n = itemNum * Math.ceil(width / _itemWidth);
                    }
                }
            }
            
            updateLayoutInfo();
            
            if(rendersNum != n) {
                rendersNum = n;
                rendererChanged = true;
                invalidate(INVALIDATE_PROP);
            }
        }
        
        protected function updateRenderSize():void {
            var r:*;
            for each(r in renders) {
                r.width = _itemWidth;
                r.height = _itemHeight;
            }
        }
        
        /***
        * @param d, decress gap num by 1
        * @param p, add padding and scroll edges
        **/
        public function getLen(n:int, w:Number, g:Number, d:Boolean = true):Number {
            var m:Number = w * n;
            if(g != 0) {
                if(d) n = n - 1;
                m += (n > 0 ? g * n : 0);
            }
            return  m;
        }
        
        protected var renders:Array = [];
        protected function updateRenders():void {
            if(!rendererChanged) return;
            rendererChanged = false;
            rendererDataChanged = true;
            
            var r:*;
            for each(r in renders) {
                r.data = null;
                r.removeEventListener(MouseEvent.CLICK, itemClickHandler);
            }
            removeAllItem();
            renders.splice(0, renders.length);
            
            if(_itemRenderer) {
                for(var i:int = 0; i < rendersNum; i++) {
                    r = _itemRenderer.newInstance();
                    r.width = _itemWidth;
                    r.height = _itemHeight;
                    r.data = null;
                    r.addEventListener(MouseEvent.CLICK, itemClickHandler);
                    renders.push(r);
                }
                addAllItem(renders);
            }
        }
        public var multiSelection:Boolean = false;
        protected function itemClickHandler(env:MouseEvent):void {
            var r:IItemRenderer = env.currentTarget as IItemRenderer;
            _selectedItems ||= [];
            if(multiSelection && env.ctrlKey) {
                var i:int = _selectedItems.indexOf(r.data);
                if(i == -1) {
                    _selectedItems.push(r.data);
                } else {
                    _selectedItems.splice(i, 1);
                }
            } else {
                _selectedItems = [r.data];
            }
            updateSelectedItems();
            dispatchEvent(new GlobalEvent(EVENT_ITEM_SELECT, r));
        }
        
        private var _showEmpty:Boolean = true;
        public function get showEmpty():Boolean {
            return _showEmpty;
        }
        public function set showEmpty(value:Boolean):void {
            if(_showEmpty != value) {
                _showEmpty = value;
                updateEmptyItems();
            }
        }
        public function updateEmptyItems():void {
            for each(var r:* in renders) {
                r.visible = r.data != null || _showEmpty;
            }
        }
        
        protected var _dataProvider:ArrayList;
        public function get dataProvider():ArrayList {
            return _dataProvider;
        }
        public function set dataProvider(value:ArrayList):void {
            if(_dataProvider != value) {
                _dataProvider && _dataProvider.removeEventListener(ArrayList.EVENT_UPDATE, dataProviderChanged);
                _dataProvider = value;
                updateDataProvider();
                _dataProvider && _dataProvider.addEventListener(ArrayList.EVENT_UPDATE, dataProviderChanged);
            }
        }
        private function dataProviderChanged(env:GlobalEvent):void {
            updateDataProvider();
        }
        
        protected var rendererDataChanged:Boolean = true;
        public function updateDataProvider():void {
            updateRendersNum();
            
            _fromScroll = false;
            rendererDataChanged = true;
            invalidate(INVALIDATE_PROP);
        }
        
        public function updateRendererData():void {
            if(!rendererDataChanged) return;
            rendererDataChanged = false;
            
            var n:int = _dataProvider ? _dataProvider.length : 0;
            if(_scrollIndex >= n) _scrollIndex = Math.max(0, n - 1);
            if(n - _scrollIndex < rendersNum) {
                _scrollIndex = n - rendersNum;
                _scrollIndex = Math.max(0, _scrollIndex);
            }
            
            var r:IItemRenderer;
            var i:int = _scrollIndex;
            for each(r in renders) {
                if(i < n) {
                    r.data = _dataProvider[i];
                } else {
                    r.data = null;
                }
                r.visible = r.data != null || _showEmpty;
                i++;
            }
            
            if(_fromScroll) {
                scrollContent();
            } else {
                if(_direction == PositionConstants.HORIZONTAL) {
                    var hl:HLayout = _layout as HLayout;
                    if(itemNum == 0) {
                        setHValue(getLen(_scrollIndex, _itemWidth, hl.hGap, false), true, false);
                    } else {
                        setVValue(getLen(_scrollIndex / itemNum, _itemHeight, hl.vGap, false), true, false);
                    }
                } else {
                    var vl:VLayout = _layout as VLayout;
                    if(itemNum == 0) {
                        setVValue(getLen(_scrollIndex, _itemHeight, vl.vGap, false), true, false);
                    } else {
                        setHValue(getLen(_scrollIndex / itemNum, _itemWidth, vl.hGap, false), true, false);
                    }
                }
            }
            _fromScroll = false;
            
            updateSelectedItems();
        }
        
        private var _selectedItems:Array;
        public function get selectedItems():Array {
            return _selectedItems ? _selectedItems : [];
        }
        public function set selectedItems(value:*):void {
            if(_selectedItems != value) {
                if(!(value is Array)) {
                    value = value == null ? null : [value];
                }
                _selectedItems = value;
                invalidate(INVALIDATE_PROP);
                dispatchEvent(new GlobalEvent(EVENT_ITEM_SELECT));
            }
        }
        public function updateSelectedItems():void {
            try {
                var item:*;
                for(var i:int = _selectedItems.length - 1; i >= 0; i--) {
                    item = _selectedItems[i];
                    if(_dataProvider && _dataProvider.indexOf(item) == -1) {
                        _selectedItems.splice(i, 1);
                    }
                }
                
                for each(var r:IItemRenderer in renders) {
                    if(r.data && _selectedItems && _selectedItems.indexOf(r.data) != -1) {
                        r.selected = true;
                    } else {
                        r.selected = false;
                    }
                }
            } catch(err:Error) {}
        }
        
        public function gotoRendererAt(i:int):IItemRenderer {
            var r:IItemRenderer;
            var n:int = _dataProvider ? _dataProvider.length : 0;
            if(i < 0 || i >= n) i = Math.max(0, n - 1);
            if(n - i >= rendersNum) {
                n = 0;
            } else {
                n = rendersNum - (n - i);
            }
            scrollIndex = i;
            return r[n];
        }
        
        protected var _rawScrollIndex:int = 0;
        public function get rawScrollIndex():int {
            return _rawScrollIndex;
        }
        protected var _scrollIndex:int = 0;
        public function get scrollIndex():int {
            return _scrollIndex;
        }
        public function set scrollIndex(i:int):void {
            if(_scrollIndex != i) {
                _scrollIndex = i;
                _rawScrollIndex = i;
                _fromScroll = false;
                rendererDataChanged = true;
                invalidate(INVALIDATE_PROP);
            }
        }
        
        protected var _fromScroll:Boolean = false;
        override public function setHValue(v:Number, toSet:Boolean = true, toScroll:Boolean = true):void {
            super.setHValue(v, toSet, toScroll);
            if(toScroll) {
                var n:int = -1;
                if(_direction == PositionConstants.HORIZONTAL) {
                    var hl:HLayout = _layout as HLayout;
                    if(itemNum == 0) {
                        n = v / (_itemWidth + hl.hGap);
                    } else {
                        //do nothing
                    }
                } else {
                    var vl:VLayout = _layout as VLayout;
                    if(itemNum == 0) {
                        //do nothing
                    } else {
                        n = Math.round(v / (_itemWidth + vl.hGap)) * itemNum;
                    }
                }
                if(n >= 0) {
                    var m:int = _dataProvider ? _dataProvider.length : 0;
                    m = Math.max(0, m - rendersNum);
                    n = Math.min(m, n);
                    
                    scrollIndex = n;
                    
                    _fromScroll = true;
                }
            }
        }
        override public function setVValue(v:Number, toSet:Boolean = true, toScroll:Boolean = true):void {
            super.setVValue(v, toSet, toScroll);
            if(toScroll) {
                var n:int = -1;
                if(_direction == PositionConstants.HORIZONTAL) {
                    var hl:HLayout = _layout as HLayout;
                    if(itemNum == 0) {
                        //do nothing
                    } else {
                        n = Math.round(v / (_itemHeight + hl.vGap)) * itemNum;
                    }
                } else {
                    var vl:VLayout = _layout as VLayout;
                    if(itemNum == 0) {
                        n = v / (_itemHeight + vl.vGap);
                    } else {
                        //do nothing
                    }
                }
                
                if(n >= 0) {
                    var m:int = _dataProvider ? _dataProvider.length : 0;
                    m = Math.max(0, m - rendersNum);
                    n = Math.min(m, n);
                    
                    scrollIndex = n;
                    _fromScroll = true;
                }
            }
        }
        
        override protected function createChildren():void {
            super.createChildren();
            
            content = null;
        }
        
        protected var _sr:Rectangle = new Rectangle();
        override protected function scrollContent():void {
            super.scrollContent();
            if(container) {
                var xO:Number = 0;
                var yO:Number = 0;
                if(_direction == PositionConstants.HORIZONTAL) {
                    var hl:HLayout = _layout as HLayout;
                    if(itemNum == 0) {
                        xO = _contentScrollRect.x - getLen(_scrollIndex, _itemWidth, hl.hGap, false);
                        yO = _contentScrollRect.y;
                    } else {
                        xO = _contentScrollRect.x;
                        yO = _contentScrollRect.y - getLen(_scrollIndex / itemNum, _itemHeight, hl.vGap, false);
                    }
                } else {
                    var vl:VLayout = _layout as VLayout;
                    if(itemNum == 0) {
                        xO = _contentScrollRect.x;
                        yO = _contentScrollRect.y - getLen(_scrollIndex, _itemHeight, vl.vGap, false);
                    } else {
                        xO = _contentScrollRect.x - getLen(_scrollIndex / itemNum, _itemWidth, vl.hGap, false);
                        yO = _contentScrollRect.y;
                    }
                }
                container.x = _paddings.left + _scrollEdges.left;
                container.y = _paddings.top + _scrollEdges.top;
                _sr.x = xO;
                _sr.y = yO;
                _sr.width = _contentScrollRect.width;
                _sr.height = _contentScrollRect.height;
                container.scrollRect = _sr;
            }
        }
        
        override protected function onProp():void {
            updateRenders();
            updateRendererData();
            
            super.onProp();
        }
        
        override protected function onResize():void {
            super.onResize();
            
            if(!autoContentSize) {
                updateRendersNum();
            }
        }
    }
}
