package utils
{
	import events.UpdateViewEvent;
	
	import mx.containers.Canvas;
	import mx.events.FlexEvent;
	
	[Event(name="UpdateList", type="events.UpdateViewEvent")]
	public class Manager extends Canvas
	{
	    public var currentView:Viewer = null;
	    
		public function Manager()
		{
			this.addEventListener(FlexEvent.CREATION_COMPLETE, initView);
			this.addEventListener(UpdateViewEvent.UPDATE_LIST, updateList);
		}
		public function initView(event:FlexEvent):void {
			updateList(null);
		}
		public function updateList(event:UpdateViewEvent):void {
		}
	}
}