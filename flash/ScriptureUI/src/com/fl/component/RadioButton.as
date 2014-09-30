/**
 * @author risker
 * Oct 24, 2013
 **/
package com.fl.component {
    import com.fl.constants.PositionConstants;
    
    import flash.events.MouseEvent;

    public class RadioButton extends Button {
        public function RadioButton() {
            super();
            
            toggle = true;
            labelPosition = PositionConstants.RIGHT;
            hAlign = PositionConstants.LEFT;
        }
        
        override protected function clickHandler(env:MouseEvent):void {
            selected = true;
        }
    }
}
