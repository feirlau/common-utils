/**
 * @author risker
 **/
package com.fl.skin {
	import com.fl.component.IImage;
	import com.fl.event.GlobalEvent;
	import com.fl.style.StyleEvent;
	import com.fl.utils.FLLoader;
	import com.fl.utils.ImageCache;
	import com.fl.utils.SkinUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	
	/***
	 * styles {
	 * 	borderSkin: either a string or a Class pointer,
	 *  borderAlpha: 0-1
	 * }
	 */
    public class ImageBorderSkin extends Skin implements IImage {
        override protected function initStyle():void {
			_selfStyles.push("borderSkin", "borderAlpha", "scale9Grid");
            super.initStyle();
        }
        
        /**
         *  Contains <code>true</code> if the ImageBorderSkin instance
         *  contains a border image.
         */
        public function get hasBorderImage():Boolean {
            return _content != null;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Overridden methods
        //
        //--------------------------------------------------------------------------
        
        override protected function onResize():void {
            super.onResize();
            
            layoutImage();
        }
        
        override protected function onProp():void {
            super.onProp();
            
            updateSource();
        }
        protected function updateSource():void {
            // If background image has changed, then load new one. 
            source = getStyle("borderSkin");
        }
        
        private var scaleGrid:Rectangle;
        override protected function styleHandler(env:StyleEvent = null):void {
            super.styleHandler(env);
            var styleProp:* = env.data;
            if(acceptStyle(styleProp)) {
                if(styleProp == null || "scale9Grid" == styleProp) {
                    var tmpA:Array = getStyle("scale9Grid");
                    if(tmpA) {
                        scaleGrid = new Rectangle();
                        scaleGrid.left = tmpA[0];
                        scaleGrid.right = tmpA[1];
                        scaleGrid.top = tmpA[2];
                        scaleGrid.bottom = tmpA[3];
                    } else {
                        scaleGrid = null;
                    }
                }
                invalidate(INVALIDATE_PROP);
            }
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
        
        public function applySource(value:Object):void {
            var tmpObj:DisplayObject;
            var clz:Class;
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
        }
        private function contentLoaderInfo_completeEventHandler(event:Event):void {
            layoutImage();
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
        
        /**
         *  Layout the image.
         */
        public function layoutImage():void {
            if(_content) {
                _content.scaleX = 1;
                _content.scaleY = 1;
            }
            var w:Number;
            var h:Number;
            if(_content is Loader) {
                w = Loader(_content).contentLoaderInfo.width;
                h = Loader(_content).contentLoaderInfo.height;
            } else if(_content) {
                w = _content.width;
                h = _content.height;
            } else {
                w = 0;
                h = 0;
            }
            if(w != _contentWidth || h != _contentHeight) {
                _contentWidth = w;
                _contentHeight = h;
                dispatchEvent(new GlobalEvent(EVENT_SKIN_RESIZE));
            }
			if(_contentWidth == 0 || _contentHeight == 0) return;
			
            if(scaleGrid) {
    			_content.scale9Grid = scaleGrid;
            }
            _content.scaleX = width / _contentWidth;
            _content.scaleY = height / _contentHeight;
			// Adjust alpha to match backgroundAlpha
			if(hasStyle("borderAlpha")) {
                _content.alpha = getStyle("borderAlpha");
			}
            
            if(rawContent is Bitmap) {
                (rawContent as Bitmap).smoothing = true;
            }
        }
    }
}
