package com.fl.extension {
    import com.fl.component.IImage;
    import com.fl.utils.ImageCache;
    
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.ByteArray;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;
    
    /**
    * custom swfloader to load and control the swf dynamicaly 
    ***/
    public class CustomSWFLoader extends Loader implements IImage {
        public static const ENTER_FRAME:String = "CustomSWFLoader_ENTER_FRAME";
        
        public function CustomSWFLoader() {
            super();
        }
        
        public function loadRUL(url:String, context:LoaderContext=null):void {
            loaderContext = context;
            source = url;
        }
        
        override public function load(request:URLRequest, context:LoaderContext=null):void {
            super.load(request, context);
            initLoader();
        }
        
        override public function loadBytes(bytes:ByteArray, context:LoaderContext=null):void {
            super.loadBytes(bytes, context);
            initLoader();
        }
        
        private function initLoader():void {
            contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            contentLoaderInfo.addEventListener(Event.INIT, initHandler);
        }
        
        private function errorHandler(env:IOErrorEvent):void {
            trace(env);
        }
        
        private var contentMC_:MovieClip;
        public function get contentMC():MovieClip {
            return contentMC_;
        }
        
        public var initFunc:Function;
        private function initHandler(env:Event):void {
            if(contentMC_) {
                contentMC_.removeEventListener(Event.ENTER_FRAME, frameHandler);
            }
            contentMC_ = content as MovieClip;
            if(contentMC_) {
                contentMC_.addEventListener(Event.ENTER_FRAME, frameHandler);
            }
            if(isplaying) {
                if(null != frame) {
                    gotoAndPlay(frame, scene);
                } else {
                    play();
                }
            } else {
                if(null != frame) {
                    gotoAndStop(frame, scene);
                } else {
                    stop();
                }
            }
            if(null != initFunc) initFunc(this);
        }
        private function frameHandler(env:Event = null):void {
            dispatchEvent(new Event(ENTER_FRAME));
        }
        
        public function get currentFrame():int {
            return contentMC_ ? contentMC_.currentFrame : 0;
        }
        
        public function get totalFrames():int {
            return contentMC_ ? contentMC_.totalFrames : 0;
        }
        
        public var autoHide:Boolean = true;
        /**ms*/
        public var delayTime:Number = 0;
        private var isplaying:Boolean = false;
        private var timer:uint = 0;
        private function setPlaying(value:Boolean):void {
            isplaying = value;
            if(timer) {
                clearTimeout(timer);
                timer = 0;
            }
            if(isplaying && !contentMC_ && delayTime > 0) {
                timer = setTimeout(delayHandler, delayTime);
            }
            if(autoHide) visible = isplaying;
        }
        private function delayHandler():void {
            timer = 0;
            stop();
            frameHandler();
        }
        
        private var frame:Object;
        private var scene:String;
        public function gotoAndPlay(f:Object, s:String = null):void {
            frame = f;
            scene = s;
            if(contentMC_) {
                contentMC_.gotoAndPlay(frame, scene);
            }
            setPlaying(true);
        }
        public function gotoAndStop(f:Object, s:String = null):void {
            frame = f;
            scene = s;
            if(contentMC_) {
                contentMC_.gotoAndStop(frame, scene);
            }
            setPlaying(false);
        }
        
        
        public function play():void {
            frame = null;
            if(contentMC_) {
                contentMC_.play();
            }
            setPlaying(true);
        }
        public function stop():void {
            frame = null;
            if(contentMC_) {
                contentMC_.stop();
            }
            setPlaying(false);
        }
        
        private var preSource:Object;
        public function set source(value:Object):void {
            if(preSource == value) return;
            preSource = value;
            if(value is String) {
                ImageCache.getInstance().setImageSource(this, value as String);
            } else {
                ImageCache.getInstance().setImageSource(this, null);
                applySource(value);
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
            if(value is ByteArray) {
                loadBytes(value as ByteArray, loaderContext);
            }
        }
    }
}
