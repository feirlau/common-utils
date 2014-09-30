package com.fl.style {
    import flash.events.Event;

    public class StyleEvent extends Event {
		public static const EVENT_STYLE_UPDATE:String = "EVENT_STYLE_UPDATE";
		
		public var data:Object;
        public function StyleEvent(type:String, data:Object = null) {
            super(type);
			
			this.data = data;
        }
    }
}
