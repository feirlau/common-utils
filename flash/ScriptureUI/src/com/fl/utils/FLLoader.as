/**
 * @author risker
 **/
package com.fl.utils {
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	public class FLLoader extends Loader {
		public static var defaultContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
		
		public function FLLoader() {
			super();
		}
		
		public var dataFormat:String;
		private var data_:*;
		public function get data():* {
			if(!data_) {
				try {
					var tmpBytes:ByteArray = contentLoaderInfo.bytes;
					switch(dataFormat) {
						case "txt":
						case "properties":
							data_ = tmpBytes.readUTFBytes(tmpBytes.length);
							break;
						case URLLoaderDataFormat.VARIABLES:
							data_ = new URLVariables();
							data_.decode(tmpBytes.readUTFBytes(tmpBytes.length));
							break;
						default:
							data_ = tmpBytes;
					}
				} catch(err:Error) {
					trace(err.getStackTrace());
				}
			}
			return data_;
		}
		
		public var completeFunc:Function;
		public var errorFunc:Function;
		public var progressFunc:Function;
        private function addListeners():void {
            contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
            contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
        }
        private function removeListeners():void {
			contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
			contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
        }
        public function removeHandlers():void {
			completeFunc = null;
			errorFunc = null;
			progressFunc = null;
        }
		public function closeLoader():void {
            removeListeners();
			removeHandlers();
			try { close(); } catch(err:Error) {}
		}
        
		private function completeHandler(env:Event):void {
			FLUtil.apply(completeFunc, env);
			closeLoader();
		}
		private function progressHandler(env:ProgressEvent):void {
			FLUtil.apply(progressFunc, env);
			LogUtil.addLog(this, ["[progressHandler] " + env.bytesLoaded + "/" + env.bytesTotal], LogUtil.DEBUG);
		}
		private function errorHandler(env:Event):void {
			FLUtil.apply(errorFunc, env);
			closeLoader();
			LogUtil.addLog(this, ["errorHandler", env.toString()], LogUtil.ERROR);
		}
		
		public function startLoad(url:String, params:Object, context:LoaderContext, cHandler:Function = null, eHandler:Function = null, pHandler:Function = null):void {
            addListeners();
			completeFunc = cHandler;
			errorFunc = eHandler;
			progressFunc = pHandler;
			var req:URLRequest = new URLRequest(url);
			req.method = URLRequestMethod.POST;
			req.data = params;
			context ||= defaultContext;
			load(req, context);
		}
        public function startLoadBytes(bytes:ByteArray, context:LoaderContext, cHandler:Function = null, eHandler:Function = null, pHandler:Function = null):void {
            addListeners();
            completeFunc = cHandler;
            errorFunc = eHandler;
            progressFunc = pHandler;
            context ||= defaultContext;
            loadBytes(bytes, context);
        }
	}
}