package com.fl.component {

    public interface IItemRenderer {
        function get label():String;
        function set label(v:String):void;
        
        function get data():*;
        function set data(v:*):void;
        
        function get visible():Boolean;
        function set visible(v:Boolean):void;
        
        function get selected():Boolean;
        function set selected(v:Boolean):void;
    }
}
