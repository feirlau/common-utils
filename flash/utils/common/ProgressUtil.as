package utils.common
{
	import flash.utils.Dictionary;
	
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.controls.ProgressBar;
	
	public class ProgressUtil
	{
		public static var canvas:Canvas = new Canvas();
		
		private static var items:Dictionary = new Dictionary();
		private static var itemCount:int = 0;
		private static var vbox:VBox;
		
		init();
		
		private static function init():void {
			canvas.width = 320;
			canvas.maxHeight = 300;
			vbox = new VBox();
			vbox.percentHeight = 100;
			vbox.setStyle("verticalGap", 3);
			canvas.addChild(vbox);
		}
		
		public static function show():void {
			canvas.visible = true;
		}
		public static function hide():void {
			canvas.visible = false;
		}
		
		/**
		 * status (-1:error, 0:start, 1:loading, 2:loaded)
		 **/
		public static function setProgress(target:Object, status:int=1, loadedBytes:int=1, totalBytes:int=1):void {
			if(target && totalBytes>0 && loadedBytes>=0) {
				var info:Object = items[target];
				if(null==info || info.status<0 || info.status>1) {
					return;
				}
				var progressBar:ProgressBar = info.progressBar;
				var url:String = info.url;
				if(status==1) {
					info.loadedBytes = loadedBytes;
					info.totalBytes = totalBytes;
					progressBar.setProgress(loadedBytes, totalBytes);
				}
				progressBar.setStyle("barColor", getStatusColor(status));
				info.status = status;
				progressBar.label = url + "  [" + getStatusLabel(status) + ": %2Bytes %3%%]";
			}
		}
		
		public static function addProgress(target:Object, url:String):void {
			try {
				var info:Object = items[target];
				if(null == info) {
					info = {};
					info.progressBar = new ProgressBar();
					items[target] = info;
					itemCount = itemCount + 1;
					addProgressBar(info.progressBar);
				}
				if(!url) {
					url = "********"
				}
				if(url.length>20) {
					url = "..." + url.substring(url.length-20);
				}
				info.url = url;
				info.progressBar.label = url + "  [" +  getStatusLabel(0) + ": %2Bytes %3%%]";
			} catch(error:Error) {
				trace("removeProgress [" + target + "]error: " + error);
			}
		}
		public static function removeProgress(target:Object):void {
			try {
				var progressBar:ProgressBar = items[target] as ProgressBar;
				removeProgressBar(progressBar);
				delete items[target];
				itemCount = itemCount - 1;
				if(itemCount<0) {
					itemCount = 0;
				}
			} catch(error:Error) {
				trace("removeProgress [" + target + "]error: " + error);
			}
		}
		
		public static function addProgressBar(progressBar:ProgressBar):void {
			try {
				progressBar.width = 300;
				progressBar.height = 22;
				progressBar.labelPlacement = "center";
                progressBar.mode = "manual";
                progressBar.setStyle("labelWidth", 300);
                progressBar.setStyle("textAlign", "left");
				vbox.addChild(progressBar);
			} catch(error:Error) {
				trace(error);
			}
		}
		
		public static function removeProgressBar(progressBar:ProgressBar):void {
			try {
			  vbox.removeChild(progressBar);
			} catch(error:Error) {
				trace(error);
			}
		}
		
		public static function getStatusLabel(status:int):String {
			var s:String = "loading";
			if(status==-1) {
				s = "error";
			} else if(status==0) {
				s = "start";
			} else if(status==2) {
				s = "loaded";
			}
			return s;
		}
		public static function getStatusColor(status:int):uint {
			var color:uint = 0x00FF00;
			if(status==-1) {
				color = 0xFF0000;
			} else if(status==0) {
				color = 0x00FFFF;
			} else if(status==2) {
				color = 0x0000FF;
			}
			return color;
		}
		
		public static function dispose():void {
			try {
		        canvas = null;
		        vbox = null;
		        for(var item:Object in items) {
		        	removeProgress(item);
		        }
		        itemCount = 0;
		    } catch(error:Error) {
		    	trace(error);
		    }
		}
	}
}