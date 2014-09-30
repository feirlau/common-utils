/**
 * @author risker
 **/
package com.fl.component
{
	import com.fl.event.GlobalEvent;
	import com.fl.skin.ISkin;
	import com.fl.skin.Skin;
	import com.fl.skin.SkinManager;
	import com.fl.style.IStyle;
	import com.fl.style.Style;
	import com.fl.style.StyleEvent;
	import com.fl.style.StyleManager;
	import com.fl.utils.FLUtil;
	import com.fl.vo.EdgeMetrics;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class BaseComponent extends BaseSprite implements IStyle {
		public static const INVALIDATE_STYLE:String = "style";
		
		public function BaseComponent() {
			super();
            
            tabEnabled = tabChildren = false;
            
            initStyle();
            initSkin();
            initProperties();
		}
        
        override protected function isRawChildren(v:DisplayObject):Boolean {
            return v != skin && super.isRawChildren(v);
        }
        
        override protected function validate():void {
            super.validate();
            
            if(isInvalid(INVALIDATE_STYLE)) {
                onStyle();
            }
        }
        protected function onStyle():void {
            scheduleRendering(INVALIDATE_STYLE);
        }
        
        protected function initStyle():void {
            _selfStyles.push("paddingLeft", "paddingRight", "paddingTop", "paddingBottom");
            style = new Style();
            var tmpA:Array = FLUtil.getClassHierarchy(this, BaseComponent);
            for(var i:int = tmpA.length - 1; i >= 0; i--) {
                copyStyle(StyleManager.getStyle(tmpA[i]));
            }
        }
        protected function initSkin():void {
            var tmpA:Array = FLUtil.getClassHierarchy(this, BaseComponent);
            for(var i:int = 0; i < tmpA.length; i++) {
                if(SkinManager.hasSkin(tmpA[i])) {
                    skin = SkinManager.getSkin(tmpA[i]);
                    break;
                }
            }
        }
        protected function get skinName():String {
            return FLUtil.getClassName(this);
        }
        
        /**
        * get the initial properties, defined by properties of styles
        **/
        protected function initProperties():void {
            var props:Object = getStyle("properties");
            for(var p:String in props) {
                if(hasOwnProperty(p)) {
                    try { this[p] = props[p]; } catch(err:Error) {}
                }
            }
        }
        
        protected var _styleName:String;
        public function get styleName():String {
            return _styleName;
        }
        public function set styleName(v:String):void {
            if(_styleName != v) {
                _styleName = v;
                resetStyle();
            }
        }
        public function resetStyle(reset:Boolean = false):void {
            if(reset || style == null) {
                style = new Style();
            }
            
            var tmpA:Array = _styleName ? _styleName.split(Style.KEY_SEP) : [];
            for(var i:int = tmpA.length - 1; i >= 0; i--) {
                copyStyle(StyleManager.getStyle(tmpA[i]));
            }
        }
		
        private var _autoSkinSize:Boolean = false;
        /**
         * Gets / sets whether or not this component will be autoSize with skin.
         */
        public function set autoSkinSize(v:Boolean):void {
            if(_autoSkinSize != v) {
                _autoSkinSize = v;
                onSkinResize();
            }
        }
        public function get autoSkinSize():Boolean {
            return _autoSkinSize;
        }
        protected function onSkinResize(env:Event = null):void {
            if(_autoSkinSize) {
                if(_skin is ISkin) {
                    setSize((_skin as ISkin).contentWidth, (_skin as ISkin).contentHeight);
                } else if(_skin is DisplayObject) {
                    setSize(_skin.width, _skin.height);
                }
            }
        }
        
        private var _skinInteractive:Boolean = false;
        /**
         * Gets / sets whether or not this skin is interactivable.
         */
        public function set skinInteractive(v:Boolean):void {
            if(_skinInteractive != v) {
                _skinInteractive = v;
                updateSkinInteractive();
            }
        }
        public function get skinInteractive():Boolean {
            return _skinInteractive;
        }
        protected function updateSkinInteractive():void {
            if(_skin is Sprite) {
                (_skin as Sprite).mouseEnabled = _skinInteractive;
                (_skin as Sprite).mouseChildren = _skinInteractive;
            }
        }
        
		private var _skin:*;
		private var _skinValue:*;
		/***
		 * Sets/gets this component's skin, can be class name/class/instance, should be ISkin or DisplayObject
		 **/
		public function set skin(value:*):void {
			if(_skinValue != value) {
				_skinValue = value;
				if(_skin) {
					if(_skin is ISkin) {
						_skin.owner = null;
					} else if(_skin is DisplayObject) {
						contains(_skin) && removeChild(_skin);
					}
					_skin = null;
				}
				if(value is String) {
					_skin = new (Class(getDefinitionByName(value)))();
				} else if(value is Class) {
					_skin = new (Class(value))();
				} else {
					_skin = value;
				}
				if(_skin is ISkin) {
					ISkin(_skin).owner = this;
                    _skin.addEventListener(Skin.EVENT_SKIN_RESIZE, onSkinResize);
				} else if(_skin is DisplayObject) {
					addChildAt(_skin, 0);
				}
                updateSkinStyle();
                onSkinResize();
                updateSkinInteractive();
			}
		}
		public function get skin():* {
			return _skin;
		}
		protected function updateSkinStyle():void {
            if(_skin is ISkin) {
                ISkin(_skin).style = _style;
            }
        }
        
        private var _preStyle:*;
		private var _style:IStyle;
		public function get style():IStyle {
			return _style;
		}
		public function set style(value:*):void {
            if(_preStyle == value) return;
            _preStyle = value;
            var s:IStyle;
            if(value is IStyle) {
                s = value;
            } else {
                s = _style;
                s ||= new Style();
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
                updateSkinStyle()
                updateStyle();
			}
		}
        protected function styleHandler(env:StyleEvent = null):void {
            var styleP:String = env && env.data ? String(env.data) : null;
            updateStyle(styleP);
        }
        
        protected var _paddings:EdgeMetrics = new EdgeMetrics();
        public function get paddings():EdgeMetrics {
            return _paddings;
        }
		public function updateStyle(styleP:String = null):void {
            if(acceptStyle(styleP)) {
                _paddings.left = getStyle("paddingLeft");
                _paddings.right = getStyle("paddingRight");
                _paddings.top = getStyle("paddingTop");
                _paddings.bottom = getStyle("paddingBottom");
                _paddings.checkNaN();
                
                invalidate(INVALIDATE_STYLE);
            }
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
            _style && _style.copyStyle(style);
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