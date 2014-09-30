package utils
{
    public class ModelLocator
    {
        private static var instance_:ModelLocator;
        
        private var cache_:Object = new Object();
        
        public static function getInstance():ModelLocator {
            if(null == instance_) {
                instance_ = new ModelLocator();
            }
            return instance_;
        }
        
        public function setCache(key:String, value:Object):void {
            cache_[key] = value;
        }
        
        public function getCache(key:String):Object {
            var tmpResult:Object = null;
            if(cache_.hasOwnProperty(key)) {
                tmpResult = cache_[key];
            }
            return tmpResult;
        }
        
        public function removeCache(key:String):void {
            if(cache_.hasOwnProperty(key)) {
                delete cache_[key];
            }
        }
        
        public function hasCache(key:String):Boolean {
            return cache_.hasOwnProperty(key);
        }
        
        public function clean():void {
            cache_ = new Object();
        }
    }
}