package events
{
	import flash.events.Event;
	
	public class UpdateViewEvent extends Event
	{
		public var data:Object = null;
		public static const UPDATE_VIEW:String = "UpdateView" ;
		public static const UPDATE_LIST:String = "UpdateList" ; 
		public function UpdateViewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
		    var tmpEvent:UpdateViewEvent = new UpdateViewEvent(type);
		    tmpEvent.data = data;
		    return tmpEvent;
		}
	}
}