/* Copyright (c) 2009-2010 Vitria Technology, Inc.  All rights reserved. */
package controls.messagefw
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.geom.Point;
    
    import mx.collections.ArrayCollection;
    import mx.core.Application;
    import mx.events.ResizeEvent;
    import mx.formatters.DateFormatter;
    
    /**
    * 1. The messages will grow from top to bottom
    * 2. If reach the bottom, they will stack at the bottom one
    * 3. Close the top message, the bottom ones will grow up
    * 4. There are three types of message, info with white color, warn with green color and error with red color.
    * 5. no border and close button by default;
    * 6. dark background, a little transparent, not pure black color;
    * 7. disappear after 5 seconds;
    * 8. When mouse over, show white border and close button;
    * 9. Never disappear if mouse over, until you mouse out and timeout
    **/
    public class MessagePopupManager
    {
        private var par_:DisplayObject;
        private var dateFormatter_:DateFormatter = new DateFormatter();
        public function MessagePopupManager(par:DisplayObject=null) {
            dateFormatter_.formatString = "YYYY-MM-DD LL:NN:SS A";
            if(!par) {
                par_ = Sprite(Application.application);
            } else {
                par_ = par;
            }
            par_.addEventListener(ResizeEvent.RESIZE, adjustSize);
        }
        private function adjustSize(event:ResizeEvent):void {
            updateMessagePositions();
        }
        
        private static var instance_:MessagePopupManager;
        public static function getInstance():MessagePopupManager {
            if(null == instance_) {
                instance_ = new MessagePopupManager();
            }
            return instance_;
        }
        
        private var messageCanvasList:ArrayCollection = new ArrayCollection();
        
        /**
        * Show message as System Growl Message style
        * @param message, the message text
        * @param type, the message type, can be "info", "warn", "error", please refer to M3OStatusBarUtil
        **/
        public function addMessage(message:String, type:String):void {
            if(message) {
                var tmpMessageCanvas:MessageCanvas = new MessageCanvas();
                tmpMessageCanvas.messageText = message;
                tmpMessageCanvas.messageTime = dateFormatter_.format(new Date());
                tmpMessageCanvas.messageType = type;
                tmpMessageCanvas.onClose = closeHandler;
                var tmpPoint:Point = getMessagePosition(tmpMessageCanvas);
                tmpMessageCanvas.showMessage(tmpPoint, par_);
                messageCanvasList.addItem(tmpMessageCanvas);
            }
        }
        private function getMessagePosition(messageCanvas:MessageCanvas):Point {
            var tmpX:int = 0;
            var tmpY:int = 0;
            if(messageCanvasList.contains(messageCanvas)) {
                tmpX = messageCanvas.x;
                tmpY = messageCanvas.y;
            } else {
                var parHeight:int = par_.height;
                var parWidth:int = par_.width;
                tmpX = parWidth - messageCanvas.width - 10;
                if(tmpX < 0) {
                    tmpX = 0;
                }
                tmpY = 10;
                for each(var tmpMessageCanvas:MessageCanvas in messageCanvasList) {
                    if(tmpY + tmpMessageCanvas.height + 5 + messageCanvas.height > parHeight) {
                        break;
                    }
                    tmpY = tmpY + tmpMessageCanvas.height + 5;
                }
            }
            return new Point(tmpX, tmpY);
        }
        
        private function closeHandler(messageCanvas:MessageCanvas):void {
            if(messageCanvasList.contains(messageCanvas)) {
                messageCanvasList.removeItemAt(messageCanvasList.getItemIndex(messageCanvas));
                updateMessagePositions();
            }
        }
        
        public function updateMessagePositions():void {
            var tmpX:int = 0;
            var tmpY:int = 10;
            var parHeight:int = par_.height;
            var parWidth:int = par_.width;
            var isExceed:Boolean = false;
            var preY:int = tmpY;
            for each(var tmpMessageCanvas:MessageCanvas in messageCanvasList) {
                tmpX = parWidth - tmpMessageCanvas.width - 10;
                if(tmpX < 0) {
                    tmpX = 0;
                }
                if(!isExceed && tmpY + tmpMessageCanvas.height > parHeight) {
                    tmpY = preY;
                    isExceed = true;
                }
                tmpMessageCanvas.x = tmpX;
                tmpMessageCanvas.y = tmpY;
                if(!isExceed) {
                    preY = tmpY;
                    tmpY = tmpY + tmpMessageCanvas.height + 5;
                }
            }
        }
        
        public function closeAllMessages():void {
            var tmpList:Array = messageCanvasList.toArray();
            for each(var tmpMessageCanvas:MessageCanvas in tmpList) {
                tmpMessageCanvas.closeMessage();
            }
        }
        
        // close all opened message, such as logout
        public function destory():void {
            closeAllMessages();
        }
    }
}