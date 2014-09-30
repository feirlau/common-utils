package utils.controls
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.controls.Image;
	import mx.core.BitmapAsset;
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.graphics.ImageSnapshot;
	import mx.managers.DragManager;
	
	public class DropAbleComponent
	{
		public function DropAbleComponent()
		{
		}
		private var _source:UIComponent;
		public var format:String = "DEFAULT";
		public var dropSuccess:Function;
		
		public function set source(comp:UIComponent):void {
			comp.addEventListener(DragEvent.DRAG_ENTER, dragEnter);
			comp.addEventListener(DragEvent.DRAG_OVER, dragOver);
			comp.addEventListener(DragEvent.DRAG_DROP, dragDrop);
			_source = comp;
		}
		public function get source():UIComponent {
			return _source;
		}
		
		protected function dragEnter(event:DragEvent):void {
			var ds:DragSource = event.dragSource;
			if(ds.hasFormat(format)) {
				var data:DragAbleComponent = ds.dataForFormat(format) as DragAbleComponent ;
				if(data) {
					var action:String = DragManager.MOVE;
					if(data.copyAble&&event.ctrlKey) {
						action = DragManager.COPY;
					}
					DragManager.acceptDragDrop(source);
					DragManager.showFeedback(action);
				}
			}
		}
		
		protected function dragOver(event:DragEvent):void {
			var ds:DragSource = event.dragSource;
			if(ds.hasFormat(format)) {
				var data:DragAbleComponent = ds.dataForFormat(format) as DragAbleComponent ;
				if(data) {
					var action:String = DragManager.MOVE;
					if(data.copyAble&&(event.ctrlKey||!data.dragAble)) {
						action = DragManager.COPY;
					}
					DragManager.showFeedback(action);
				}
			}
		}
		
		protected function dragDrop(event:DragEvent):void {
			var ds:DragSource = event.dragSource;
			var info:Object = new Object();
			if(format&&ds.hasFormat(format)) {
				var data:DragAbleComponent = ds.dataForFormat(format) as DragAbleComponent ;
				var comp:UIComponent = data.dropComponentSource;
				info.x = event.localX;
                info.y = event.localY;
                info.dragger = data;
				if(data&&data.addSource) {
					comp = data.source;
					trace(describeType(UIComponent));
					if(data.copyAble&&(event.ctrlKey||!data.dragAble)) {
						if(data.dropAsImage) {
							comp = new Image();
							Image(comp).source = new BitmapAsset(ImageSnapshot.captureBitmapData(data.source));
						}else {
							var className:String = getQualifiedClassName(data.source);
							className = className.replace(/::/g, '.');
							var classRef:Class = getDefinitionByName(className) as Class;
							comp = new classRef() as UIComponent;
							comp.width = data.source.width;
							comp.height = data.source.height;
							if(comp.hasOwnProperty('text')) {
								Object(comp).text = Object(data.source).text;
							}
							if(comp.hasOwnProperty('label')) {
								Object(comp).label = Object(data.source).label;
							}
							if(comp.hasOwnProperty('source')) {
								Object(comp).source = Object(data.source).source;
							}
						}
					}else if(data.dropAsImage) {
						if(comp.parent) {
							comp.parent.removeChild(comp);
						}
						comp = new Image();
						Image(comp).source = new BitmapAsset(ImageSnapshot.captureBitmapData(data.source));
						if(data.resetSource) {
							data.source = null;
						}else {
							data.source = comp;
						}
					}
					info.x = event.localX - data.info.offsetX;
					info.y = event.localY - data.info.offsetY;
				}
				if(comp) {
					comp.x = info.x;
					comp.y = info.Y;
					if(comp.parent!=source){
						source.addChild(comp);
					}
				}
				info.event = event;
				info.comp = comp;
				info.dropper = this;
				if(dropSuccess!=null) {
					dropSuccess(info);
				}
				if(data.dropSuccess!=null) {
					data.dropSuccess(info);
				}
			}
		}
	}
}