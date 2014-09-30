package com.fl.skin {
	import com.fl.component.BaseComponent;
	import com.fl.style.IStyle;
	
	import flash.display.DisplayObject;

    public interface ISkin {
        function get contentWidth():Number;
        function get contentHeight():Number;
        function get content():DisplayObject;
        
		function get owner():BaseComponent;
		function set owner(value:BaseComponent):void;
		
		function get style():IStyle;
		function set style(value:*):void;
    }
}
