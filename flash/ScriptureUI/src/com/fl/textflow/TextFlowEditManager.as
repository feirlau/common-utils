package com.fl.textflow {
    import com.fl.constants.StatefulConstants;
    import com.fl.utils.LogUtil;
    
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TextEvent;
    import flash.ui.Keyboard;
    
    import flashx.textLayout.edit.EditManager;
    import flashx.textLayout.edit.SelectionState;
    import flashx.textLayout.edit.TextScrap;
    import flashx.undo.IUndoManager;

    public class TextFlowEditManager extends EditManager {
        public var textInput:TextFlowInput;
        
        public function TextFlowEditManager(undoManager:IUndoManager=null) {
            super(undoManager);
        }
        
        override public function pasteTextScrap(scrapToPaste:TextScrap, operationState:SelectionState=null):void {
            if(isPlain && textInput) {
                if(scrapToPaste && scrapToPaste.textFlow) {
                    var tmpS1:String = scrapToPaste.textFlow.getText();
                    textInput.insertString(tmpS1);
                }
            } else {
                super.pasteTextScrap(scrapToPaste, operationState);
            }
        }
        
        override public function keyDownHandler(env:KeyboardEvent):void {
            if(env.keyCode == Keyboard.UP || env.keyCode == Keyboard.DOWN) {
                //do nothing
            } else {
                super.keyDownHandler(env);
            }
        }
        
        /**屏蔽一些暂时无法解决的异常*/
        override public function mouseDownHandler(event:MouseEvent):void {
            try {
                super.mouseDownHandler(event);
            } catch(err:Error) {
                LogUtil.addLog(this, err.message, LogUtil.ERROR);
            }
        }
        
        /**屏蔽一些暂时无法解决的异常*/
        override public function mouseDoubleClickHandler(event:MouseEvent):void {
            try {
                super.mouseDoubleClickHandler(event);
            } catch(err:Error) {
                LogUtil.addLog(this, err.message, LogUtil.ERROR);
            }
        }
        
        /**屏蔽一些暂时无法解决的异常*/
        public override function flushPendingOperations():void {
            try {
                super.flushPendingOperations();
            } catch(err:Error) {
                LogUtil.addLog(this, err.message, LogUtil.ERROR);
            }
        }
        
        private var isPlain_:Boolean = false;
        public function get isPlain():Boolean {
            return isPlain_;
        }
        public function set isPlain(v:Boolean):void {
            isPlain_ = v;
        }
        
        override public function textInputHandler(event:TextEvent):void {
            if(isRangeSelection()) {
                deleteText();
            }
            if(textInput && textInput.acceptText(event.text)) {
                super.textInputHandler(event);
            }
        }
        
        override public function focusInHandler(event:FocusEvent):void {
            super.focusInHandler(event);
            if(textInput) {
                textInput.setStyle(StatefulConstants.STATE, StatefulConstants.FOCUS);
            }
        }
        override public function focusOutHandler(event:FocusEvent):void {
            super.focusOutHandler(event);
            if(textInput) {
                textInput.setStyle(StatefulConstants.STATE, "");
            }
        }
    }
}
