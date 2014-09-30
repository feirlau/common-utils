package org.feirlau.loader
{
    import org.feirlau.core.FLUtils;
    
    import flash.events.IEventDispatcher;
    import flash.events.ProgressEvent;
    
    import mx.events.ResourceEvent;
    import mx.logging.ILogger;
    import mx.logging.Log;
    import mx.resources.ResourceManager;
    
    public class LocalLoader extends DefaultLoader
    {
        private static const logger_:ILogger = Log.getLogger("LocalLoader");
        private static var instance_:LocalLoader;
        public static function getInstance():LocalLoader {
            if(null == instance_) {
                instance_ = new LocalLoader();
            }
            return instance_;
        }
        
        override protected function doLoad(resource:Resource, success:Function=null, fail:Function=null):void {
            try {
                var loader:IEventDispatcher = ResourceManager.getInstance().loadResourceModule(resource.loaderURL);
                var removeListener:Function = function():void {
                    loader.removeEventListener(ResourceEvent.COMPLETE, f1);
                    loader.removeEventListener(ResourceEvent.ERROR, f2);
                    loader.removeEventListener(ProgressEvent.PROGRESS, f3);
                };
                var f1:Function = function(event1:ResourceEvent):void {
                    removeListener();
                    FLUtils.calls(success, event1);
                };
                var f2:Function = function(event2:ResourceEvent):void {
                    removeListener();
                    FLUtils.calls(fail, event2);
                };
                var f3:Function = function(event3:ProgressEvent):void {
                    progressHandler(resource, event3.bytesLoaded, event3.bytesTotal);
                };
                loader.addEventListener(ResourceEvent.COMPLETE, f1);
                loader.addEventListener(ResourceEvent.ERROR, f2);
                loader.addEventListener(ProgressEvent.PROGRESS, f3);
            } catch(err:Error) {
                FLUtils.calls(fail, null);
                logger_.error(err.getStackTrace());
            }
        }
        
        override protected function unloadRes(resource:Resource):void {
            try {
                if(resource && resource.loaderURL) {
                    ResourceManager.getInstance().unloadResourceModule(resource.loaderURL);
                }
            } catch(err:Error) {
                logger_.error(err.getStackTrace());
            }
        }
    }
}