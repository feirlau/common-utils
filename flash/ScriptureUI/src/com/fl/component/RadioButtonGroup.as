/**
 * @author risker
 * Oct 24, 2013
 **/
package com.fl.component {
    import com.fl.event.GlobalEvent;
    
    import flash.events.EventDispatcher;

    public class RadioButtonGroup extends EventDispatcher {
        private var items:Array = [];
        public function addItem(rb:RadioButton):RadioButton {
            var i:int = items.indexOf(rb);
            if(i == -1) {
                items.push(rb);
                rb.addEventListener(Button.EVENT_SELECT_CHANGED, selectHandler);
            }
            if(null == selectedItem && rb.selected) {
                selectedItem = rb;
            }
            return rb;
        }
        private function selectHandler(env:GlobalEvent):void {
            var rb:RadioButton = env.currentTarget as RadioButton;
            if(rb.selected) {
                selectedItem = rb;
            }
        }
        
        public function removeItem(rb:RadioButton):RadioButton {
            var i:int = items.indexOf(rb);
            if(i != -1) {
                items.splice(i, 1);
                rb.removeEventListener(Button.EVENT_SELECT_CHANGED, selectHandler);
            }
            if(rb == _selectedItem) {
                selectedItem = null;
            }
            return rb;
        }
        
        public function clear():void {
            for each(var item:RadioButton in items) {
                removeItem(item);
            }
        }
        
        private var _selectedItem:RadioButton;
        public function get selectedItem():RadioButton {
            return _selectedItem;
        }
        public function set selectedItem(rb:RadioButton):void {
            var i:int = items.indexOf(rb);
            if(i != -1 && _selectedItem != rb) {
                if(_selectedItem) {
                    _selectedItem.selected = false;
                }
                _selectedItem = rb;
                if(_selectedItem) {
                    _selectedItem.selected = true;
                }
                dispatchEvent(new GlobalEvent(Button.EVENT_SELECT_CHANGED));
            }
        }
    }
}
