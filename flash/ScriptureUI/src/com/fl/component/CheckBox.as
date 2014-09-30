/**
 * @author risker
 * Oct 24, 2013
 **/
package com.fl.component {
    import com.fl.constants.PositionConstants;

    public class CheckBox extends Button {
        public function CheckBox() {
            super();
            
            toggle = true;
            labelPosition = PositionConstants.RIGHT;
            hAlign = PositionConstants.LEFT;
        }
    }
}
