/**
 * @author risker
 **/
package com.fl.utils {
	public class LogUtil {
		/**
		 *  Designates events that are very
		 *  harmful and will eventually lead to application failure.
		 */
		public static const FATAL:int = 1000;
		
		/**
		 *  Designates error events that might
		 *  still allow the application to continue running.
		 */
		public static const ERROR:int = 8;
		
		/**
		 *  Designates events that could be
		 *  harmful to the application operation.
		 */
		public static const WARN:int = 6;
		
		/**
		 *  Designates informational messages that
		 *  highlight the progress of the application at coarse-grained level.
		 */
		public static const INFO:int = 4;
		
		/**
		 *  Designates informational level
		 *  messages that are fine grained and most helpful when debugging an
		 *  application.
		 */
		public static const DEBUG:int = 2;
		
		/**
		 *  Tells a target to process all messages.
		 */
		public static const ALL:int = 0;
		
	    public static var level:int = 4;
		public static function addLog(clzOrIns:*, messages:*, lev:int = 4):void {
			if(lev >= level) {
				var tmpA:Array = [];
				if(clzOrIns) tmpA.push(FLUtil.getClassName(clzOrIns));
                tmpA.push("[LOG_" + lev + "]");
                tmpA.push(new Date().toLocaleString());
                tmpA = tmpA.concat(messages);
				trace(tmpA.join(" - "));
			}
		}
	}
}
