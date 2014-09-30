package utils.network
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import mx.events.ResourceEvent;
	import mx.events.StyleEvent;
	import mx.resources.ResourceManager;
	import mx.styles.StyleManager;
	
	import utils.common.ProgressUtil;
	
	public class ResourceLoaderUtil
	{
		public function ResourceLoaderUtil() {
		}
        
        public static function loadResourceModule(url:String, resultCallback:Function=null, faultCallback:Function=null):IEventDispatcher {
        	var fault:Function = function(event:Event):void {
        		if(null!=faultCallback) {
        			faultCallback(event);
        		}
        		faultDefault(event);
        	}
        	var result:Function = function(event:Event):void {
	        	if(null!=resultCallback) {
	                resultCallback(event);
	            }
        		resultDefault(event);
        	}
        	var event:IEventDispatcher = ResourceManager.getInstance().loadResourceModule(url);
        	event.addEventListener(ResourceEvent.COMPLETE, result);
        	event.addEventListener(ResourceEvent.ERROR, fault);
        	event.addEventListener(ResourceEvent.PROGRESS, progressDefault);
        	ProgressUtil.addProgress(event, url);
        	trace(event);
        	return event;
        }
        
        public static function loadStyleModule(url:String, resultCallback:Function=null, faultCallback:Function=null):IEventDispatcher {
        	var fault:Function = function(event:Event):void {
                if(null!=faultCallback) {
                    faultCallback(event);
                }
                faultDefault(event);
            }
            var result:Function = function(event:Event):void {
                if(null!=resultCallback) {
                    resultCallback(event);
                }
                resultDefault(event);
            }
        	var event:IEventDispatcher = StyleManager.loadStyleDeclarations(url);
            event.addEventListener(StyleEvent.COMPLETE, result);
            event.addEventListener(StyleEvent.ERROR, fault);
            event.addEventListener(StyleEvent.PROGRESS, progressDefault);
            ProgressUtil.addProgress(event, url);
            trace(event);
            return event;
        }
        
        public static function loadDisplayModule(url:String, resultCallback:Function=null, faultCallback:Function=null, parameter:Object=null, method:String="POST"):Loader {
        	var fault:Function = function(event:Event):void {
                if(null!=faultCallback) {
                    faultCallback(event);
                }
                faultDefault(event);
            }
            var result:Function = function(event:Event):void {
                if(null!=resultCallback) {
                    resultCallback(event);
                }
                resultDefault(event);
            }
        	var request:URLRequest = new URLRequest(url);
        	request.method = URLRequestMethod.POST;
        	request.data = parameter;
        	var loader:Loader = new Loader();
        	loader.contentLoaderInfo.addEventListener(Event.COMPLETE, result);
        	loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, fault);
        	loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressDefault);
        	loader.load(request);
        	ProgressUtil.addProgress(loader.contentLoaderInfo, url);
        	trace(loader);
        	return loader;
        	
        }
        
        public static function loadDataModule(url:String, resultCallback:Function=null, faultCallback:Function=null, parameter:Object=null, method:String="POST"):URLLoader {
        	var fault:Function = function(event:Event):void {
                if(null!=faultCallback) {
                    faultCallback(event);
                }
                faultDefault(event);
            }
            var result:Function = function(event:Event):void {
                if(null!=resultCallback) {
                    resultCallback(event);
                }
                resultDefault(event);
            }
        	var request:URLRequest = new URLRequest(url);
        	request.method = URLRequestMethod.POST;
            request.data = parameter;
        	var loader:URLLoader = new URLLoader(request);
        	loader.addEventListener(Event.COMPLETE, result);
            loader.addEventListener(IOErrorEvent.IO_ERROR, fault);
            loader.addEventListener(ProgressEvent.PROGRESS, progressDefault);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fault);
            loader.load(request);
            ProgressUtil.addProgress(loader, url);
            trace(loader);
            return loader;
        }
        
        public static function resultDefault(event:Event):void {
        	trace("ResourceLoader.resultDefault:[type]" + event.type + " [event]" + event.toString());
        	ProgressUtil.setProgress(event.target, 2);
        }
        public static function faultDefault(event:Event):void {
        	trace("ResourceLoader.faultDefault:[type]" + event.type + " [event]" + event.toString());
        	ProgressUtil.setProgress(event.target, -1);
        }
        public static function progressDefault(event:ProgressEvent):void {
        	trace("ResourceLoader.progressDefault:[type]" + event.type + " [event]" + event.toString());
        	ProgressUtil.setProgress(event.target, 1, event.bytesLoaded, event.bytesTotal);
        }
        
	}
}