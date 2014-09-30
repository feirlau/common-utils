package com.fl.style {
	import com.adobe.serialization.json.JSON;
	import com.fl.utils.FLUtil;
	import com.fl.utils.LogUtil;
	import com.fl.utils.SkinUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;

    public class Style extends EventDispatcher implements IStyle {
        public static const KEY_SEP:String = ">";
		private var _styles:Object = new Object();
		public function get styles():Object {
			return _styles;
		}
		public function setStyle(key:String, value:*):void {
            if(!key) return;
            
            var keys:Array = key.split(KEY_SEP);
            var s:Object = _styles;
            for(var i:int = 0; i < keys.length - 1; i++) {
                try {
                    s = s[keys[i]];
                } catch(err:Error) {
                    LogUtil.addLog(this, ["[setStyle] unknow key " + keys[i], key, value], LogUtil.ERROR);
                }
            }
            if(s) {
                try {
                    s[keys[i]] = value;
                } catch(err:Error) {
                    LogUtil.addLog(this, ["[setStyle] unknow key " + keys[i], key, value], LogUtil.ERROR);
                }
            }
			dispatchEvent(new StyleEvent(StyleEvent.EVENT_STYLE_UPDATE, keys[0]));
		}
		public function getStyle(key:String):* {
            if(!key) return;
            
            var keys:Array = key.split(KEY_SEP);
            var s:* = _styles;
            for(var i:int = 0; i < keys.length; i++) {
                try {
                    s = s[keys[i]];
                } catch(err:Error) {
                    LogUtil.addLog(this, ["[getStyle] unknow key " + keys[i], key], LogUtil.ERROR);
                }
            }
			return s;
		}
		public function hasStyle(key:String):Boolean {
			return (key in _styles);
		}
		
		public function copyStyle(style:*):void {
			if(style) {
				if(style is IStyle) {
					style = (style as IStyle).styles;
				} else if(style is String) {
					try {
						style = com.adobe.serialization.json.JSON.decode(style);
					} catch(err:Error) {
						trace(FLUtil.getClassName(this), "copy", err.getStackTrace());
					}
				}
				for(var key:* in style) {
					_styles[key] = style[key];
				}
				refreshStyle();
			}
		}
        
        public function refreshStyle():void {
            dispatchEvent(new StyleEvent(StyleEvent.EVENT_STYLE_UPDATE));
        }
    }
}
