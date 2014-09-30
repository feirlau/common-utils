package com.fl.extension {
    import com.fl.component.Text;
    import com.fl.utils.FLUtil;
    
    import flash.events.TextEvent;
    import flash.utils.ByteArray;
    
    public class FilterText extends Text {
        public function FilterText() {
            super();
            
            editable = true;
            _tf.addEventListener(TextEvent.TEXT_INPUT, inputHandler);
        }
        
        protected function inputHandler(env:TextEvent):void {
            if(!acceptText(env.text)) {
                env.preventDefault();
            }
        }
        
        private function acceptText(value:String):Boolean {
            return !(isMaxShowWidth(value) || isMaxBytes(value) || filter(value));
        }
        
        public var filterFunc:Function;
        private function filter(value:String):Boolean {
            var tmpResult:Boolean = false;
            if(null != filterFunc) {
                tmpResult = filterFunc(value);
            } else {
                tmpResult = defaultFilter(value);
            }
            return tmpResult;
        }
        
        private var includeStr_:String;
        public function get includeStr():String {
            return includeStr_;
        }
        public function set includeStr(value:String):void {
            if(includeStr_ != value) {
                includeStr_ = value;
                includeReg = new RegExp(includeStr);
            }
        }

        private var excludeStr_:String;
        public function get excludeStr():String {
            return excludeStr_;
        }
        public function set excludeStr(value:String):void {
            if(excludeStr_ != value) {
                excludeStr_ = value;
                excludeReg = new RegExp(excludeStr_);
            }
        }

        private var includeReg:RegExp;
        private var excludeReg:RegExp;
        private function defaultFilter(value:String):Boolean {
            var tmpResult:Boolean = false;
            if(value && includeReg) {
                tmpResult = (null == value.match(includeReg));
            }
            if(!tmpResult && value && excludeReg) {
                tmpResult = (null != value.match(excludeReg));
            }
            return tmpResult;
        }
        
        public var maxBytes:int = -1;
        private function isMaxBytes(value:String):Boolean {
            var tmpResult:Boolean = false;
            if(maxBytes >= 0 && text != null && value) {
                var tmpBytes:ByteArray = new ByteArray();
                tmpBytes.writeUTFBytes(text);
                tmpBytes.writeUTFBytes(value);
                if(tmpBytes.length > maxBytes) {
                    tmpResult = true;
                }
            }
            return tmpResult;
        }
        
        public var maxShowWidth:int = -1;
        private function isMaxShowWidth(value:String):Boolean {
            var tmpResult:Boolean = false;
            if(maxShowWidth >= 0 && text != null && value) {
                if(FLUtil.getWordWidth(text + value) > maxShowWidth) {
                    tmpResult = true;
                }
            }
            return tmpResult;
        }
    }
    
}
