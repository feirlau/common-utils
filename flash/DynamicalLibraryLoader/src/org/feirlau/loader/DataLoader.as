package org.feirlau.loader
{
    import org.feirlau.core.FLUtils;
    
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    
    import mx.logging.ILogger;
    import mx.logging.Log;
    
    public class DataLoader extends DefaultLoader
    {
        private static const logger_:ILogger = Log.getLogger("DataLoader");
        private static var instance_:DataLoader;
        public static function getInstance():DataLoader {
            if(null == instance_) {
                instance_ = new DataLoader();
            }
            return instance_;
        }
        
        override protected function doLoad(resource:Resource, success:Function=null, fail:Function=null):void {
            try {
                var loader:URLLoader = new URLLoader();
                loader.dataFormat = resource.dataFormat;
                var request:URLRequest = new URLRequest(resource.loaderURL);
                request.data = resource.parameters;
                request.method = resource.method;
                var removeListener:Function = function():void {
                    loader.removeEventListener(Event.COMPLETE, f1);
                    loader.removeEventListener(IOErrorEvent.IO_ERROR, f2);
                    loader.removeEventListener(ProgressEvent.PROGRESS, f3);
                    loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, f4);
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
                var f4:Function = function(event4:SecurityErrorEvent):void {
                    removeListener();
                    FLUtils.calls(fail, event4);
                };
                loader.addEventListener(Event.COMPLETE, f1);
                loader.addEventListener(IOErrorEvent.IO_ERROR, f2);
                loader.addEventListener(ProgressEvent.PROGRESS, f3);
                loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, f4);
                loader.load(request);
            } catch(err:Error) {
                FLUtils.calls(fail, null);
                logger_.error(err.getStackTrace());
            }
        }
    }
}