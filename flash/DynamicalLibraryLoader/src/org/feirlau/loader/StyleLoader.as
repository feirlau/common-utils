package org.feirlau.loader
{
    import org.feirlau.core.FLUtils;
    
    import flash.events.IEventDispatcher;
    import flash.events.ProgressEvent;
    
    import mx.events.StyleEvent;
    import mx.logging.ILogger;
    import mx.logging.Log;
    import mx.styles.StyleManager;
    
    public class StyleLoader extends DefaultLoader
    {
        private static const logger_:ILogger = Log.getLogger("StyleLoader");
        private static var instance_:StyleLoader;
        public static function getInstance():StyleLoader {
            if(null == instance_) {
                instance_ = new StyleLoader();
            }
            return instance_;
        }
        
        override protected function doLoad(resource:Resource, success:Function=null, fail:Function=null):void {
            try {
                var loader:IEventDispatcher = StyleManager.loadStyleDeclarations(resource.loaderURL);
                var removeListener:Function = function():void {
                    loader.removeEventListener(StyleEvent.COMPLETE, f1);
                    loader.removeEventListener(StyleEvent.ERROR, f2);
                    loader.removeEventListener(ProgressEvent.PROGRESS, f3);
                };
                var f1:Function = function(event1:StyleEvent):void {
                    removeListener();
                    FLUtils.calls(success, event1);
                };
                var f2:Function = function(event2:StyleEvent):void {
                    removeListener();
                    loader.addEventListener(StyleEvent.ERROR, fakeErrorHandler, false, 0, true);
                    FLUtils.calls(fail, event2);
                };
                var f3:Function = function(event3:ProgressEvent):void {
                    progressHandler(resource, event3.bytesLoaded, event3.bytesTotal);
                };
                loader.addEventListener(StyleEvent.COMPLETE, f1);
                loader.addEventListener(StyleEvent.ERROR, f2);
                loader.addEventListener(ProgressEvent.PROGRESS, f3);
            } catch(err:Error) {
                FLUtils.calls(fail, null);
                logger_.error(err.getStackTrace());
            }
        }
        
        /**
        * Should add this handler to handle the load error exception(Error #2035) from StyleManagerImpl.
        * Maybe a bug of flex sdk.
        * Without this handler, there will be as exception if load style when jboss shutdown or someother network problems.
        */
        private function fakeErrorHandler(err:StyleEvent):void {
            logger_.error("Used to handler the load error from StyleManagerImpl: " + err.errorText);
        }
        
        override protected function unloadRes(resource:Resource):void {
            try {
                if(resource && resource.loaderURL) {
                    StyleManager.unloadStyleDeclarations(resource.loaderURL);
                }
            } catch(err:Error) {
                logger_.error(err.getStackTrace());
            }
        }
    }
}