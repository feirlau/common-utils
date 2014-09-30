/**
 * @author risker
 * Oct 16, 2013
 **/
package com.fl.component {
    import com.fl.constants.PositionConstants;
    import com.fl.constants.ScrollPolicyConstants;
    import com.fl.event.GlobalEvent;
    import com.fl.vo.EdgeMetrics;
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.geom.Rectangle;

    public class ScrollBase extends BaseComponent {
        public static const EVENT_VSCROLL_CHANGE:String = "EVENT_VSCROLL_CHANGE";
        public static const EVENT_HSCROLL_CHANGE:String = "EVENT_HSCROLL_CHANGE";
        
        override protected function initStyle():void {
            _selfStyles.push("barPaddingLeft", "barPaddingRight", "barPaddingTop", "barPaddingBottom",
                "hStyle", "vStyle"
            );
            super.initStyle();
        }
        
        private var _scrollPolicy:String = ScrollPolicyConstants.AUTO;
        public function set scrollPolicy(v:String):void {
            _scrollPolicy = v;
            hScrollPolicy = v;
            vScrollPolicy = v;
        }
        public function get scrollPolicy():String {
            return _scrollPolicy;
        }
        
        private var _hScrollPolicy:String = ScrollPolicyConstants.AUTO;
        public function set hScrollPolicy(v:String):void {
            if(_hScrollPolicy != v) {
                _hScrollPolicy = v;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        public function get hScrollPolicy():String {
            return needScroll ? _hScrollPolicy : ScrollPolicyConstants.OFF;
        }
        
        private var _vScrollPolicy:String = ScrollPolicyConstants.AUTO;
        public function set vScrollPolicy(v:String):void {
            if(_vScrollPolicy != v) {
                _vScrollPolicy = v;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        public function get vScrollPolicy():String {
            return needScroll ? _vScrollPolicy : ScrollPolicyConstants.OFF;
        }
        
        private var _hScrollPosition:String = PositionConstants.RIGHT;
        public function set hScrollPosition(v:String):void {
            if(_hScrollPosition != v) {
                _hScrollPosition = v;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        public function get hScrollPosition():String {
            return _hScrollPosition;
        }
        
        private var _vScrollPosition:String = PositionConstants.BOTTOM;
        public function set vScrollPosition(v:String):void {
            if(_vScrollPosition != v) {
                _vScrollPosition = v;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        public function get vScrollPosition():String {
            return _vScrollPosition;
        }
        
        private var _hValue:Number = 0;
        public function set hValue(v:Number):void {
            if(_hValue != v) {
                setHValue(v);
            }
        }
        public function get hValue():Number {
            return hScrollBar ? hScrollBar.value : 0;
        }
        private var oldHValue:Number = 0;
        public function setHValue(v:Number, toSet:Boolean = true, toScroll:Boolean = true):void {
            if(!hScrollBar) return;
            oldHValue = _hValue;
            _hValue = v;
            if(toSet) {
                hScrollBar.value = v;
            }
            if(toScroll) {
                scrollContent();
            }
            dispatchEvent(new GlobalEvent(EVENT_HSCROLL_CHANGE, oldHValue));
        }
        public function get hMax():Number {
            if(!hScrollBar) return 0;
            validateNow();
            return hScrollBar.maximum;
        }
        
        private var _vValue:Number = 0;
        public function set vValue(v:Number):void {
            if(_vValue != v) {
                setVValue(v);
            }
        }
        public function get vValue():Number {
            return vScrollBar ? vScrollBar.value : 0;
        }
        private var oldVValue:Number = 0;
        public function setVValue(v:Number, toSet:Boolean = true, toScroll:Boolean = true):void {
            if(!vScrollBar) return;
            oldVValue = _vValue;
            _vValue = v;
            if(toSet) {
                vScrollBar.value = v;
            }
            if(toScroll) {
                scrollContent();
            }
            dispatchEvent(new GlobalEvent(EVENT_HSCROLL_CHANGE, oldVValue));
        }
        public function get vMax():Number {
            if(!vScrollBar) return 0;
            validateNow();
            return vScrollBar.maximum;
        }
        
        private var _scrollWidth:Number = 16;
        public function set scrollWidth(v:Number):void {
            if(_scrollWidth != v) {
                _scrollWidth = v;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        public function get scrollWidth():Number {
            return _scrollWidth;
        }
        
        protected var _maxWidth:Number = NaN;
        /**
         * Sets/gets the maxWidth of the component.
         */
        public function set maxWidth(w:Number):void {
            if(_maxWidth != w) {
                _maxWidth = w;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        public function get maxWidth():Number {
            return _maxWidth;
        }
        
        protected var _maxHeight:Number = NaN;
        /**
         * Sets/gets the maxHeight of the component.
         */
        public function set maxHeight(h:Number):void {
            if(_maxHeight != h) {
                _maxHeight = h;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        public function get maxHeight():Number {
            return _maxHeight;
        }
        
        protected var _contentWidth:Number = 0;
        public function set contentWidth(v:Number):void {
            if(_contentWidth != v) {
                _contentWidth = v;
                updateContentSize();
            }
        }
        public function get contentWidth():Number {
            return _content ? _content.width : _contentWidth;
        }
        
        protected var _contentHeight:Number = 0;
        public function set contentHeight(v:Number):void {
            if(_contentHeight != v) {
                _contentHeight = v;
                updateContentSize();
            }
        }
        public function get contentHeight():Number {
            return _content ? _content.height : _contentHeight;
        }
        
        private var _autoContentSize:Boolean = false;
        /**
         * Gets / sets whether or not this component will be autoSize with content.
         */
        public function set autoContentSize(v:Boolean):void {
            if(_autoContentSize != v) {
                _autoContentSize = v;
                updateContentSize();
            }
        }
        public function get autoContentSize():Boolean {
            return _autoContentSize;
        }
        
        private var _content:DisplayObject;
        public function set content(v:DisplayObject):void {
            if(_content != v) {
                clearContent();
                _content = v;
                if(_content) {
                    _content.addEventListener(EVENT_RESIZE, updateContentSize, false, 0, true);
                }
                updateContentSize();
            }
        }
        public function get content():DisplayObject {
            return _content;
        }
        protected function clearContent():void {
            if(_content) {
                _content.removeEventListener(EVENT_RESIZE, updateContentSize);
            }
        }
        
        /**change the scrollPolicy when autoContentSize/maxWidth/maxHeight are set*/
        protected var needScroll:Boolean = true;
        private var preCW:Number;
        private var preCH:Number;
        protected function updateContentSize(env:Event = null):void {
            needScroll = true;
            if(autoContentSize) {
                needScroll = false;
                var w:Number = contentWidth + _paddings.left + _paddings.right;
                var h:Number = contentHeight + _paddings.top + _paddings.bottom;
                if(!isNaN(_maxWidth) && w > _maxWidth) {
                    needScroll = true;
                    width = _maxWidth;
                } else {
                    width = w;
                }
                if(!isNaN(_maxHeight) && h > _maxHeight) {
                    needScroll = true;
                    height = _maxHeight;
                } else {
                    height = h;
                }
            }
            if(preCW != contentWidth || preCH != contentHeight) {
                preCW = contentWidth;
                preCH = contentHeight;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        protected var _contentScrollRect:Rectangle = new Rectangle();
        public function get contentScrollRect():Rectangle {
            try {validateNow()} catch(e:Error) {}
            return _contentScrollRect;
        }
        protected function scrollContent():void {
            _contentScrollRect.x = hValue;
            _contentScrollRect.y = vValue;
            _contentScrollRect.width = width - _paddings.left - _paddings.right - _scrollEdges.left - _scrollEdges.right;
            _contentScrollRect.height = height - _paddings.top - _paddings.bottom - _scrollEdges.top - _scrollEdges.bottom;
            if(content) {
                if(content is BaseSprite) {
                    (content as BaseSprite).autoClip = false;
                }
                content.x = _paddings.left + _scrollEdges.left;
                content.y = _paddings.top + _scrollEdges.top;
                content.scrollRect = _contentScrollRect;
            }
        }
        
        protected var vScrollBar:ScrollBar;
        private function createVScrollBar():void {
            if(!vScrollBar && vScrollPolicy != ScrollPolicyConstants.OFF) {
                vScrollBar = new ScrollBar();
                vScrollBar.enabled = enabled;
                vScrollBar.direction = PositionConstants.VERTICAL;
                vScrollBar.addEventListener(Slider.EVENT_VALUE_CHANGED, vValueHandler);
                addChild(vScrollBar);
            }
        }
        protected var hScrollBar:ScrollBar;
        private function createHScrollBar():void {
            if(!hScrollBar && hScrollPolicy != ScrollPolicyConstants.OFF) {
                hScrollBar = new ScrollBar();
                hScrollBar.enabled = enabled;
                hScrollBar.direction = PositionConstants.HORIZONTAL;
                hScrollBar.addEventListener(Slider.EVENT_VALUE_CHANGED, hValueHandler);
                addChild(hScrollBar);
            }
        }
        
        override protected function isRawChildren(v:DisplayObject):Boolean {
            return v != hScrollBar && v != vScrollBar && super.isRawChildren(v);
        }
        
        protected function vValueHandler(env:GlobalEvent):void {
            setVValue(vScrollBar.value, false);
        }
        protected function hValueHandler(env:GlobalEvent):void {
            setHValue(hScrollBar.value, false);
        }
        
        protected var _unscrollWidth:Number = 0;
        public function get unscrollWidth():Number {
            return _unscrollWidth;
        }
        protected var _unscrollHeight:Number = 0;
        public function get unscrollHeight():Number {
            return _unscrollHeight;
        }
        protected var _scrollEdges:EdgeMetrics = new EdgeMetrics();
        public function get scrollEdges():EdgeMetrics {
            return _scrollEdges;
        }
        override protected function onResize():void {
            super.onResize();
            
            var hB:Boolean = false;
            var vB:Boolean = false;
            var w:Number = contentWidth + _paddings.left + _paddings.right;
            var h:Number = contentHeight + _paddings.top + _paddings.bottom;
            
            if(ScrollPolicyConstants.ON == hScrollPolicy) {
                hB = true;
                h += scrollWidth;
            } else if(ScrollPolicyConstants.AUTO == hScrollPolicy) {
                if(w > width) {
                    hB = true;
                    h += scrollWidth;
                }
            }
            if(ScrollPolicyConstants.ON == vScrollPolicy) {
                vB = true;
                w += scrollWidth;
            } else if(ScrollPolicyConstants.AUTO == vScrollPolicy) {
                if(h > height) {
                    vB = true;
                    w += scrollWidth;
                }
            }
            if(ScrollPolicyConstants.AUTO == hScrollPolicy && !hB && vB) {
                if(w > width) {
                    hB = true;
                    h += scrollWidth;
                }
            }
            
            _unscrollWidth = w;
            _unscrollHeight = h;
            _scrollEdges.reset();
            
            if(hB) {
                createHScrollBar();
                hScrollBar.maximum = w - width;
                hScrollBar.pageSize = width;
            }
            if(vB) {
                createVScrollBar();
                vScrollBar.maximum = h - height;
                vScrollBar.pageSize = height;
            }
            
            if(hScrollBar) hScrollBar.visible = hB;
            if(hB) {
                if(vB) {
                    hScrollBar.setSize(scrollWidth, width - scrollWidth - barPaddings.left - barPaddings.right);
                    if(vScrollPosition == PositionConstants.LEFT) {
                        hScrollBar.x = scrollWidth + barPaddings.left;
                    } else {
                        hScrollBar.x = barPaddings.left;
                    }
                } else {
                    hScrollBar.setSize(scrollWidth, width - barPaddings.left - barPaddings.right);
                    hScrollBar.x = barPaddings.left;
                }
                if(hScrollPosition == PositionConstants.TOP) {
                    hScrollBar.y = barPaddings.top;
                    _scrollEdges.top = scrollWidth;
                } else {
                    hScrollBar.y = height - scrollWidth - barPaddings.bottom;
                    _scrollEdges.bottom = scrollWidth;
                }
            }
            
            if(vScrollBar) vScrollBar.visible = vB;
            if(vB) {
                if(hB) {
                    vScrollBar.setSize(scrollWidth, height - scrollWidth - barPaddings.top - barPaddings.bottom);
                    if(hScrollPosition == PositionConstants.TOP) {
                        vScrollBar.y = scrollWidth + barPaddings.top;
                    } else {
                        vScrollBar.y = barPaddings.top;
                    }
                } else {
                    vScrollBar.setSize(scrollWidth, height - barPaddings.top - barPaddings.bottom);
                    vScrollBar.y = barPaddings.top;
                }
                if(vScrollPosition == PositionConstants.LEFT) {
                    vScrollBar.x = barPaddings.left;
                    _scrollEdges.left = scrollWidth;
                } else {
                    vScrollBar.x = width - scrollWidth - barPaddings.right;
                    _scrollEdges.right = scrollWidth;
                }
            }
            
            scrollContent();
        }
        
        override public function set enabled(value:Boolean):void {
            super.enabled = value;
            
            if(vScrollBar) vScrollBar.enabled = value;
            if(hScrollBar) hScrollBar.enabled = value;
        }
        
        protected var barPaddings:EdgeMetrics = new EdgeMetrics();
        override public function updateStyle(styleP:String = null):void {
            super.updateStyle(styleP);
            if(acceptStyle(styleP)) {
                barPaddings.left = getStyle("barPaddingLeft");
                barPaddings.right = getStyle("barPaddingRight");
                barPaddings.top = getStyle("barPaddingTop");
                barPaddings.bottom = getStyle("barPaddingBottom");
                barPaddings.checkNaN();
                
                updateScrollStyle(styleP);
                
                invalidate(INVALIDATE_RESIZE);
            }
        }
        protected function updateScrollStyle(styleP:String = null):void {
            if(styleP == null || styleP == "vStyle") {
                if(vScrollBar) vScrollBar.style = getStyle("vStyle");
            }
            if(styleP == null || styleP == "hStyle") {
                if(hScrollBar) hScrollBar.style = getStyle("hStyle");
            }
        }
    }
}
