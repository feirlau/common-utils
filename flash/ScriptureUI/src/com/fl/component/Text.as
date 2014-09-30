/**
 * @author risker
 * Oct 14, 2013
 **/
package com.fl.component {
    import com.fl.constants.ScrollPolicyConstants;
    import com.fl.constants.StatefulConstants;
    
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;

    public class Text extends ScrollBase {
        override protected function initStyle():void {
            _selfStyles.push("state");
            super.initStyle();
        }
        
        override public function acceptStyle(key:String):Boolean {
            return super.acceptStyle(key) || textField.acceptStyle(key);
        }
        protected var _textAutoSize:String = TextFieldAutoSize.NONE;
        /**
         * Gets / sets whether or not this text component will be autoSize.
         */
        public function set textAutoSize(v:String):void {
            if(_textAutoSize != v) {
                _textAutoSize = v;
                invalidate(INVALIDATE_PROP);
            }
        }
        public function get textAutoSize():String {
            return _textAutoSize;
        }
        
        protected var _text:String = "";
        /**
         * Gets / sets the text of this Label.
         */
        public function set text(t:String):void {
            if(_text != t) {
                _text = t;
                if(_text == null) _text = "";
                htmlTextChanged = true;
                invalidate(INVALIDATE_PROP);
            }
        }
        public function get text():String {
            return _text == null ? "" : _text;
        }
        
        protected var _multiline:Boolean = true;
        /**
         * Gets / sets whether or not this text component will be multiline.
         */
        public function set multiline(b:Boolean):void {
            if(_multiline != b) {
                _multiline = b;
                invalidate(INVALIDATE_PROP);
            }
        }
        public function get multiline():Boolean {
            return _multiline;
        }
        
        protected var _wordWrap:Boolean = true;
        /**
         * Gets / sets whether or not this text component will be wordWrap.
         */
        public function set wordWrap(b:Boolean):void {
            if(_wordWrap != b) {
                _wordWrap = b;
                invalidate(INVALIDATE_PROP);
            }
        }
        public function get wordWrap():Boolean {
            return _wordWrap;
        }
        
        protected var _editable:Boolean = false;
        /**
         * Gets / sets whether or not this text component will be editable.
         */
        public function set editable(b:Boolean):void {
            if(_editable != b) {
                _editable = b;
                invalidate(INVALIDATE_PROP);
                invalidate(INVALIDATE_STYLE);
            }
        }
        public function get editable():Boolean {
            return _editable;
        }
        
        protected var _selectable:Boolean = false;
        /**
         * Gets / sets whether or not this text component will be selectable. Only meaningful if editable is false.
         */
        public function set selectable(b:Boolean):void {
            if(_selectable != b) {
                _selectable = b;
                invalidate(INVALIDATE_PROP);
            }
        }
        public function get selectable():Boolean {
            return _selectable;
        }
        
        private var _html:Boolean = false;
        /**
         * Gets / sets whether or not text will be rendered as HTML or plain text.
         */
        public function set html(b:Boolean):void {
            if(_html != b) {
                _html = b;
                htmlTextChanged = true;
                invalidate(INVALIDATE_PROP);
            }
        }
        public function get html():Boolean {
            return _html;
        }
        
        /**
         * Sets/gets whether this component is enabled or not.
         */
        override public function set enabled(value:Boolean):void {
            super.enabled = value;
            _tf.enabled = value;
        }
        
        override public function get hScrollPolicy():String {
            return height <= 40 ? ScrollPolicyConstants.OFF : super.hScrollPolicy;
        }
        
        override public function get vScrollPolicy():String {
            return height <= 40 ? ScrollPolicyConstants.OFF : super.vScrollPolicy;
        }
        
        override public function setHValue(v:Number, toSet:Boolean = true, toScroll:Boolean = true):void {
            super.setHValue(v, toSet, toScroll);
            if(toScroll && _tf.maxScrollH > 0) {
                var n:int = hValue / hsUnit - 1;
                n = Math.max(n, 1);
                if(_tf.scrollH != n) {
                    scrollHandlerEnable = false;
                    _tf.scrollH = n;
                    scrollHandlerEnable = true;
                }
            }
        }
        override public function setVValue(v:Number, toSet:Boolean = true, toScroll:Boolean = true):void {
            super.setVValue(v, toSet, toScroll);
            if(toScroll && _tf.maxScrollV > 0) {
                var n:int = vValue / vsUnit + 1;
                if(_tf.scrollV != n) {
                    scrollHandlerEnable = false;
                    _tf.scrollV = n;
                    scrollHandlerEnable = true;
                }
            }
        }
        
        override protected function scrollContent():void {
            super.scrollContent();
            //2px offset to make it move alignable
            _tf.x = _paddings.left + _scrollEdges.left;
            _tf.y = _paddings.top + _scrollEdges.top;
        }
        
        protected var _tf:BaseTextField = new BaseTextField();
        /**
         * Returns a reference to the internal text field in the component.
         */
        public function get textField():BaseTextField {
            return _tf;
        }
        override protected function createChildren():void {
            super.createChildren();
            
            _tf.addEventListener(Event.SCROLL, onTextScroll);
            _tf.addEventListener(Event.CHANGE, onTextChange);
            _tf.addEventListener(BaseSprite.EVENT_RENDER, onTextRender);
            _tf.addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
            _tf.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
            addChild(_tf);
        }
        /**
         * Called when the text in the text field is manually changed.
         */
        protected function onTextChange(event:Event):void {
            _text = _html ? _tf.htmlText : _tf.text;
            //reset the scrollbar will case the scroll problems
            if(!editable) {
                scrollEdges.reset();
            }
            invalidate(INVALIDATE_PROP);
            dispatchEvent(event);
        }
        private var scrollHandlerEnable:Boolean = true;
        protected function onTextScroll(event:Event):void {
            if(!scrollHandlerEnable) return;
            var n:int = _tf.scrollH;
            if(n > 0) n --;
            setHValue(n * hsUnit, true, false);
            
            n = _tf.scrollV;
            if(n > 0) n --;
            setVValue(n * vsUnit, true, false);
        }
        protected function onTextRender(event:Event):void {
            invalidate(INVALIDATE_PROP);
        }
        protected function focusInHandler(event:FocusEvent):void {
            setStyle(StatefulConstants.STATE, focused ? StatefulConstants.FOCUS : "");
        }
        protected function focusOutHandler(event:FocusEvent):void {
            setStyle(StatefulConstants.STATE, focused ? StatefulConstants.FOCUS : "");
        }
        
        override public function get focused():Boolean {
            return stage && stage.focus == _tf;
        }
        override public function setFocus():void {
            stage && (stage.focus = _tf);
        }
        
        override protected function onResize():void {
            super.onResize();
            
            invalidate(INVALIDATE_PROP);
        }
        
        protected var textPW:int = 5;
        protected var textPH:int = 4;
        private var vsUnit:Number = 1;
        private var hsUnit:Number = 1;
        override protected function onProp():void {
            scrollHandlerEnable = false;
            super.onProp();
            
            _tf.multiline = _multiline;
            _tf.wordWrap = _wordWrap;
            _tf.autoSize = _textAutoSize;
            updateText();
            
            if(_editable) {
                _tf.type = TextFieldType.INPUT;
                _tf.mouseEnabled = true;
                _tf.selectable = true;
                mouseChildren = true;
            } else {
                _tf.type = TextFieldType.DYNAMIC;
                _tf.mouseEnabled = _selectable;
                _tf.selectable = _selectable;
                mouseChildren = _selectable;
                if(!_selectable) {
                    _tf.setSelection(0, 0);
                }
            }
            _tf.render(false);
            
            var w:Number;
            var h:Number;
            if(!autoContentSize) {
                w = width - _paddings.left - _paddings.right - _scrollEdges.left - _scrollEdges.right;
                _tf.width = w;
                h = height - _paddings.top - _paddings.bottom - _scrollEdges.top - _scrollEdges.bottom;
                _tf.height = h;
            } else {
                _tf.autoSize = TextFieldAutoSize.LEFT;
                _tf.wordWrap = false;
                w = _tf.textWidth;
                h = _tf.textHeight;
                _tf.wordWrap = _wordWrap;
                _tf.autoSize = _textAutoSize;
                
                _tf.width = w + textPW;
                w = w + _paddings.left + _paddings.right + textPW;
                if(!isNaN(_maxWidth) && w > _maxWidth) {
                    w = _maxWidth;
                    _tf.width = w - _paddings.left - _paddings.right;
                    h = _tf.textHeight;
                }
                
                _tf.height = h + textPH;
                h = h + _paddings.top + _paddings.bottom + textPH;
                if(!isNaN(_maxHeight) && h > _maxHeight) {
                    h = _maxHeight;
                }
                setSize(w, h);
            }
            w = _tf.textWidth;
            h = _tf.textHeight;
            
            //the scroll unit of textfield
            //for horizontal scroll, the unit is 1, maxScrollH will be larger
            hsUnit = _tf.maxScrollH >= 1 ? (w - _tf.width) / (_tf.maxScrollH - 1) : 1;
            vsUnit = _tf.maxScrollV >= 1 ? (h - _tf.height) / (_tf.maxScrollV - 1) : 1;
            
            contentWidth = w;
            contentHeight = h;
            
            scrollHandlerEnable = true;
        }
        protected var htmlTextChanged:Boolean = true;
        protected function updateText():void {
            if(html) {
                _tf.htmlText = _text;
            } else {
                _tf.text = _text;
            }
            htmlTextChanged = false;
        }
        
        override public function set style(value:*):void {
            super.style = value;
            _tf.style = value;
        }
    }
}
