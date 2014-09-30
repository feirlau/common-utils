package com.fl.keyboard {
    import flash.events.KeyboardEvent;

    public interface IKeyboardHandler {
        /** 是否接收该键盘事件 */
        function acceptKey(env:KeyboardEvent, data:Object = null):Boolean;
        /** 处理键盘事件 */
        function handleKey(env:KeyboardEvent, data:Object = null):void;
    }
}
