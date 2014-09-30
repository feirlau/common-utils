package com.fl.mouse {
    import flash.events.MouseEvent;
    
    public interface IMouseHandler {
        /** 是否接收该鼠标事件 */
        function acceptMouse(env:MouseEvent, data:Object = null):Boolean;
        /** 处理鼠标事件 */
        function handleMouse(env:MouseEvent, data:Object = null):void;
    }
}
