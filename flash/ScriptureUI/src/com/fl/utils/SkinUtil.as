/**
 * @author risker
 **/
package com.fl.utils {
	import flash.utils.getQualifiedClassName;

    public class SkinUtil {
        public static var pathFunc:Function;
		public static function contactPath(...args):String {
			var path:String = args.join("/");
			if(null != pathFunc) path = pathFunc(path);
			return path;
		}
    }
}
