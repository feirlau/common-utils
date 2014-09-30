package com.fl.style {
	import flash.events.IEventDispatcher;

    public interface IStyle extends IEventDispatcher{
		function get styles():Object;
        /**@param key, key1>key2>key3...*/
		function setStyle(key:String, value:*):void;
        /**@param key, key1>key2>key3...*/
		function getStyle(key:String):*;
		function hasStyle(key:String):Boolean;
		
		/**
		 * @param style, IStyle/json string/object 
		 **/
		function copyStyle(style:*):void;
        function refreshStyle():void;
    }
}
