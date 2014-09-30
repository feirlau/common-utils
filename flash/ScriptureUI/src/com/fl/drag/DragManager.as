package com.fl.drag {
    import flash.display.DisplayObject;
    import flash.display.InteractiveObject;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    public class DragManager {
        /**
         *  Constant that specifies that the type of drag action is "none".
         */
        public static const NONE:String = "none";
        
        /**
         *  Constant that specifies that the type of drag action is "copy".
         */
        public static const COPY:String = "copy";
        
        /**
         *  Constant that specifies that the type of drag action is "move".
         */
        public static const MOVE:String = "move";
        
        /**
         *  Constant that specifies that the type of drag action is "link".
         */
        public static const LINK:String = "link";
        

        private var stage:Stage;
        public function DragManager(s:Stage) {
            stage = s;
        }

        private var _dragProxy:DragProxy;
        
        private var _isDragging:Boolean;
        public function get isDragging():Boolean {
            return _isDragging;
        }
        /**
         *  Initiates a drag and drop operation.
         *
         *  @param dragInitiator IUIComponent that specifies the component initiating
         *  the drag.
         *
         *  @param dragSource DragSource object that contains the data
         *  being dragged.
         *
         *  @param dragImage The image to drag. This argument is optional.
         *  If omitted, a standard drag rectangle is used during the drag and
         *  drop operation. If you specify an image, you must explicitly set a
         *  height and width of the image or else it will not appear.
         *
         *  @param xOffset Number that specifies the x offset, in pixels, for the
         *  <code>dragImage</code>. This argument is optional. If omitted, the drag proxy
         *  is shown at the upper-left corner of the drag initiator. The offset is expressed
         *  in pixels from the left edge of the drag proxy to the left edge of the drag
         *  initiator, and is usually a negative number.
         *
         *  @param yOffset Number that specifies the y offset, in pixels, for the
         *  <code>dragImage</code>. This argument is optional. If omitted, the drag proxy
         *  is shown at the upper-left corner of the drag initiator. The offset is expressed
         *  in pixels from the top edge of the drag proxy to the top edge of the drag
         *  initiator, and is usually a negative number.
         *
         *  @param imageAlpha Number that specifies the alpha value used for the
         *  drag image. This argument is optional. If omitted, the default alpha
         *  value is 0.5. A value of 0.0 indicates that the image is transparent;
         *  a value of 1.0 indicates it is fully opaque.
         */
        public function doDrag(dragInitiator:InteractiveObject, dragSource:DragSource, dragImage:DisplayObject = null, 
            xOffset:Number = 0, yOffset:Number = 0, imageAlpha:Number = 0.5, allowMove:Boolean = true):void {
            if(_isDragging)
                return;

            _isDragging = true;

            _dragProxy = new DragProxy(dragInitiator, dragSource);
            stage.addChild(_dragProxy);

            var pw:Number;
            var ph:Number;
            if(dragImage) {
                dragImage.cacheAsBitmap = true;
                _dragProxy.addChild(dragImage);
                pw = dragImage.width;
                ph = dragImage.height;
            } else {
                _dragProxy.createDragImg();
                pw = dragInitiator.width;
                ph = dragInitiator.height;
            }
            _dragProxy.setSize(pw, ph);
            _dragProxy.alpha = imageAlpha;
            _dragProxy.allowMove = allowMove;

            var proxyOrigin:Point = dragInitiator.localToGlobal(new Point(-xOffset, -yOffset));
            _dragProxy.xOffset = stage.mouseX - proxyOrigin.x;
            _dragProxy.yOffset = stage.mouseX - proxyOrigin.y;

            _dragProxy.x = proxyOrigin.x;
            _dragProxy.y = proxyOrigin.y;

            _dragProxy.startX = _dragProxy.x;
            _dragProxy.startY = _dragProxy.y;
        }

        /**
         *  Call this method from your <code>dragEnter</code> event handler if you accept
         *  the drag/drop data.
         *  For example:
         *
         *  <pre>DragManager.acceptDragDrop(event.target);</pre>
         *
         *	@param target The drop target accepting the drag.
         */
        public function acceptDragDrop(target:InteractiveObject):void {
            // trace("-->acceptDragDrop for DragManagerImpl", sm, target);

            if(_dragProxy) _dragProxy.target = target;
        }

        /**
         *  Sets the feedback indicator for the drag and drop operation.
         *  Possible values are <code>DragManager.COPY</code>, <code>DragManager.MOVE</code>,
         *  <code>DragManager.LINK</code>, or <code>DragManager.NONE</code>.
         *
         *  @param feedback The type of feedback indicator to display.
         */
        public function showFeedback(feedback:String):void {
            // trace("-->showFeedback for DragManagerImpl", sm, feedback);
            if(_dragProxy) {
                if(feedback == DragManager.MOVE && !_dragProxy.allowMove)
                    feedback = DragManager.COPY;

                _dragProxy.action = feedback;
            }
        }
        
        /**
         *  Returns the current drag and drop feedback.
         *
         *  @return  Possible return values are <code>DragManager.COPY</code>, 
         *  <code>DragManager.MOVE</code>,
         *  <code>DragManager.LINK</code>, or <code>DragManager.NONE</code>.
         */
        public function getFeedback():String {
            return _dragProxy ? _dragProxy.action : DragManager.NONE;
        }
        
        public function endDrag():void {
            if(_dragProxy) {
                _dragProxy.destory();
                _dragProxy = null;
            }
            _isDragging = false;
        }
    }
}
