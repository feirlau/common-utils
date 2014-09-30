/* Copyright (c) 2010-2011 FeirLau.  All rights reserved. */
package utils.common
{
    import flash.external.ExternalInterface;
    
    import mx.logging.ILogger;
    import mx.logging.Log;
    
    /**
     * Set/Get cookies from browser using javascript.
     * The cookie value is encode by encodeURIComponent, and decode by decodeURIComponent.
     * Otherwise, some value will break the feature, such as value contains(";", "=") or other charaters.
     **/
    public class CookieUtil
    {
        public function CookieUtil()
        {
        }
        private static const COOKIE_UTIL_INIT:String = "function(){" + 
            "if (window.FlexCookieUtil) return;" + 
            "var FlexCookieUtil = window.FlexCookieUtil = {};" + 
            "FlexCookieUtil.set = function(name, value, expiredays){ var exdate = new Date(); exdate.setDate(exdate.getDate() + expiredays); document.cookie = name + '=' + encodeURIComponent(value) + ((expiredays == null)?'':';expires=' + exdate.toUTCString()); };" + 
            "FlexCookieUtil.get = function(name){ var all_cookies = document.cookie.split(';'); var temp_cookie = ''; var cookie_name = ''; var cookie_value = '';" + 
                "for(i = 0; i < all_cookies.length; i++){ temp_cookie = all_cookies[i].split( '=' ); cookie_name = temp_cookie[0].replace(/^\\s+|\\s+$/g, ''); if(cookie_name == name){ if(temp_cookie.length > 1){ cookie_value = decodeURIComponent(temp_cookie[1].replace(/^\\s+|\\s+$/g, ''));} break;} temp_cookie = null; cookie_name = '';} return cookie_value;};" + 
            "FlexCookieUtil.remove = function(name){ if(FlexCookieUtil.get(name)){ document.cookie = name+'='+';expires=Thu, 01-Jan-1970 00:00:01 GMT';}};" + 
        "}";
        
        private static const SET_COOKIE:String = "FlexCookieUtil.set";
        private static const REMOVE_COOKIE:String = "FlexCookieUtil.remove";
        private static const GET_COOKIE:String = "FlexCookieUtil.get";
        
        private static const logger_:ILogger = Log.getLogger("CookieUtil");
        
        private static var inited_:Boolean = false;
        /**
        * Should init in the right context, otherwise the domain or path of the cookie won't be consistent with java side, and can't get the right value.
        **/
        public static function init():void {
            if(!inited_) {
                if(available) ExternalInterface.call(COOKIE_UTIL_INIT);
                inited_ = true;
            }
        }
                
        /**
         * set cookie
         * @param name
         * @param value
         * @param expiredays
         **/
        public static function setCookie(name:String, value:String, expiredays:int):void {
            if(available) {
                init();
                ExternalInterface.call(SET_COOKIE, name, value, expiredays);
            }
        }
        
        /**
         * remove cookie value
         * @param name
         */
        public static function removeCookie(name:String):void {
            if(available) {
                init();
                ExternalInterface.call(REMOVE_COOKIE, name);
            }
        }
        
        /**
         * get cookie value
         * @param name
         * @return value
         **/
        public static function getCookie(name:String):String {
            var tmpResult:String = "";
            if(available) {
                init();
                tmpResult = ExternalInterface.call(GET_COOKIE, name);
            }
            return tmpResult;
        }

        /**
         *  @return Boolean, true if FlexCookieUtil is available.
         **/
        public static function get available():Boolean {
            var tmpResult:Boolean = false;
            if (ExternalInterface.available) {
                try {
                    tmpResult = Boolean(ExternalInterface.call("function(){return true;}"));
                } catch(e:Error) {
                    logger_.debug(e.getStackTrace());
                    logger_.error("No external interface for FlexCookieUtil.");
                }
            }
            return tmpResult;
        }

    }
}
