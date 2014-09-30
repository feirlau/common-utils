package org.feirlau.core
{
    
    import mx.logging.ILogger;
    import mx.logging.Log;
    
    public class FLUtils
    {
        private static const logger_:ILogger = Log.getLogger("FLUtils");
        
        /**
         * invoke the funcs with the parameter.
         * @param funcs, a Function instance or an array of functions.
         * @param param, the paramter to be passed to the funcs.
         **/
        public static function calls(funcs:*, param:Object):void {
            if(funcs == null) {
                return;
            }
            if(funcs is Function) {
                var item:Function = funcs as Function;
                item.apply(null, [param]);                
            } else if(funcs is Array) {
                for each(var func:* in funcs) {
                    if(func != null) {
                        calls(func, param);
                    }
                }
            } else {
                logger_.error("Your callback is not Function or Array of Function");
            }
        }
        
        /**
         * invoke the funcs with the parameters.
         * @param funcs, a Function instance or an array of functions.
         * @param args, the paramters to be passed to the funcs.
         **/
        public static function apply(funcs:*, ...args):void {
            if(funcs == null) {
                return;
            }
            if(funcs is Function) {
                var item:Function = funcs as Function;
                item.apply(null, args);                
            } else if(funcs is Array) {
                for each(var func:* in funcs) {
                    if(func != null) {
                        apply(func, args);
                    }
                }
            } else {
                logger_.error("Your callback is not Function or Array of Function");
            }
        }
        
        /**
         * Check if the soruce string matched the target string/regexp.
         * @param source, the source string to match.
         * @param target, the target string or regexp to match.
         * @return boolean, true if they are matched fully; elase false.
         **/
        public static function stringFullMatch(source:String, target:String):Boolean {
            var tmpResult:Boolean = false;
            if(source == target) {
                tmpResult = true;
            } else if(source==null || target==null) {
                tmpResult = false;
            } else {
                var tmpReg:RegExp = new RegExp('^'+target+'$', 'm');
                tmpResult = (null!=source.match(tmpReg));
            }
            return tmpResult;
        }
        
        /**
         * Create a formated url with three parts:
         * @param url, the original url string
         * @param parameters, the parameters to be append to the url
         * @param fragments, the fragments to be append to the url
         * @return the formated url.
         **/
        public static function getURL(url:String, parameters:Object = null, fragments:Object = null):String {
            var tmpA:Array = parseURL(url);
            var addressStr:String = tmpA[0];
            var parameterStr:String = tmpA[1];
            var fragementStr:String = tmpA[2];
            for(var key1:Object in parameters) {
                if(parameterStr) parameterStr += "&";
                parameterStr += encodeURIComponent(key1.toString());
                if(parameters[key1] != null) parameterStr += "=" + encodeURIComponent(parameters[key1].toString());
            }
            for(var key2:Object in fragments) {
                if(fragementStr) fragementStr += "&";
                fragementStr += encodeURIComponent(key1.toString());
                if(fragments[key1] != null) fragementStr += "=" + encodeURIComponent(fragments[key1].toString());
            }
            return addressStr + (parameterStr ? "?" + parameterStr : "") + (fragementStr ? "?" + fragementStr : "");
        }
        
        /**
         * http://www.a.b/c?e=f&g#h=i&j
         * Parse the url to three parts: address part, parameter part, fragement part.
         * @return a three elements array, ["http://www.a.b/c", "e=f&g", "h=i&j"]
         **/
        public static function parseURL(url:String):Array {
            var addressStr:String = "";
            var parameterStr:String = "";
            var fragementStr:String = "";
            var i:int = url.indexOf("?");
            var j:int = url.indexOf("#");
            if(i == -1 && j == -1) {
                addressStr = url;
            } else if(i == -1) {
                addressStr = url.substring(0, j);
                fragementStr = url.substr(j + 1);
            } else if(j == -1) {
                addressStr = url.substring(0, i);
                parameterStr = url.substr(i + 1);
            } else if(i < j) {
                addressStr = url.substring(0, i);
                parameterStr = url.substring(i + 1, j);
                fragementStr = url.substr(j + 1);
            } else if(i > j) {
                addressStr = url.substring(0, j);
                fragementStr = url.substr(j + 1);
            }
            return [addressStr, parameterStr, fragementStr];
        }
    }
}