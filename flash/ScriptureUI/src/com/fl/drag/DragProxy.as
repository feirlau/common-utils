package com.fl.drag {
	import com.fl.component.BaseComponent;
	import com.fl.component.UIGlobal;
	import com.fl.keyboard.IKeyboardHandler;
	import com.fl.keyboard.KeySequence;
	import com.fl.mouse.IMouseHandler;
	import com.fl.mouse.MouseSequence;
	import com.fl.utils.FLUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.getDefinitionByName;

	/**
	 *  为DragManager显示拖拽图像的帮助类.
	 */
	public class DragProxy extends BaseComponent implements IKeyboardHandler, IMouseHandler {
	    public var dragInitiator:DisplayObject;
	    public var dragSource:DragSource;
	    public var target:InteractiveObject;
        
	    public var xOffset:Number;
	    public var yOffset:Number;
	    public var startX:Number;
	    public var startY:Number;
	    /**
	     *  @see DragManager
	     */
	    public var action:String;
	    public var allowMove:Boolean = true;
        
        private var lastKeyEvent:KeyboardEvent;
        private var lastMouseEvent:MouseEvent;
        private var lastMouseTarget:DisplayObject;
        
		public function DragProxy(dragInitiator:DisplayObject, dragSource:DragSource) {
			super();
            
            mouseEnabled = mouseChildren = false;
            
			this.dragInitiator = dragInitiator;
        	this.dragSource = dragSource;
            
            UIGlobal.keyboard.addHandler(this);
            UIGlobal.mouse.addHandler(this);
		}
        
        private var bmp:Bitmap;
        public function createDragImg():void {
            var tmpData:BitmapData;
            tmpData = new BitmapData(dragInitiator.width, dragInitiator.height, true, 0x88000000);
            tmpData.draw(dragInitiator);
            bmp = new Bitmap(tmpData, PixelSnapping.AUTO, true);
        }
        
        public function endDrag():void {
            UIGlobal.drag.endDrag();
        }
        
        public function destory():void {
            UIGlobal.keyboard.removeHandler(this);
            UIGlobal.mouse.removeHandler(this);
            
            if(bmp && bmp.bitmapData) {
                bmp.bitmapData.dispose();
            }
            bmp = null;
            
            if(parent) parent.removeChild(this);
            
            lastKeyEvent = null;
            lastMouseEvent = null;
            lastMouseTarget = null;
        }
        
        public function showFeedback():void {
            if(!action || action == DragManager.NONE) {
                Mouse.cursor = MouseCursor.AUTO;
            } else {
                Mouse.cursor = action;
            }
        }
        
        private function dispatchDragEvent(type:String, env:Object, eventTarget:DisplayObject, relatedObject:InteractiveObject = null):void {
            
            var dragEvent:DragEvent = new DragEvent(type);
            var pt:Point = new Point();
            
            dragEvent.dragInitiator = dragInitiator;
            dragEvent.dragSource = dragSource;
            dragEvent.action = action;
            dragEvent.relatedObject = relatedObject;
            dragEvent.ctrlKey = env.ctrlKey;
            dragEvent.altKey = env.altKey;
            dragEvent.shiftKey = env.shiftKey;
            
            if(lastMouseEvent) {
                pt.x = lastMouseEvent.localX;
                pt.y = lastMouseEvent.localY;
                pt = lastMouseTarget.localToGlobal(pt);
                pt = eventTarget.globalToLocal(pt);
                dragEvent.localX = pt.x;
                dragEvent.localY = pt.y;
            }
            
            eventTarget.dispatchEvent(dragEvent);
        }
        
        private var escKey:KeySequence = new KeySequence(Keyboard.ESCAPE, "", 0, 0, 0, KeyboardEvent.KEY_DOWN);
        /** 是否接收该键盘事件 */
        public function acceptKey(env:KeyboardEvent, data:Object = null):Boolean {
            return true;
        }
        /** 处理键盘事件 */
        public function handleKey(env:KeyboardEvent, data:Object = null):void {
            if(escKey.isPressed(env)) {
                endDrag();
            } else {
                checkKeyEvent(env);
            }
        }
        private function checkKeyEvent(event:KeyboardEvent):void {
            if (target && lastMouseEvent && lastMouseTarget) {
                // Ignore repeat events. We only send the dragOver
                // event when the key state changes.
                if(lastKeyEvent && (event.type == lastKeyEvent.type) && (event.keyCode == lastKeyEvent.keyCode)) {
                    return;
                }
                
                lastKeyEvent = event;
                
                dispatchDragEvent(DragEvent.DRAG_OVER, event, target);
                
                showFeedback();
            }
        }
        
        private var _moveMouse:MouseSequence = new MouseSequence(MouseEvent.MOUSE_MOVE, "", 0, 0, 0, true);
        private var _upMouse:MouseSequence = new MouseSequence(MouseEvent.MOUSE_UP, "", 0, 0, 0, true);
        /** 是否接收该鼠标事件 */
        public function acceptMouse(env:MouseEvent, data:Object = null):Boolean {
            return true;
        }
        /** 处理鼠标事件 */
        public function handleMouse(env:MouseEvent, data:Object = null):void {
            if(env == null) {
                mouseUpHandler(lastMouseEvent);
            } else if(_moveMouse.isPressed(env)) {
                mouseMoveHandler(env);
            } else if(_moveMouse.isPressed(env)) {
                mouseUpHandler(env);
            }
        }
        
	    public function mouseMoveHandler(event:MouseEvent):void {
	        var dragEvent:DragEvent;
	        var dropTarget:DisplayObject;
	        var i:int;
	
	        lastMouseEvent = event;
	        lastMouseTarget = event.target as DisplayObject;
            
	        var pt:Point = new Point();
	        var point:Point = new Point(event.localX, event.localY);
	        var stagePoint:Point = lastMouseTarget.localToGlobal(point);
	        var mouseX:Number = point.x;
	        var mouseY:Number = point.y;
	        x = mouseX - xOffset;
	        y = mouseY - yOffset;
	
			var targetList:Array = FLUtil.getObjectsUnderPoint(UIGlobal.stage, stagePoint);
	        
            // targetList is in depth order, and we want the top of the list. However, we
            // do not want the target to be a decendent of us.
			var newTarget:DisplayObject = null;
			var targetIndex:int = targetList.length - 1;
			while (targetIndex >= 0) {
				newTarget = targetList[targetIndex];
				if (newTarget != this && !contains(newTarget))
					break;
				targetIndex--;
			}
			
            // If we already have a target, send it a dragOver event
            // if we're still over it.
            // If we're not over it, send it a dragExit event.
	        if (target) {
	            var foundIt:Boolean = false;
	            var oldTarget:DisplayObject = target;
	
				dropTarget = newTarget;
	
				while (dropTarget) {
					if (dropTarget == target) {
						dispatchDragEvent(DragEvent.DRAG_OVER, event, dropTarget);
						foundIt = true;
						break;
					} 
					else  {
						dispatchDragEvent(DragEvent.DRAG_ENTER, event, dropTarget);
                        
                        // If the potential target accepted the drag, our target
                        // now points to the dropTarget. Bail out here, but make 
                        // sure we send a dragExit event to the oldTarget.
						if (target == dropTarget) {
							foundIt = false;
							break;
						}
					}
					dropTarget = dropTarget.parent;
				}
	
	            if(!foundIt) {
                    // Dispatch a "dragExit" event on the old target.
	                dispatchDragEvent(DragEvent.DRAG_EXIT, event, oldTarget);
					if(target == oldTarget) target = null;
	            }
	        }
	
            // If we don't have an existing target, go look for one.
	        if(!target) {
	            action = DragManager.MOVE;
	
				dropTarget = newTarget;
				while(dropTarget) {
					if(dropTarget != this) {
						dispatchDragEvent(DragEvent.DRAG_ENTER, event, dropTarget);
						if(target) break;
					}
					dropTarget = dropTarget.parent;
				}
	
	            if(!target) action = DragManager.NONE;
	        }
	
	        showFeedback();
	    }
        
	    public function mouseUpHandler(event:MouseEvent):void {
	        var dragEvent:DragEvent;
	
	        if (target && action != DragManager.NONE) {
	            dispatchDragEvent(DragEvent.DRAG_DROP, event, target);
	        } else {
	            action = DragManager.NONE;
	        }
	        
            dispatchDragEvent(DragEvent.DRAG_COMPLETE, event, dragInitiator, target);
	
	        endDrag();
	    }
	}
}
