/**
 * @author risker
 * Oct 14, 2013
 **/
package com.fl.component {
    import com.fl.event.GlobalEvent;
    import com.fl.style.IStyle;
    import com.fl.style.Style;
    import com.fl.style.StyleEvent;
    import com.fl.utils.StringUtil;
    
    import flash.text.TextField;
    import flash.text.TextFormat;

    public class BaseTextField extends TextField implements IStyle {
        public function BaseTextField() {
            super();
            
            //@see flash.text. TextFormat
            _selfStyles = ["color", "upColor", "overColor", "downColor", "focusColor", "disabledColor",
                "font", "size", "italic", "bold", "underline",
                "align", "indent", "blockIndent", "bullet",
                "kerning", "leading", "letterSpacing",
                "leftMargin", "rightMargin", "tabStops", "state"
            ];
        }
        
        /**
         *  @private
         *  Storage for the enabled property.
         */
        private var _enabled:Boolean = true;
        
        /**
         *  A Boolean value that indicates whether the component is enabled. 
         *  This property only affects
         *  the color of the text and not whether the BaseTextField is editable.
         *  To control editability, use the 
         *  <code>flash.text.TextField.type</code> property.
         *  
         *  @default true
         *  @see flash.text.TextField
         */
        public function get enabled():Boolean {
            return _enabled;
        }
        public function set enabled(value:Boolean):void {
            _enabled = value;
            mouseEnabled = value;
            tabEnabled = value;
            updateStyle("color");
        }
        
        private var _style:IStyle;
        public function get style():IStyle {
            return _style;
        }
        public function set style(value:*):void {
            var s:IStyle;
            if(value is IStyle) {
                s = value;
            } else {
                s = new Style();
                s.copyStyle(value);
            }
            if(_style != s) {
                if(_style) {
                    _style.removeEventListener(StyleEvent.EVENT_STYLE_UPDATE, styleHandler);
                }
                _style = s;
                if(_style) {
                    _style.addEventListener(StyleEvent.EVENT_STYLE_UPDATE, styleHandler, false, 0, true);
                }
                updateStyle();
            }
        }
        protected function styleHandler(env:StyleEvent = null):void {
            var styleP:String = env ? String(env.data) : null;
            updateStyle(styleP);
        }
        public function updateStyle(styleP:String = null):void {
            if(acceptStyle(styleP)) {
                render(true);
            }
        }
        
        public function render(fireEvent:Boolean = false):void {
            var textFormat:TextFormat = getTextStyles();
            setTextFormat(textFormat);
            defaultTextFormat = textFormat;
            
            if(fireEvent) {
                dispatchEvent(new GlobalEvent(BaseSprite.EVENT_RENDER));
            }
        }
        
        private var cachedTextFormat:TextFormat;
        public function getTextStyles():TextFormat {
            var textFormat:TextFormat = new TextFormat();
            
            var state:String = getStyle("state");
            var c:Object;
            if(state) {
                c = getStyle(state + "Color");
                c ||= getStyle("color");
                textFormat.color = c;
            } else if(enabled) {
                textFormat.color = getStyle("color");
            } else {
                textFormat.color = getStyle("disabledColor");
            }
            textFormat.font = StringUtil.trimArrayElements(getStyle("font"),",");
            textFormat.size = getStyle("size");
            textFormat.bold = getStyle("bold");
            textFormat.italic = getStyle("italic");
            textFormat.underline = getStyle("underline");
            
            textFormat.align = getStyle("align");
            textFormat.indent = getStyle("indent");
            textFormat.blockIndent = getStyle("blockIndent");
            textFormat.bullet = getStyle("bullet");
            
            textFormat.kerning = getStyle("kerning");
            textFormat.leading = getStyle("leading");
            textFormat.letterSpacing = getStyle("letterSpacing");
            
            textFormat.leftMargin = getStyle("leftMargin");
            textFormat.rightMargin = getStyle("rightMargin");
            textFormat.tabStops = getStyle("tabStops");
            
            cachedTextFormat = textFormat;
            return textFormat;
        }
        
        public function get styles():Object {
            return _style ? _style.styles : null;
        }
        public function setStyle(key:String, value:*):void {
            if(_style) _style.setStyle(key, value);
        }
        public function getStyle(key:String):* {
            return _style ? _style.getStyle(key) : null;
        }
        public function hasStyle(key:String):Boolean {
            return _style ? _style.hasStyle(key) : false;
        }
        public function copyStyle(style:*):void {
            if(_style && style) {
                _style.copyStyle(style);
            }
        }
        public function refreshStyle():void {
            _style && _style.refreshStyle();
        }
        public function acceptStyle(key:String):Boolean {
            var b:Boolean = false;;
            if(_selfStyles && _selfStyles.length > 0) {
                b = key == null || _selfStyles.indexOf(key) != -1;
            }
            return b;
        }
        protected var _selfStyles:Array = [];
        public function get selfStyles():Array {
            return _selfStyles;
        }
    }
}
