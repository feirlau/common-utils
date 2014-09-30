package com.fl.skin {
    import com.fl.component.BaseComponent;
    import com.fl.style.Style;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    public class Skin extends BaseComponent implements ISkin {
        public static const EVENT_SKIN_RESIZE:String = "EVENT_SKIN_RESIZE";
        
        override protected function initStyle():void {
            //just init the empty style
            style = new Style();
        }
        
        override protected function initSkin():void {
            //do nothing, no skin for skin
        }
        
        protected var _contentWidth:Number;
        public function get contentWidth():Number {
            return _contentWidth;
        }
        protected var _contentHeight:Number;
        public function get contentHeight():Number {
            return _contentHeight;
        }
        protected var _content:DisplayObject;
        public function get content():DisplayObject {
            return _content;
        }
        
		private var _owner:BaseComponent;
		public function get owner():BaseComponent {
			return _owner;
		}
		public function set owner(value:BaseComponent):void {
			if(_owner != value) {
				if(_owner) {
					_owner.removeEventListener(EVENT_RESIZE, updateSize);
					_owner.removeEventListener(EVENT_RENDER, renderHandler);
					_owner.contains(this) && _owner.removeChild(this);
				}
				_owner = value;
				if(_owner) {
					_owner.addChildAt(this, 0);
					_owner.addEventListener(EVENT_RESIZE, updateSize, false, 0, true);
					_owner.addEventListener(EVENT_RENDER, renderHandler, false, 0, true);
				}
                updateSize();
                renderHandler();
			}
		}
		protected function renderHandler(env:Event = null):void {
			
		}
        public function updateSize(env:Event = null):void {
            if(_owner) {
                setSize(_owner.width, _owner.height);
            }
        }
    }
}
