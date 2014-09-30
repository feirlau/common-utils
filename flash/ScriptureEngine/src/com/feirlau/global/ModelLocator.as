package com.feirlau.global {
    import mx.logging.ILogger;
    import mx.logging.Log;
    
    public class ModelLocator {
        private static const logger_:ILogger = Log.getLogger("ModelLocator");
        private static var instance_:ModelLocator;
        
        public static const LOGIN_EVENT:String = "LOGIN_EVENT";
        
        public var username:String;
        private var loginOK_:Boolean = false;
        [Bindable]
        public function get loginOK():Boolean {
            return loginOK_;
        }
        public function set loginOK(value:Boolean):void {
            loginOK_ = value;
            var tmpEvent:GlobalEvent = new GlobalEvent(LOGIN_EVENT);
            tmpEvent.data = value;
            EventManager.getInstance().dispatchEvent(tmpEvent);
        }
        
        public static function getInstance():ModelLocator {
            if(instance_ == null) {
                instance_ = new ModelLocator();
            }
            return instance_;
        }
        
        private var sceneWidth_:int = 1000;
        public function get sceneWidth():int {
            return sceneWidth_;
        }
        public function set sceneWidth(v:int):void {
            sceneWidth_ = v;
        }
        
        private var sceneHeight_:int = 580;
        public function get sceneHeight():int {
            return sceneHeight_;
        }
        public function set sceneHeight(v:int):void {
            sceneHeight_ = v;
        }
        
        private var sceneRoot_:String = "scene";
        public function get sceneRoot():String {
            return sceneRoot_;
        }
        public function set sceneRoot(v:String):void {
            sceneRoot_ = v;
        }
    }
}