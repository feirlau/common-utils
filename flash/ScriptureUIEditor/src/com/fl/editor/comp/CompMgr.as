/**
 * @author risker
 * Dec 26, 2013
 **/
package com.fl.editor.comp {
    import com.fl.event.EventManager;
    import com.fl.event.GlobalEvent;
    
    import flash.utils.Dictionary;

    public class CompMgr {
        public static var EVENT_COMPCONFIG_UPDATE:String = "EVENT_COMPCONFIG_UPDATE";
        private static var _instance:CompMgr;
        public static function getInstance():CompMgr {
            _instance ||= new CompMgr();
            return _instance;
        }
        
        public var comps:Dictionary = new Dictionary();
        public function addComp(ci:CompItem):void {
            comps[ci.name] = ci;
            EventManager.getInstance().dispatchEvent(new GlobalEvent(EVENT_COMPCONFIG_UPDATE));
        }
        public function removeComp(ci:*):CompItem {
            if(ci is CompItem) ci = ci.name;
            var res:CompItem = comps[ci];
            delete comps[ci];
            EventManager.getInstance().dispatchEvent(new GlobalEvent(EVENT_COMPCONFIG_UPDATE));
            return res;
        }
    }
}
