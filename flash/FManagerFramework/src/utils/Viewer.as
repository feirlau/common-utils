package utils
{
	import events.UpdateViewEvent;
	
	import mx.containers.Canvas;
	import mx.events.FlexEvent;
	import mx.rpc.events.ResultEvent;
	
	[Event(name="UpdateView", type="events.UpdateViewEvent")]
	public class Viewer extends Canvas
	{
		[Bindable]
		public var viewerData:XML = null;
		[Bindable]
		public var itemData:XML = null;
		
		public function Viewer()
		{
			this.addEventListener(FlexEvent.INITIALIZE, initView);
			this.addEventListener(UpdateViewEvent.UPDATE_VIEW, updateView);
		}
		public function updateView(event:UpdateViewEvent):void {
			trace(event.data);
		}
		public function httpResult(event:ResultEvent):void {
			viewerData = event.result as XML;
			trace(viewerData);
		}
		public function initView(event:FlexEvent):void {
			
		}
	}
}