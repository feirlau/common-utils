/**
 * @author risker
 * Author: Robert VanCuren Jr.
 */
package com.fl.utils {
	import com.fl.component.IImage;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	public class ImageCache {
		private var cachedImages:Dictionary = new Dictionary();
		private var cachedTimes:Dictionary = new Dictionary();
		private var imagesWaitingForCache:Dictionary = new Dictionary();
		private var pendingLoaders:Dictionary = new Dictionary();
		
		private static var _instance:ImageCache;
		public static function getInstance():ImageCache {
			_instance ||= new ImageCache();
			return _instance;
		}
		
		public function setImageSource(image:IImage, source:String):void {
			LogUtil.addLog(this, "[ImageCache.setImageSource] " + source, LogUtil.DEBUG);
			if(!source) {
				removeImageFromWaitingList(image, null);
			} else if(isCached(source)) {
				LogUtil.addLog(this, "[ImageCache.setImageSource cached] ", LogUtil.DEBUG);
				removeImageFromWaitingList(image, null);
				image.applySource(getBitmapFromCache(source));
				cachedTimes[source] = getTimer();
			} else {
				addImageToWaitingList(image, source);
				cacheImage(source, image);
			}
		}
		
		public function cacheImage(source:String, image:IImage):void {
			if(!isCachePending(source)) {
				loadIntoCache(source, image);
			}
		}
		
		public function flushImage(source:String):void {
			delete cachedImages[source];
			delete cachedTimes[source];
		}
		
		public function flush():void {
			cachedImages = new Dictionary();
			cachedTimes = new Dictionary();
		}
		
		private var loadItems:Array = [];
		private function loadIntoCache(source:String, image:IImage):void {
			pendingLoaders[source] = image;
			loadItems.push(source);
			doLoad();
		}
		
		private var maxConnections:int = 4;
		private var curConnections:int = 0;
		private function doLoad():void {
			if(curConnections < 0) curConnections = 0;
			while(curConnections < maxConnections && loadItems.length > 0) {
				var source:String = loadItems.shift();
				new FLLoader().startLoad(source, null, pendingLoaders[source].loaderContext, loaderCompleteHandler, loaderErrorHandler);
				curConnections++;
			}
		}
		
		private function loaderCompleteHandler(event:Event):void {
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			var tmpS:String = loaderInfo.url;
			if(loaderInfo.content is Bitmap) {
				cachedImages[tmpS] = Bitmap(loaderInfo.content).bitmapData;
			} else {
				cachedImages[tmpS] = loaderInfo.bytes;
			}
			cachedTimes[tmpS] = getTimer();
			removeFromPendingImages(tmpS);
			updateImagesWaitingFor(tmpS);
			updateCachedImages();
			
			curConnections--;
			doLoad();
		}
		private function loaderErrorHandler(event:Event):void {
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			var tmpS:String = loaderInfo.url;
			removeFromPendingImages(tmpS);
			updateImagesWaitingFor(tmpS);
			
			curConnections--;
			doLoad();
		}
		
		private function removeFromPendingImages(source:String):void {
			for(var tmpS:String in pendingLoaders) {
				if(tmpS == source) {
					delete pendingLoaders[tmpS];
					break;
				}
			}
		}
		
		private function updateImagesWaitingFor(source:String):void {
			var content:* = cachedImages[source];
			var tmpA:Array = imagesWaitingForCache[source] as Array;
			for each(var image:IImage in tmpA) {
				image.applySource(getBitmapFromCache(source));
			}
			delete imagesWaitingForCache[source];
		}
		
		public var maxCache:uint = 200;
		private function updateCachedImages():void {
			if(maxCache != 0 && maxCache < DictionaryUtil.length(cachedImages)) {
				var preS:String;
				var tmpS:String;
				var preT:uint = 0;
				var tmpT:uint = 0;
				for(tmpS in cachedImages) {
					tmpT = cachedTimes[tmpS];
					if(!preS || tmpT < preT) {
						preS = tmpS;
						preT = tmpT;
					}
				}
				if(preS) {
					flushImage(preS);
				}
			}
		}
		
		private function isCached(source:String):Boolean {
			return cachedImages[source] != null;
		}
		
		private function isCachePending(source:String):Boolean {
			for(var tmpS:String in pendingLoaders) {
				if(tmpS == source) {
					return true;
				}
			}
			return false;
		}
		
		private function addImageToWaitingList(image:IImage, source:String):void {
			var waitingList:Array;
			var i:int = removeImageFromWaitingList(image, source);
			if(i == -1) {
				waitingList = getWaitingListBySource(source) as Array;
				image.preCachedSource = source;
				waitingList.push(image);
			}
		}
		private function removeImageFromWaitingList(image:IImage, source:String):int {
			var waitingList:Array;
			var i:int = -1;
			if(image.preCachedSource) {
				waitingList = imagesWaitingForCache[image.preCachedSource] as Array;
				i = waitingList ? waitingList.indexOf(image) : -1;
				if(i >= 0 && image.preCachedSource != source) {
					waitingList.splice(i, 1);
					image.preCachedSource = null;
					i = -1;
				}
			}
			return i;
		}
		
		private function getWaitingListBySource(source:String):Array {
			var waitingList:Array = imagesWaitingForCache[source] as Array;
			
			if(waitingList == null) {
				waitingList = imagesWaitingForCache[source] = [];
			}
			
			return waitingList;
		}
		
		private function getBitmapFromCache(source:String):* {
			var content:* = cachedImages[source];
			if(content is BitmapData) {
				content = new Bitmap(content as BitmapData);
			} else if(content is ByteArray) {
				//do nothing
			} else {
				content = source;
			}
			return content;
		}
	}
}