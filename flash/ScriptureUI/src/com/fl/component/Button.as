/**
 * @author risker
 * Oct 18, 2013
 **/
package com.fl.component {
    import com.fl.constants.PositionConstants;
    import com.fl.constants.ScrollPolicyConstants;
    import com.fl.constants.StatefulConstants;
    import com.fl.event.GlobalEvent;
    import com.fl.skin.ISkin;
    import com.fl.style.IStyle;
    import com.fl.style.Style;
    
    import flash.events.Event;
    import flash.events.MouseEvent;

    public class Button extends StatefulComponent {
        public static const EVENT_SELECT_CHANGED:String = "EVENT_SELECT_CHANGED";
        
        public function Button() {
            super();
            
            _text.scrollPolicy = ScrollPolicyConstants.OFF;
            _text.wordWrap = false;
            _text.autoContentSize = true;
            _text.selectable = false;
            _text.mouseEnabled = _text.mouseChildren = false;
        }
        
        override protected function initStyle():void {
            _selfStyles.push("normalStyle", "selectedStyle", "normalIconStyle", "selectedIconStyle", "normalTextStyle", "selectedTextStyle");
            super.initStyle();
        }
        
        public function set label(v:String):void {
            _text.text = v;
        }
        public function get label():String {
            return _text.text;
        }
        
        public function set html(v:Boolean):void {
            _text.html = v;
        }
        public function get html():Boolean {
            return _text.html;
        }
        
        private var _selected:Boolean = false;
        public function get selected():Boolean {
            return _selected;
        }
        public function set selected(v:Boolean):void {
            if(_selected != v) {
                updateSelected(v);
            }
        }
        public function updateSelected(v:Boolean, fireEvent:Boolean = true):void {
            _selected = v;
            invalidate(INVALIDATE_PROP);
            if(fireEvent) {
                dispatchEvent(new GlobalEvent(EVENT_SELECT_CHANGED));
            }
        }
        
        private var _toggle:Boolean = false;
        public function get toggle():Boolean {
            return _toggle;
        }
        public function set toggle(value:Boolean):void {
            if(_toggle != value) {
                _toggle = value;
                invalidate(INVALIDATE_PROP);
            }
        }
        
        private var _gap:Number = 2;
        public function get gap():Number {
            return _gap;
        }
        public function set gap(value:Number):void {
            if(_gap != value) {
                _gap = value;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        
        private var _hPadding:Number = 0;
        public function get hPadding():Number {
            return _hPadding;
        }
        public function set hPadding(value:Number):void {
            if(_hPadding != value) {
                _hPadding = value;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        
        private var _vPadding:Number = 0;
        public function get vPadding():Number {
            return _vPadding;
        }
        public function set vPadding(value:Number):void {
            if(_vPadding != value) {
                _vPadding = value;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        
        private var _labelPosition:String = PositionConstants.LEFT;
        public function get labelPosition():String {
            return _labelPosition;
        }
        public function set labelPosition(value:String):void {
            if(_labelPosition != value) {
                _labelPosition = value;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        
        private var _hAlign:String = PositionConstants.CENTER;
        public function get hAlign():String {
            return _hAlign;
        }
        public function set hAlign(value:String):void {
            if(_hAlign != value) {
                _hAlign = value;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        
        private var _vAlign:String = PositionConstants.MIDDLE;
        public function get vAlign():String {
            return _vAlign;
        }
        public function set vAlign(value:String):void {
            if(_vAlign != value) {
                _vAlign = value;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        
        protected function clickHandler(env:MouseEvent):void {
            if(_toggle) selected = !_selected;
        }
        
        override protected function init():void {
            super.init();
            
            addEventListener(MouseEvent.CLICK, clickHandler);
        }
        
        protected var _text:Text = new Text();
        public function get text():Text {
            return _text;
        }
        protected var _icon:StatefulComponent = new StatefulComponent();
        public function get icon():StatefulComponent {
            return _icon;
        }
        override protected function createChildren():void {
            super.createChildren();
            
            _text.addEventListener(EVENT_RESIZE, onTextResize);
            addChild(_text);
            _icon.addEventListener(EVENT_RESIZE, onIconResize);
            _icon.autoSkinSize = true;
            _icon.mouseEnabled = _icon.mouseChildren = false;
            addChild(_icon);
        }
        
        protected function onTextResize(env:Event):void {
            invalidate(INVALIDATE_RESIZE);
        }
        protected function onIconResize(env:Event):void {
            invalidate(INVALIDATE_RESIZE);
        }
        
        override protected function onResize():void {
            super.onResize();
            
            layoutButton();
        }
        protected function layoutButton():void {
            var wT:Number = _text.width;
            var hT:Number = _text.height;
            var wI:Number = _icon.width;
            var hI:Number = _icon.height;
            switch(hAlign) {
                case PositionConstants.LEFT:
                    if(PositionConstants.LEFT == labelPosition) {
                        _text.x = hPadding;
                        _icon.x = _text.x + wT + gap;
                    } else if(PositionConstants.RIGHT == labelPosition) {
                        _icon.x = hPadding;
                        _text.x = _icon.x + wI + gap;
                    } else if(PositionConstants.TOP == labelPosition) {
                        _text.x = hPadding;
                        _icon.x = hPadding;
                    } else if(PositionConstants.BOTTOM == labelPosition) {
                        _text.x = hPadding;
                        _icon.x = hPadding;
                    }
                    break;
                case PositionConstants.RIGHT:
                    if(PositionConstants.LEFT == labelPosition) {
                        _icon.x = width - hPadding - wI;
                        _text.x = _icon.x - gap - wT;
                    } else if(PositionConstants.RIGHT == labelPosition) {
                        _text.x = width - hPadding - wT;
                        _icon.x = _text.x - gap - wI;
                    } else if(PositionConstants.TOP == labelPosition) {
                        _text.x = width - hPadding - wT;
                        _icon.x = width - hPadding - wI;
                    } else if(PositionConstants.BOTTOM == labelPosition) {
                        _text.x = width - hPadding - wT;
                        _icon.x = width - hPadding - wI;
                    }
                    break;
                case PositionConstants.CENTER:
                    if(PositionConstants.LEFT == labelPosition) {
                        _text.x = (width - wT - gap - wI) / 2 + hPadding;
                        _icon.x = _text.x + wT + gap;
                    } else if(PositionConstants.RIGHT == labelPosition) {
                        _icon.x = (width - wT - gap - wI) / 2 + hPadding;
                        _text.x = _icon.x + wI + gap;
                    } else if(PositionConstants.TOP == labelPosition) {
                        _text.x = (width - wT) / 2 + hPadding;
                        _icon.x = (width - wI) / 2 + hPadding;
                    } else if(PositionConstants.BOTTOM == labelPosition) {
                        _text.x = (width - wT) / 2 + hPadding;
                        _icon.x = (width - wI) / 2 + hPadding;
                    }
                    break;
            }
            switch(vAlign) {
                case PositionConstants.TOP:
                    if(PositionConstants.LEFT == labelPosition) {
                        _text.y = vPadding;
                        _icon.y = vPadding;
                    } else if(PositionConstants.RIGHT == labelPosition) {
                        _text.y = vPadding;
                        _icon.y = vPadding;
                    } else if(PositionConstants.TOP == labelPosition) {
                        _text.y = vPadding;
                        _icon.y = _text.y + hT + gap;
                    } else if(PositionConstants.BOTTOM == labelPosition) {
                        _icon.y = vPadding;
                        _text.y = _icon.y + hI + gap;
                    }
                    break;
                case PositionConstants.BOTTOM:
                    if(PositionConstants.LEFT == labelPosition) {
                        _text.y = height - vPadding - hT;
                        _icon.y = height - vPadding - hI;
                    } else if(PositionConstants.RIGHT == labelPosition) {
                        _text.y = height - vPadding - hT;
                        _icon.y = height - vPadding - hI;
                    } else if(PositionConstants.TOP == labelPosition) {
                        _icon.y = height - vPadding - hI;
                        _text.y = _icon.y - gap - hT;
                    } else if(PositionConstants.BOTTOM == labelPosition) {
                        _text.y = height - vPadding - hT;
                        _icon.y = _text.y - gap - hI;
                    }
                    break;
                case PositionConstants.MIDDLE:
                    if(PositionConstants.LEFT == labelPosition) {
                        _text.y = (height - hT) / 2 + vPadding;
                        _icon.y = (height - hI) / 2 + vPadding;
                    } else if(PositionConstants.RIGHT == labelPosition) {
                        _text.y = (height - hT) / 2 + vPadding;
                        _icon.y = (height - hI) / 2 + vPadding;
                    } else if(PositionConstants.TOP == labelPosition) {
                        _text.y = (height - hT - gap - hI) / 2 + vPadding;
                        _icon.y = _text.y + hT + gap;
                    } else if(PositionConstants.BOTTOM == labelPosition) {
                        _icon.y = (height - hI - gap - hT) / 2 + vPadding;
                        _text.y = _icon.y + hI + gap;
                    }
                    break;
            }
        }
        
        override protected function onProp():void {
            super.onProp();
            
            updateSkinStyle();
            updateIconStyle();
            updateTextStyle();
        }
        
        override protected function onStyle():void {
            super.onStyle();
            
            updateSkinStyle();
            updateIconStyle();
            updateTextStyle();
        }
        
        override protected function updateSkinStyle():void {
            var s:IStyle;
            if(skin is ISkin) {
                s = ISkin(skin).style ||= new Style();
                s.copyStyle(_selected ? getStyle("selectedStyle") : getStyle("normalStyle"));
                s.setStyle(StatefulConstants.STATE, state);
            }
        }
        protected function updateIconStyle():void {
            var s:IStyle;
            s = _icon.style ||= new Style();
            s.copyStyle(_selected ? getStyle("selectedIconStyle") : getStyle("normalIconStyle"));
            s.setStyle(StatefulConstants.STATE, state);
        }
        protected function updateTextStyle():void {
            var s:IStyle;
            s = _text.style ||= new Style();
            s.copyStyle(_selected ? getStyle("selectedTextStyle") : getStyle("normalTextStyle"));
            s.setStyle(StatefulConstants.STATE, state);
        }
    }
}
