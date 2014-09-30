package org.feirlau.loader
{
    import flash.net.URLLoaderDataFormat;
    
    import org.feirlau.core.FLUtils;
    
    public class Resource
    {
        public static const RESOURCE_TYPE_LIBRARY:String = "library";
        public static const RESOURCE_TYPE_STYLE:String = "style";
        public static const RESOURCE_TYPE_LOCAL:String = "local";
        public static const RESOURCE_TYPE_DATA:String = "data";
        public static const RESOURCE_TYPE_ALL:String = "*";
        
        public static const STATUS_INIT:String = "init";
        public static const STATUS_LOADING:String = "loading";
        public static const STATUS_LOADED:String = "loaded";
        public static const STATUS_FAILED:String = "failed";
        
        public function Resource(id_:String, url_:String, name_:String, version_:String = "1", type_:String="library", subtype_:String="xml") {
            id = id_;
            url = url_;
            name = name_;
            type = type_;
            subtype = subtype_;
            version = version_;
        }
        
        public var id:String;
        public var url:String;
        public var name:String;
        public var version:String;
        public var type:String;
        public var subtype:String;
        public var info:*;
        public var status:String = STATUS_INIT;
        public var bytesLoaded:uint = 0;
        public var bytesTotal:uint = 1;
        public var parameters:Object = null;
        public var method:String = "POST";
        
        public function get loaderURL():String {
            return FLUtils.getURL(url, {version: (version ? version : "1")});
        }
        
        public function toString():String {
            return "{id:" + id + ", name:" + name + ", version:" + version + ", type:" + type + ", url:" + url + "}";
        }
        
        public function equal(res:Resource):Boolean {
            var tmpResult:Boolean = false;
            if(res && res.id==id && res.type==type) {
                tmpResult = true;
            }
            return tmpResult;
        }
        
        public function get dataFormat():String {
            var tmpResult:String = URLLoaderDataFormat.BINARY;
            switch(subtype) {
                case "txt":
                case "properties":
                    tmpResult = URLLoaderDataFormat.TEXT;
                    break;
                case URLLoaderDataFormat.VARIABLES:
                    tmpResult = URLLoaderDataFormat.VARIABLES;
                    break;
            }
            return tmpResult;
        }
    }
}