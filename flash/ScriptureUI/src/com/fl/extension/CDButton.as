package com.fl.extension {
    import com.fl.component.Button;
    
    import flash.events.MouseEvent;
    public class CDButton extends Button {
        
        public function CDButton(cd:int = 1000) {
            super();
            cdTime_ = cd;
        }
        
        private var cdMasker:CDMasker;
        override protected function createChildren():void {
            super.createChildren();
            
            cdMasker = new CDMasker(width, height, cdTime_);
            cdMasker.visible = cdVisible_;
            addChild(cdMasker);
        }
        
        override protected function onResize():void {
            super.onResize();
            
            updateCdMask();
        }
        
        public var preventOnCd:Boolean = true;
        override protected function clickHandler(event:MouseEvent):void {
            super.clickHandler(event);
            if(isCd) {
                if(enabled) {
                    if(preventOnCd) {
                        event.stopImmediatePropagation();
                    }
                } else {
                    stopCd();
                }
            } else if(enabled) {
                curTime = cdTime_;
                startCd();
            }
        }
        
        private var cdVisible_:Boolean = true;
        public function get cdVisible():Boolean {
            return cdVisible_;
        }
        public function set cdVisible(value:Boolean):void {
            if(cdVisible_ != value) {
                cdVisible_ = value;
                cdMasker && (cdMasker.visible = cdVisible_);
            }
        }
        
        private var cdTime_:int = 1000;
        public function get cdTime():int {
            return cdTime_;
        }
        public function set cdTime(value:int):void {
            if(cdTime_ != value) {
                cdTime_ = value;
                updateCdMask();
            }
        }
        private function updateCdMask():void {
            var tmpB:Boolean = isCd;
            if(cdMasker) {
                cdMasker.stop();
                removeChild(cdMasker);
            }
            cdMasker = new CDMasker(width, height, cdTime_);
            cdMasker.visible = cdVisible_;
            addChild(cdMasker);
            tmpB && startCd();
        }
        
        private var curTime_:int = 1000;
        public function get curTime():int {
            return cdMasker ? cdMasker.curTime : 0;
        }
        public function set curTime(value:int):void {
            if(curTime_ != value) {
                curTime_ = value;
                if(isCd) {
                    cdMasker.updateCd(curTime_);
                }
            }
        }
        
        public function get isCd():Boolean {
            return cdMasker && cdMasker.isRunning;
        }
        
        public function restartCd():void {
            stopCd();
            startCd();
        }
        
        public function startCd():void {
            cdTime_ > 0 && curTime_ > 0 && cdMasker && !cdMasker.isRunning && cdMasker.start(curTime_);
        }
        public function stopCd():void {
            isCd && cdMasker.stop();
        }
    }
}
