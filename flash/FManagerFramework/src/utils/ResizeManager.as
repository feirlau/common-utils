package utils
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.containers.Panel;
  
 /**
 * @class ResizeManager
 * @brief Enable any UIComponent to resize
 * @author Jove flex-flex.net
 * @version 1.1
 */
 public class ResizeManager{
    
	private static const SIDE_OTHER:Number = 0;
	private static const SIDE_TOP:Number = 1;
	private static const SIDE_BOTTOM:Number = 2;
	private static const SIDE_LEFT:Number = 4;
	private static const SIDE_RIGHT:Number = 8;
    
	private static var resizeObj:UIComponent;
	private static var mouseMargin:Number = 10;
	private static var mouseState:Number = 0;
    
	[Embed(source="conf/imgs/verticalSize.gif")]
	private static var verticalSize:Class;
	[Embed(source="conf/imgs/horizontalSize.gif")]
	private static var horizontalSize:Class; 
	[Embed(source="conf/imgs/leftObliqueSize.gif")]
	private static var leftObliqueSize:Class;
	[Embed(source="conf/imgs/rightObliqueSize.gif")]
	private static var rightObliqueSize:Class;
    
     /**
      * Enable the UIComponent to have resize capability.
      * @param targetObj The UIComponent to be enabled resize capability
      * @param minSize The min size of the UIComponent when resizing
      */
     public static function enableResize(targetObj:UIComponent, minSize:Number):void{
        //Application.application.parent:SystemManager
        Application.application.parent.addEventListener(MouseEvent.MOUSE_UP, doMouseUp);
        Application.application.parent.addEventListener(MouseEvent.MOUSE_MOVE, doResize);
        
        initPosition(targetObj);
        
        targetObj.setStyle("oPoint", new Point());
        targetObj.setStyle("minSize", minSize);
        targetObj.setStyle("isPopup", targetObj.isPopUp);
        
        targetObj.addEventListener(MouseEvent.MOUSE_DOWN, doMouseDown);
        //targetObj.addEventListener(MouseEvent.MOUSE_UP, doMouseUp);
        targetObj.addEventListener(MouseEvent.MOUSE_MOVE, doMouseMove);
        targetObj.addEventListener(MouseEvent.MOUSE_OUT, doMouseOut);
     }
    
     /**
      * Disable the UIComponent to have resize capability.
      * @param targetObj The UIComponent to be disabled resize capability
      */
     public static function disableResize(targetObj:UIComponent):void{
        targetObj.removeEventListener(MouseEvent.MOUSE_DOWN, doMouseDown);
        //targetObj.removeEventListener(MouseEvent.MOUSE_UP, doMouseUp);
        targetObj.removeEventListener(MouseEvent.MOUSE_MOVE, doMouseMove);
        targetObj.removeEventListener(MouseEvent.MOUSE_OUT, doMouseOut);
     }
     
        
     private static function initPosition(obj:Object):void{
        obj.setStyle("oHeight", obj.height);
        obj.setStyle("oWidth", obj.width);
        obj.setStyle("oX", obj.x);
        obj.setStyle("oY", obj.y);
     }
    
     /**
      * Set the first global point that mouse down on the resizeObj.
      * @param The MouseEvent.MOUSE_DOWN
      */
     private static function doMouseDown(event:MouseEvent):void{
       
        if(mouseState != SIDE_OTHER){
          
          resizeObj = UIComponent(event.currentTarget);
          
          initPosition(resizeObj);
          
          var point:Point = new Point();
          point.x = resizeObj.mouseX;
          point.y = resizeObj.mouseY;
  
          point = resizeObj.localToGlobal(point);
          resizeObj.setStyle("oPoint", point);
        }
     }
    
     /**
      * Clear the resizeObj and also set the latest position.
      * @param The MouseEvent.MOUSE_UP
      */
     private static function doMouseUp(event:MouseEvent):void{
        if(resizeObj != null){
          initPosition(resizeObj);
        }
        resizeObj = null;
     }
     
     /**
      * Show the mouse arrow when not draging.
      * Call doResize(event) to resize resizeObj when mouse is inside the resizeObj area.
      * @param The MouseEvent.MOUSE_MOVE
      */
     private static function doMouseMove(event:MouseEvent):void{
       
        
        var thisObj:UIComponent = UIComponent(event.currentTarget);
        var point:Point = new Point();
          
        point = thisObj.localToGlobal(point);
        
        if(resizeObj == null){
          var xPosition:Number = Application.application.parent.mouseX;
          var yPosition:Number = Application.application.parent.mouseY;
          if(xPosition >= (point.x + thisObj.width - mouseMargin) && yPosition >= (point.y + thisObj.height - mouseMargin)){
            CursorUtil.changeCursor(leftObliqueSize, -6, -6); 
            mouseState = SIDE_RIGHT | SIDE_BOTTOM;
          }else if(xPosition <= (point.x + mouseMargin) && yPosition <= (point.y + mouseMargin)){
            CursorUtil.changeCursor(leftObliqueSize, -6, -6);
            mouseState = SIDE_LEFT | SIDE_TOP;
          }else if(xPosition <= (point.x + mouseMargin) && yPosition >= (point.y + thisObj.height - mouseMargin)){
            CursorUtil.changeCursor(rightObliqueSize, -6, -6);
            mouseState = SIDE_LEFT | SIDE_BOTTOM;
          }else if(xPosition >= (point.x + thisObj.width - mouseMargin) && yPosition <= (point.y + mouseMargin)){
            CursorUtil.changeCursor(rightObliqueSize, -6, -6);
            mouseState = SIDE_RIGHT | SIDE_TOP;
          }else if(xPosition >= (point.x + thisObj.width - mouseMargin)){
            CursorUtil.changeCursor(horizontalSize, -9, -9);
            mouseState = SIDE_RIGHT;
          }else if(xPosition <= (point.x + mouseMargin)){
            CursorUtil.changeCursor(horizontalSize, -9, -9);
            mouseState = SIDE_LEFT;
          }else if(yPosition >= (point.y + thisObj.height - mouseMargin)){
            CursorUtil.changeCursor(verticalSize, -9, -9);
            mouseState = SIDE_BOTTOM;
          }else if(yPosition <= (point.y + mouseMargin)){
            CursorUtil.changeCursor(verticalSize, -9, -9);
            mouseState = SIDE_TOP;
          }else{
            CursorUtil.changeCursor(null, 0, 0);
            mouseState = SIDE_OTHER;
          }
          
          if(thisObj.getStyle("isPopup")){
         //When cursor is move arrow, disable popup
            if( mouseState != SIDE_OTHER){
              thisObj.isPopUp = false;
            }else{
              thisObj.isPopUp = true;
            }
          }
        }
        
        //Use SystemManager to listen the mouse reize event, so we needn't handle the event at the current object.
        //doResize(event);
     }
    
     /**
      * Hide the arrow when not draging and moving out the resizeObj.
      * @param The MouseEvent.MOUSE_MOVE
      */
     private static function doMouseOut(event:MouseEvent):void{
        if(resizeObj == null){
          CursorUtil.changeCursor(null, 0, 0);
          mouseState = SIDE_OTHER;
        }
     }
    
     /**
      * Resize when the draging resizeObj, resizeObj is not null.
      * @param The MouseEvent.MOUSE_MOVE
      */
     private static function doResize(event:MouseEvent):void{
       
       if(resizeObj != null){
         
         var point:Point = Point(resizeObj.getStyle("oPoint"));
         
         var xPlus:Number = Application.application.parent.mouseX - point.x;
       var yPlus:Number = Application.application.parent.mouseY - point.y;
         
         var windowMinSize:Number = Number(resizeObj.getStyle("minSize"));
         
         var ow:Number = Number(resizeObj.getStyle("oWidth"));
         var oh:Number = Number(resizeObj.getStyle("oHeight"));
         var oX:Number = Number(resizeObj.getStyle("oX"));
         var oY:Number = Number(resizeObj.getStyle("oY"))
         
        switch(mouseState){
         
          case SIDE_RIGHT | SIDE_BOTTOM:
            resizeObj.width = ow + xPlus > windowMinSize ? ow + xPlus : windowMinSize;
            resizeObj.height = oh + yPlus > windowMinSize ? oh + yPlus : windowMinSize;
            break;
            
          case SIDE_LEFT | SIDE_TOP:
            resizeObj.width = ow - xPlus > windowMinSize ? ow - xPlus : windowMinSize;
            resizeObj.height = oh - yPlus > windowMinSize ? oh - yPlus : windowMinSize;
            resizeObj.x = xPlus < ow - windowMinSize ? oX + xPlus: resizeObj.x;
            resizeObj.y = yPlus < oh - windowMinSize ? oY + yPlus : resizeObj.y;
            break;
   
        case SIDE_LEFT | SIDE_BOTTOM:
            resizeObj.width = ow - xPlus > windowMinSize ? ow - xPlus : windowMinSize;
            resizeObj.height = oh + yPlus > windowMinSize ? oh + yPlus : windowMinSize;
            resizeObj.x = xPlus < ow - windowMinSize ? oX + xPlus: resizeObj.x;
            break;
            
          case SIDE_RIGHT | SIDE_TOP:
            resizeObj.width = ow + xPlus > windowMinSize ? ow + xPlus : windowMinSize;
            resizeObj.height = oh - yPlus > windowMinSize ? oh - yPlus : windowMinSize;
            resizeObj.y = yPlus < oh - windowMinSize ? oY + yPlus : resizeObj.y;
            break;
            
          case SIDE_RIGHT:
            resizeObj.width = ow + xPlus > windowMinSize ? ow + xPlus : windowMinSize;
            break;
            
          case SIDE_LEFT:
            resizeObj.width = ow - xPlus > windowMinSize ? ow - xPlus : windowMinSize;
            resizeObj.x = xPlus < ow - windowMinSize ? oX + xPlus: resizeObj.x;
            break;
            
          case SIDE_BOTTOM:resizeObj.height = oh + yPlus > windowMinSize ? oh + yPlus : windowMinSize;
            break;
            
          case SIDE_TOP:
            resizeObj.height = oh - yPlus > windowMinSize ? oh - yPlus : windowMinSize;
            resizeObj.y = yPlus < oh - windowMinSize ? oY + yPlus : resizeObj.y;
            break;
          }       
        }      
     }    
   }  
}