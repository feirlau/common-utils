/**
 * @author risker
 * Dec 30, 2013
 **/
package com.fl.demo {
    import com.fl.component.Button;

    public class Custom extends Button {
        public function Custom() {
            super();
        }
        
        public function parseComp(xml:XML):void {
            trace(xml);
        }
    }
}
