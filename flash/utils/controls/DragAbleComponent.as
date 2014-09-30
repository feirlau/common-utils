package utils.controls
{
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	
	import mx.core.Application;
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.graphics.ImageSnapshot;
	import mx.managers.DragManager;

	public class DragAbleComponent
	{
		public function DragAbleComponent()
		{
			//TODO: implement function
		}
		
		private var _source:UIComponent;
		private var _info:Object = {};
		
		public var dragAble:Boolean = true;
		public var copyAble:Boolean = true;
		public var moveAsDrag:Boolean = false;
		public var resetSource:Boolean = false;
		public var format:String = "DEFAULT";
		public var dragStart:Function;
		public var dropSuccess:Function;
		public var dropAsImage:Boolean = false;
		public var addSource:Boolean = false;
		public var dragImageSource:UIComponent;
		public var dropComponentSource:UIComponent;
		
		private static var mousedownTarget:Object;
		init();
		
		private static function init():void {
			Application.application.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void {
					mousedownTarget = event.target;
				});
			Application.application.addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void {
					mousedownTarget = null;
				});
		} 
		public function set source(comp:UIComponent):void {
			if(source){
				source.removeEventListener(MouseEvent.MOUSE_MOVE, startDrag);
			}
			if(comp) {
				comp.addEventListener(MouseEvent.MOUSE_MOVE, startDrag);
			}
			_source = comp;
		}
		public function get source():UIComponent {
			return _source;
		}
		public function get info():Object {
			return _info;
		}
		protected function startDrag(event:MouseEvent):void {
			var mousemoveTarget:Object = event.target;

			if(!event.altKey&&mousemoveTarget&&(mousemoveTarget==mousedownTarget)&&(dragAble||copyAble)) {
				mousedownTarget = null;
				Application.application.setFocus();
				var ds:DragSource = new DragSource();
				ds.addData(this, format);
				var dragImage:UIComponent = new UIComponent();
				var tmpBitmap:BitmapData;
				if(null==dragImageSource) {
					tmpBitmap = ImageSnapshot.captureBitmapData(source);
				}else {
					tmpBitmap = ImageSnapshot.captureBitmapData(dragImageSource);
				}
				dragImage.width = tmpBitmap.width;
				dragImage.height = tmpBitmap.height;
				dragImage.graphics.clear();
				dragImage.graphics.beginBitmapFill(tmpBitmap);
				dragImage.graphics.drawRect(0,0,tmpBitmap.width, tmpBitmap.height);
				dragImage.graphics.endFill();
				DragManager.doDrag(source, ds, event, dragImage);
				
				_info.offsetX = source.mouseX;
				_info.offsetY = source.mouseY;
				
				if(moveAsDrag) {
					source.includeInLayout = false;
					source.visible = false ;
					var callback:Function = function(e:DragEvent):void {
						var comp:UIComponent = e.target as UIComponent;
						comp.removeEventListener(DragEvent.DRAG_COMPLETE, callback);
						comp.includeInLayout = true;
						comp.visible = true;
					}
					source.addEventListener(DragEvent.DRAG_COMPLETE, callback);
				}
				if(dragStart!=null) {
					dragStart(event, this);
				}
			}
		}
	}
}