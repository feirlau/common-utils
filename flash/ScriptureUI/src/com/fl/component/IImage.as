/**
 * @author risker
 **/
package com.fl.component {
	import flash.system.LoaderContext;
	
	public interface IImage {
		function set preCachedSource(value:String):void;
		function get preCachedSource():String;
		function get loaderContext():LoaderContext;
		function set loaderContext(value:LoaderContext):void;
		function set source(value:Object):void;
		function get source():Object;
		function applySource(value:Object):void;
	}
}
