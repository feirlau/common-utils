package controls
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.controls.Menu;
	import mx.core.ClassFactory;
	import mx.events.ResizeEvent;
	import mx.skins.halo.ButtonSkin;

	public class ExpandableHBox extends HBox
	{
		public var itemWidth:int = 40;
		public var variableWidth:Boolean = false;
		private var expandLabel_:Button;
		private var expandMenu_:Menu;
		private var visiableChildren:Array = new Array();
		private var hiddenChildren:Array = new Array();
		private var currentWidth:int = 0;
		public function ExpandableHBox()
		{
			super();
			if(null==expandLabel_) {
				expandLabel_ = new Button();
				expandLabel_.label = ">>";
				expandLabel_.useHandCursor = false;
				expandLabel_.labelPlacement = "top";
				expandLabel_.setStyle("fontSize", 8);
				expandLabel_.setStyle("paddingLeft", 0);
				expandLabel_.setStyle("paddingRight", 0);
				expandLabel_.setStyle("skin", null);
				expandLabel_.setStyle("overSkin", ButtonSkin);
				expandLabel_.width = 20;
				expandLabel_.addEventListener(MouseEvent.CLICK, expand);
			}
			if(null==expandMenu_) {
				expandMenu_ = Menu.createMenu(expandLabel_, null);
				expandMenu_.itemRenderer = new ClassFactory(CanvasMenuItemRenderer);
			}
			this.horizontalScrollPolicy = "off";
			this.addEventListener(ResizeEvent.RESIZE, adjustHandler);
			this.addEventListener(Event.ADDED_TO_STAGE, adjustHandler);
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			if(!child) return null;
			if(!variableWidth) child.width = itemWidth;
			if(hiddenChildren.length>0) {
				hiddenChildren.push(child);
				if(child.hasEventListener(ResizeEvent.RESIZE)) {
				    child.addEventListener(ResizeEvent.RESIZE, childrenResized, false, 0, true);
				}
			} else {
                if(child.hasEventListener(ResizeEvent.RESIZE)) {
                    child.addEventListener(ResizeEvent.RESIZE, childrenResized, false, 0, true);
                }
				var tmpWidth:int = 0;
				var tmpGap:int = int(getStyle("horizontalGap"));
				if(visiableChildren.length>0) {
					tmpWidth += tmpGap;
				}
				if(currentWidth+tmpWidth+child.width > width) {
					tmpWidth += expandLabel_.width;
					hiddenChildren.push(child);
					while(visiableChildren.length>0 && currentWidth>0 && currentWidth+tmpWidth>width) {
						var tmpChild:DisplayObject = visiableChildren.pop() as DisplayObject;
						super.removeChild(tmpChild);
						hiddenChildren.unshift(tmpChild);
						currentWidth -= tmpChild.width;
						if(visiableChildren.length>0) {
							currentWidth -= tmpGap;
						} else {
							tmpWidth -= tmpGap;
						}
					}
					currentWidth += tmpWidth;
					super.addChildAt(expandLabel_, numChildren);
				} else {
					tmpWidth += child.width;
					currentWidth += tmpWidth;
					visiableChildren.push(child);
					super.addChildAt(child, numChildren);
				}
			}
			return child;
		}
		override public function removeChild(child:DisplayObject):DisplayObject {
			if(!child) return null;
			if(child.hasEventListener(ResizeEvent.RESIZE)) {
			    child.removeEventListener(ResizeEvent.RESIZE, childrenResized);
			}
			var tmpIndex:int = hiddenChildren.indexOf(child);
			var tmpWidth:int = 0;
			var tmpGap:int = int(getStyle("horizontalGap"));
			if(tmpIndex>=0) {
				delete hiddenChildren[tmpIndex];
			} else {
				tmpIndex = visiableChildren.indexOf(child);
				if(tmpIndex>=0) {
	                delete visiableChildren[tmpIndex];
					super.removeChild(child);
					if(hiddenChildren.length>0) {
						adjust();
					} else {
						if(visiableChildren.length>0) {
			                tmpWidth = tmpGap;
			            }
			            tmpWidth += child.width;
						currentWidth -= tmpWidth;
					}
	            }
	        }
            return tmpIndex==-1?null:child;
		}
		override public function removeAllChildren():void {
			if(super.contains(expandLabel_)) {
				super.removeChild(expandLabel_);
			}
			for each(var child:DisplayObject in visiableChildren) {
				if(child.hasEventListener(ResizeEvent.RESIZE)) {
	                child.removeEventListener(ResizeEvent.RESIZE, childrenResized);
	            }
	            super.removeChild(child);
			}
			visiableChildren = new Array();
			hiddenChildren = new Array();
			currentWidth = 0;
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			if(index>=visiableChildren.length) {
				if(hiddenChildren.length>=0) {
					hiddenChildren.push(child);
				} else {
					return addChild(child);
				}
			} else {
				visiableChildren.splice(index, 0, child);
				adjust();
			}
			return child;
		}
		override public function removeChildAt(index:int):DisplayObject {
			if(index>=visiableChildren.length) {
				index = index - visiableChildren.length;
				if(index>=hiddenChildren.length) return null;
				return hiddenChildren.splice(index, 1);
			}
			return removeChild(visiableChildren[index]);
		}
		
		protected function expand(event:MouseEvent):void {
			var menuPoint:Point = new Point();
			menuPoint = expandLabel_.localToGlobal(new Point(expandLabel_.width,expandLabel_.height));
			expandMenu_.dataProvider = hiddenChildren;
			callLater(expandMenu_.show, [menuPoint.x, menuPoint.y]);
		}
		
		protected function childrenResized(event:Event):void {
			if(event.target && visiableChildren.indexOf(event.target)>=0) {
			    adjust();
			}
		}
		
		protected function adjustHandler(event:Event):void {
			if(event.type==ResizeEvent.RESIZE && Number(event.target.width)==ResizeEvent(event).oldWidth) {
				return;
			}
			callLater(adjust);
		}
		protected function adjust():void {
            var tmpChildren:Array = visiableChildren.concat(hiddenChildren);
            removeAllChildren();
            for each(var child:DisplayObject in tmpChildren) {
            	addChild(child);
            }
		}
	}
}