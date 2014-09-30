package com.fl.mouse {
    import flash.events.EventPhase;
    import flash.events.MouseEvent;
    
    /**
     * Represents a sequence of mouse.
     */
    public class MouseSequence {
        private var _tipStr:String = "";
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
        public function MouseSequence(eventType:String, tipStr:String = "", ctrlPressed:int = 0, altPressed:int = 0, shiftPressed:int = 0, useCapture:Boolean = false) {
            _eventType = eventType;
            _tipStr = tipStr;
            _ctrlPressed = ctrlPressed;
            if(_ctrlPressed > 0) _tipStr = "Ctrl+" + _tipStr;
            _altPressed = altPressed;
            if(_altPressed > 0) _tipStr = "Alt+" + _tipStr;
            _shiftPressed = shiftPressed;
            if(_shiftPressed > 0) _tipStr = "Shift+" + _tipStr;
            _useCapture = useCapture;
        }
        
        /**
         * Gets a value indicating whether this mouse sequence has been pressed in the supplied
         * keyboard event
         */
        public function isPressed(event:MouseEvent): Boolean {
            return event && (!_eventType || _eventType == event.type) && (_useCapture || event.eventPhase != EventPhase.CAPTURING_PHASE) &&
                (_ctrlPressed == 0 || (_ctrlPressed > 0 && event.ctrlKey) || (_ctrlPressed < 0 && !event.ctrlKey)) &&
                (_altPressed == 0 || (_altPressed > 0 && event.altKey) || (_altPressed < 0 && !event.altKey)) &&
                (_shiftPressed == 0 || (_shiftPressed > 0 && event.shiftKey) || (_shiftPressed < 0 && !event.shiftKey));
        }
        
        public function toString():String {
            return _tipStr;
        }
    }
}