package utils.common
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.containers.Canvas;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.MoveEvent;
	import mx.events.ResizeEvent;
	
	import org.gif.player.GIFPlayer;
	
	public class UIUtil
	{
		[Embed(source="/assets/progress-animation/waiting.gif", mimeType="application/octet-stream")]
		private static var waitIconClass:Class;
		private static var defaultW:int = 100;
		private static var defaultH:int = 100;
		private static var items:Dictionary = new Dictionary();
		
		public function UIUtil()
		{
		}
        
        public static function disableUI(obj:Object, showIcon:Boolean=true):void {
            var comp:UIComponent = obj as UIComponent;
            if(comp && comp.visible) {
	        	comp.enabled = false;
	        	showWaitIcon(comp);
            }
        }
        public static function enableUI(obj:Object):void {
            var comp:UIComponent = obj as UIComponent;
            if(comp) {
                comp.enabled = true;
                hideWaitIcon(comp);
            }
        }
        
        public static function showWaitIcon(comp:UIComponent):Boolean {
        	if(comp) {
                var displayInfo:Object = items[comp];
                if(displayInfo) {
                	return false;
                }
	        	var app:Application = Application.application as Application;
	        	var iconPlayer:GIFPlayer;
                var playerWrapper:UIComponent;
                var disableCanvas:Canvas;
                iconPlayer = new GIFPlayer(false);
                iconPlayer.loadBytes(ByteArray(new waitIconClass()));
                playerWrapper = new UIComponent();
                playerWrapper.addChild(iconPlayer);
                playerWrapper.setStyle("horizontalCenter", 0);
                playerWrapper.setStyle("verticalCenter", 0);
                disableCanvas = new Canvas();
                disableCanvas.addChild(playerWrapper);
	        	disableCanvas.includeInLayout = false;
	        	disableCanvas.setStyle("backgroundColor", "#bbbbbb");
	        	disableCanvas.setStyle("backgroundAlpha", 0.4);
                iconPlayer.play();
	        	displayInfo = {};
	        	displayInfo.iconPlayer = iconPlayer;
	        	displayInfo.playerWrapper = playerWrapper;
	        	displayInfo.disableCanvas = disableCanvas;
	        	items[comp] = displayInfo;
                resizeWaitIcon(comp);
	        	disableCanvas.visible = true;
	        	app.systemManager.addChild(disableCanvas);
	        	comp.addEventListener(ResizeEvent.RESIZE, resizeHandle);
	        	comp.addEventListener(MoveEvent.MOVE, resizeHandle);
	        	app.addEventListener(FlexEvent.UPDATE_COMPLETE, function():void {
	        	    setTimeout(resizeWaitIcon, 300, comp);
	        	});
	        	return true;
        	}
        	return false;
        }
        
        public static function hideWaitIcon(comp:UIComponent):Boolean {
        	if(comp) {
        		var displayInfo:Object = items[comp];
                if(!displayInfo) {
                    return false;
                }
                var app:Application = Application.application as Application;
                var iconPlayer:GIFPlayer;
                var playerWrapper:UIComponent;
                var disableCanvas:Canvas;
                iconPlayer = displayInfo.iconPlayer;
                playerWrapper = displayInfo.playerWrapper;
                disableCanvas = displayInfo.disableCanvas;
                if(comp.hasEventListener(ResizeEvent.RESIZE)) {
                	comp.removeEventListener(ResizeEvent.RESIZE, resizeHandle);
                }
                if(comp.hasEventListener(MoveEvent.MOVE)) {
                    comp.removeEventListener(MoveEvent.MOVE, resizeHandle);
                }
                if(disableCanvas && disableCanvas.parent==app.systemManager) {
	                iconPlayer.stop();
	                disableCanvas.visible = false;
                    app.systemManager.removeChild(disableCanvas);
                }
                delete items[comp];
                return true;
            }
            return false;
        }
        
        private static function resizeHandle(event:Event):void {
        	var comp:UIComponent = event.target as UIComponent;
        	resizeWaitIcon(comp);
        }
        
        private static function resizeWaitIcon(comp:UIComponent):Boolean {
        	if(comp) {
        		var displayInfo:Object = items[comp];
                if(!displayInfo) {
                    return false;
                }
                var iconPlayer:GIFPlayer;
                var playerWrapper:UIComponent;
                var disableCanvas:Canvas;
                iconPlayer = displayInfo.iconPlayer;
                playerWrapper = displayInfo.playerWrapper;
                disableCanvas = displayInfo.disableCanvas;
                var p:Point = comp.localToGlobal(new Point(0, 0));
                var width:int = comp.width;
                var height:int = comp.height;
                var w:int = width<defaultW?width:defaultW;
                var h:int = height<defaultH?height:defaultH;
                var x:int = width/2 - w/2;
                var y:int = height/2 - h/2;
                var n:int = w>h?h:w;
                iconPlayer.width = n;
                iconPlayer.height = n;
                playerWrapper.width = n;
                playerWrapper.height = n;
                playerWrapper.x = x;
                playerWrapper.y = y;
                disableCanvas.width = width;
                disableCanvas.height = height;
                disableCanvas.x = p.x;
                disableCanvas.y = p.y;
                return true;
            }
            return false;
        }
        
        public static function dispose(comp:UIComponent):Boolean {
        	return hideWaitIcon(comp);
        }
        public static function disposeAll():void {
        	for(var item:Object in items) {
        		dispose(item as UIComponent);
        	}
        }
	}
}
