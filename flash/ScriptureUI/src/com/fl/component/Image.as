/**
 * @author risker
 **/
package com.fl.component {
    import com.fl.event.GlobalEvent;
    import com.fl.skin.ISkin;
    import com.fl.style.StyleEvent;
    import com.fl.utils.FLLoader;
    import com.fl.utils.ImageCache;
    import com.fl.utils.LogUtil;
    import com.fl.utils.SkinUtil;
    
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.geom.Rectangle;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.utils.ByteArray;
    import flash.utils.getDefinitionByName;

    public class Image extends BaseComponent implements IImage {
        public static const EVENT_CONTENT_UPDATE:String = "EVENT_CONTENT_UPDATE";
        
        override protected function initStyle():void {
            _selfStyles.push("brokenImageSkin", "waitImageSkin");
            super.initStyle();
        }
        
		private var preSource:Object;
		public function set source(value:Object):void {
			if(preSource == value) return;
			preSource = value;
            // The code below looks a lot like Loader.loadContent().
            var tmpObj:*;
            var cls:Class;
            var isCache:Boolean;
            // The "as" operator checks to see if newStyle
            // can be coerced to a Class.
            if(preSource && preSource as Class) {
                // Load background image given a class pointer
                cls = Class(preSource);
                tmpObj = new cls();
            } else if(preSource) {
                try {
                    cls = Class(getDefinitionByName(String(preSource)));
                } catch(e:Error) {
                    // ignore
                }
                
                if(cls) {
                    tmpObj = new cls();
                } else {
                    // This code is a subset of Loader.loadContent().
                    // Load background image from external URL.
                    ImageCache.getInstance().setImageSource(this, SkinUtil.contactPath(String(preSource)));
                    isCache = true;
                }
            }
            if(!isCache) {
                ImageCache.getInstance().setImageSource(this, null);
                applySource(tmpObj);
            }
		}
        public function get source():Object {
            return preSource;
        }
        
        private var _loaderContext:LoaderContext;
        public function set loaderContext(value:LoaderContext):void {
            _loaderContext = value;
        }
        public function get loaderContext():LoaderContext {
            return null;
        }
        
		private var _preCachedSource:String;
		public function get preCachedSource():String {
			return _preCachedSource;
		}
		public function set preCachedSource(value:String):void {
			_preCachedSource = value;
		}
        
		private var _smoothBitmapContent:Boolean = true;
		public function get smoothBitmapContent():Boolean {
			return _smoothBitmapContent;
		}
		public function set smoothBitmapContent(value:Boolean):void {
			if(_smoothBitmapContent != value) {
    			_smoothBitmapContent = value;
                invalidate(INVALIDATE_PROP);
            }
		}
		
		private var sourceSet:Boolean;
		private var settingBrokenImage:Boolean;
		public function applySource(value:Object):void {
			settingBrokenImage = (value == brokenImageSkin);
			sourceSet = !settingBrokenImage;
            var tmpObj:DisplayObject;
			var clz:Class;
			if(value is String) {
				try {
					value = Class(getDefinitionByName(String(value)));
				} catch(e:Error) {
					// ignore
				}
			}
			if(value is DisplayObject) {
                tmpObj = value as DisplayObject;
			} else if(value is Class) {
				clz = Class(value);
				value = new clz();
			} else if(value is ByteArray) {
				// This code is a subset of Loader.loadContent().
				
				// Load background image from external URL.
                var tmpLoader:FLLoader = new FLLoader();
                tmpLoader.startLoadBytes(value as ByteArray, loaderContext, contentLoaderInfo_completeEventHandler);
                tmpObj = tmpLoader;
            } else {
                tmpObj = null;
            }
            initImage(tmpObj);
            layoutImage();
            invalidate(INVALIDATE_PROP);
		}
        private function contentLoaderInfo_completeEventHandler(event:Event):void {
            layoutImage();
            invalidate(INVALIDATE_PROP);
            dispatchEvent(event);
            dispatchEvent(new GlobalEvent(Image.EVENT_CONTENT_UPDATE));
        }
		
		protected var _contentWidth:Number;
        public function get contentWidth():Number {
            return _contentWidth;
        }
        protected var _contentHeight:Number;
        public function get contentHeight():Number {
            return _contentHeight;
        }
        protected var _content:DisplayObject;
        public function get content():DisplayObject {
            return _content;
        }
        public function get rawContent():DisplayObject {
            return _content is Loader ? (_content as Loader).content : _content;
        }
        
        protected function initImage(image:DisplayObject):void {
            if(_content != image) {
                removeImage();
                
                _content = image;
                
                if(_content) addChild(_content);
                
                if(_content is ISkin) {
                    ISkin(_content).style = style;
                }
                
                dispatchEvent(new GlobalEvent(Image.EVENT_CONTENT_UPDATE));
            }
        }
        public function removeImage():void {
            if (_content) {
                removeChild(_content);
                if (_content is ISkin) {
                    ISkin(_content).style = null;
                }
                if(_content is FLLoader) {
                    FLLoader(_content).removeHandlers();
                }
                _content = null;
            }
            ImageCache.getInstance().setImageSource(this, null);
        }
        
        protected var _autoImgSize:Boolean = false;
        /**use the content size or not*/
        public function get autoImgSize():Boolean {
            return _autoImgSize;
        }
        public function set autoImgSize(value:Boolean):void {
            if(_autoImgSize != value) {
                _autoImgSize = value;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        
        protected var _keepSize:Boolean = false;
        /**change the content size or not*/
        public function get keepSize():Boolean {
            return _keepSize;
        }
        public function set keepSize(value:Boolean):void {
            if(_keepSize != value) {
                _keepSize = value;
                invalidate(INVALIDATE_RESIZE);
            }
        }

        /**
         *  Layout the image.
         */
        public function layoutImage():void {
            if(content) {
                content.scaleX = 1;
                content.scaleY = 1;
            }
            
            if(_content is Loader) {
                _contentWidth = Loader(_content).contentLoaderInfo.width;
                _contentHeight = Loader(_content).contentLoaderInfo.height;
            } else if(_content) {
                _contentWidth = _content.width;
                _contentHeight = _content.height;
            } else {
                _contentWidth = 0;
                _contentHeight = 0;
            }
            
            if(autoImgSize) {
                setSize(_contentWidth, _contentHeight);
            } else if(keepSize) {
            } else if(_content) {
                content.scaleX = _contentWidth == 0 ? 0 : width / _contentWidth;
                content.scaleY = _contentHeight == 0 ? 0 : height / _contentHeight;
            }
        }
        
        override protected function onResize():void {
            super.onResize();
            
            layoutImage();
        }
        
        override protected function render():void {
            super.render();
            
            if(shouldRender(INVALIDATE_PROP)) {
                if(rawContent is Bitmap) {
                    (rawContent as Bitmap).smoothing = _smoothBitmapContent;
                }
            }
        }
        protected var brokenImageSkin:*;
        protected var waitImageSkin:*;
		override protected function styleHandler(env:StyleEvent=null):void {
			super.styleHandler(env);
			var styleProp:* = env.data;
			if(acceptStyle(styleProp)) {
				if(styleProp == null || styleProp == "brokenImageSkin") {
					brokenImageSkin = getStyle("brokenImageSkin");
				}
				if(styleProp == null || styleProp == "waitImageSkin") {
					waitImageSkin = getStyle("waitImageSkin");
					!sourceSet && waitImageSkin && applySource(waitImageSkin);
				}
			}
		}
    }
}
