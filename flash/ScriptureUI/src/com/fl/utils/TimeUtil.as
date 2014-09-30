/**
 * @author risker
 * Dec 31, 2013
 **/
package com.fl.utils {

    public class TimeUtil {
        public static const MIN_SEC:uint = 60;
        public static const HOUR_SEC:uint = 3600;
        public static const DAY_SEC:uint = 24 * 3600;
        public static const WEEK_SEC:uint = 7 * 24 * 3600;

        public static var STR_DAY:String = "D";
        public static function getCountDown(ms:uint, showDay:Boolean = false):String {
            var tmpS:String = "";
            ms = ms / 1000;

            if(showDay) {
                var days:uint = ms / DAY_SEC;
                ms = ms % DAY_SEC;
                
                if(days > 0) { //show days only
                    tmpS = StringUtil.substitute("{0}{1}", ms > 60 ? days + 1 : days, STR_DAY);
                    return tmpS;
                }
            }
            var hours:uint = ms / HOUR_SEC;
            ms = ms % HOUR_SEC;
            tmpS += hours < 10 ? "0" + hours : hours;
            tmpS += ":";

            var minutes:uint = ms / MIN_SEC;
            ms = ms % MIN_SEC;
            tmpS += minutes < 10 ? "0" + minutes : minutes;
            tmpS += ":";

            var seconds:uint = ms;
            tmpS += seconds < 10 ? "0" + seconds : seconds;

            return tmpS;
        }
    }
}
