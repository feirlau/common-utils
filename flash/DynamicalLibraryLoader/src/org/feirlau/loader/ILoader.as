package org.feirlau.loader
{
    import flash.system.LoaderContext;
    
    public interface ILoader
    {
        /***
        * @param resource, an array of Resources(@link org.feirlau.Resource)  to be loaded
        * @param callback, can be a function or function array, as callback after finishing loading libraries. 
        *    the parameters of callback function are callback(successList, failedList).
        * @param loaderContext_, loader context
        */ 
        function load(resources:Array, callback:* = null, loaderContext_:LoaderContext=null):void;
        
        function isLoaded(resource:Resource):Boolean;
        
        function unload(resource:Array):void;
        
        function destory():void;
    }
}