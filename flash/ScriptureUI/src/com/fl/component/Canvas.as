package com.fl.component {
    import flash.display.DisplayObject;
    /**
    * container with scroll
    **/
    public class Canvas extends ScrollBase {
        public function Canvas() {
            super();
            
            rawChangeEnable = true;
        }
        
        override public function updateRawSize(fireEvent:Boolean = false):void {
            super.updateRawSize(fireEvent);
            
            if(fireEvent) {
                updateContentSize();
            }
        }
        
        override public function get contentWidth():Number {
            return rawWidth;
        }
        override public function get contentHeight():Number {
            return rawHeight;
        }
    }
}
