package org.feirlau.loader
{
    import org.feirlau.core.FLUtils;
    
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.net.URLRequest;
    
    import mx.logging.ILogger;
    import mx.logging.Log;
    
    public class LibraryLoader extends DefaultLoader
    {
        private static const logger_:ILogger = Log.getLogger("LibraryLoader");
        private static var instance_:LibraryLoader;
        public static function getInstance():LibraryLoader {
            if(null == instance_) {
                instance_ = new LibraryLoader();
            }
            return instance_;
        }
        
        override protected function doLoad(resource:Resource, success:Function=null, fail:Function=null):void {
            try {
                var loader:Loader = new Loader();
                var request:URLRequest = new URLRequest(resource.loaderURL);
                request.data = resource.parameters;
                request.method = resource.method;
                var removeListener:Function = function():void {
                    loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, f1);
                    loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, f2);
                    loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, f3);
                };
                var f1:Function = function(event1:Event):void {
                    removeListener();
                    resource.info = loader;
                    FLUtils.calls(success, event1);
                };
                var f2:Function = function(event2:IOErrorEvent):void {
                    removeListener();
                    FLUtils.calls(fail, event2);
                };
                var f3:Function = function(event3:ProgressEvent):void {
                    progressHandler(resource, event3.bytesLoaded, event3.bytesTotal);
                };
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, f1);
                loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, f2);
                loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, f3);
                loader.load(request, loaderContext);
            } catch(err:Error) {
                FLUtils.calls(fail, null);
                logger_.error(err.getStackTrace());
            }
        }
        
        override protected function unloadRes(resource:Resource):void {
            try {
                if(resource && resource.info is Loader) {
                    (resource.info as Loader).unload();
                }
            } catch(err:Error) {
                logger_.error(err.getStackTrace());
            }
        }
    }
}