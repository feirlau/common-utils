package org.feirlau.loader
{
    import org.feirlau.core.FLUtils;
    
    import flash.events.Event;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.utils.setTimeout;
    
    import mx.collections.ArrayCollection;
    import mx.logging.ILogger;
    import mx.logging.Log;
    
    public class DefaultLoader implements ILoader
    {
        private static const logger_:ILogger = Log.getLogger("DefaultLoader");
        
        protected var cache_:ArrayCollection = new ArrayCollection();
        protected var loaderContext:LoaderContext = null;
        
        public function DefaultLoader()
        {
            loaderContext = new LoaderContext();
            loaderContext.applicationDomain = ApplicationDomain.currentDomain;
        }
        
        private var isLoading_:Boolean = false;
        private var delayTime_:int = 1000;
        public function load(resources:Array, callback:*=null, loaderContext_:LoaderContext=null):void {
            if(isLoading_) {
                laterLoad(resources, callback, loaderContext_);
                return;
            }
            if(loaderContext_) {
                loaderContext = loaderContext_;
            }
            isLoading_ = true;
            var tmpSuccessList:Array = new Array();
            var tmpFailedList:Array = new Array();
            startLoad(resources, tmpSuccessList, tmpFailedList, function(successList:Array, failedList:Array):void {
                isLoading_ = false;
                FLUtils.apply(callback, successList, failedList);
            });
        }
        private function laterLoad(... args):void {
            setTimeout(load, delayTime_, args);
        }
        
        protected function startLoad(resources:Array, successList:Array, failedList:Array, callback:*=null):void {
            if(null == successList) {
                successList = new Array();
            }
            if(null == failedList) {
                failedList = new Array();
            }
            if(null==resources || resources.length==0) {
                FLUtils.apply(callback, successList, failedList);
            } else {
                var tmpResource:Resource = resources.shift() as Resource;
                if(isLoaded(tmpResource) || tmpResource.status==Resource.STATUS_LOADED) {
                    successList.push(tmpResource);
                    startLoad(resources, successList, failedList, callback);
                } else if(tmpResource.status == Resource.STATUS_LOADING) {
                    failedList.push(tmpResource);
                    startLoad(resources, successList, failedList, callback);
                } else {
                    var func1:Function = function(event1:Event=null):void {
                        tmpResource.bytesLoaded = tmpResource.bytesTotal;
                        tmpResource.status = Resource.STATUS_LOADED;
                        successList.push(tmpResource);
                        cache_.addItem(tmpResource);
                        ResourcesManager.getInstance().updateResourceStatus(tmpResource);
                        startLoad(resources, successList, failedList, callback);
                    };
                    var func2:Function = function(event2:Event=null):void {
                        tmpResource.status = Resource.STATUS_FAILED;
                        failedList.push(tmpResource);
                        startLoad(resources, successList, failedList, callback);
                    };
                    tmpResource.status = Resource.STATUS_LOADING;
                    doLoad(tmpResource, func1, func2);
                }
            }
        }
        
        protected function doLoad(resource:Resource, successFunc:Function=null, failedFunc:Function=null):void {
            if(successFunc != null) {
                successFunc();
            }
        }
        
        public function isLoaded(resource:Resource):Boolean {
            var tmpResult:Boolean = false;
            if(resource) {
                for each(var res:Resource in cache_) {
                    if(resource.equal(res)) {
                        tmpResult = true;
                        break;
                    }
                }
            }
            return false;
        }
        
        public function unload(resources:Array):void {
            for each(var resource:Resource in resources) {
                if(resource) {
                    var tmpIndex:int = 0;
                    for each(var res:Resource in cache_) {
                        if(resource.equal(res)) {
                            unloadRes(resource);
                            cache_.removeItemAt(tmpIndex);
                        }
                        tmpIndex++;
                    }
                }
            }
        }
        
        protected function unloadRes(resource:Resource):void {
            
        }
        
        protected function progressHandler(resource:Resource, bytesLoaded:uint, bytesTotal:uint):void {
            resource.bytesLoaded = bytesLoaded;
            resource.bytesTotal = bytesTotal;
            ResourcesManager.getInstance().updateResourceStatus(resource);
        }
        
        public function destory():void {
            unload(cache_.toArray());
        }
    }
}