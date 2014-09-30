/**
 * FlexSpy 1.1
 * 
 * <p>Code released under WTFPL [http://sam.zoy.org/wtfpl/]</p>
 * @author Arnaud Pichery [http://coderpeon.ovh.org]
 */
package com.fl.keyboard {
    import flash.events.Event;
    import flash.events.EventPhase;
    import flash.events.KeyboardEvent;
    
    /**
     * Represents a sequence of keys (ex: Ctrl-Alt-F1, Alt-D, etc.)
     */
    public class KeySequence {
        private var _tipStr:String = "";
        private var _keyCode:int;
        private var _ctrlPressed:int;
        private var _shiftPressed:int;
        private var _altPressed:int;
        private var _useCapture:Boolean;
        private var _eventType:String;
        
        /**
         * Creates a new key sequence associated with the supplied key code and key modifier (Ctrl, Alt and Shift)
         * <p>A list of available key code can be found 
         * <a href="http://msdn2.microsoft.com/en-us/library/ms927178.aspx">here</a>
         * </p>
         * 
         * 
         */
        public function KeySequence(keyCode:int, tipStr:String = "", ctrlPressed:int = 0, altPressed:int = 0, shiftPressed:int = 0, eventType:String = null, useCapture:Boolean = false) {
            _keyCode = keyCode;
            _tipStr = tipStr;
            _ctrlPressed = ctrlPressed;
            if(_ctrlPressed > 0) _tipStr = "Ctrl+" + _tipStr;
            _altPressed = altPressed;
            if(_altPressed > 0) _tipStr = "Alt+" + _tipStr;
            _shiftPressed = shiftPressed;
            if(_shiftPressed > 0) _tipStr = "Shift+" + _tipStr;
            _useCapture = useCapture;
            _eventType = eventType;
        }
        
        /**
         * Gets a value indicating whether this key sequence has been pressed in the supplied
         * keyboard event
         */
        public function isPressed(event:KeyboardEvent): Boolean {
            return event && (!_eventType || _eventType == event.type) && (_useCapture || event.eventPhase != EventPhase.CAPTURING_PHASE) && (_keyCode == -1 || event.keyCode == _keyCode) && 
                (_ctrlPressed == 0 || (_ctrlPressed > 0 && event.ctrlKey) || (_ctrlPressed < 0 && !event.ctrlKey)) &&
                (_altPressed == 0 || (_altPressed > 0 && event.altKey) || (_altPressed < 0 && !event.altKey)) &&
                (_shiftPressed == 0 || (_shiftPressed > 0 && event.shiftKey) || (_shiftPressed < 0 && !event.shiftKey));
        }
        
        public function toString():String {
            return _tipStr;
        }
    }
}