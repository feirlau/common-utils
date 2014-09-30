/**
 * @author risker
 **/
package com.fl.skin {
	import com.fl.style.StyleEvent;
	import com.fl.utils.LogUtil;
	import com.fl.utils.SkinUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	
	/**
	 * style 
	 **/
	public class TiledBorderSkin extends Skin {
        private var _imgStyles:Array = [];
        override protected function initStyle():void {
            _imgStyles.push("leftTopImage", "topImage", "rightTopImage", "leftImage", "centerImage", "rightImage",
				"leftBottomImage", "bottomImage", "rightBottomImage");
            _selfStyles.splice(_selfStyles.length, 0, _imgStyles);
            super.initStyle();
        }
        
		private var scaleGrid:Rectangle;
		override protected function render():void {
			super.render();
			
			var unscaledWidth:Number = width;
			var unscaledHeight:Number = height;
			
			graphics.clear();
			scaleGrid ||= new Rectangle();
			if(leftTopImage) {
				scaleGrid.left = leftTopImage.width;
				scaleGrid.top = leftTopImage.height;
			} else {
				scaleGrid.left = 0;
				scaleGrid.top = 0;
			}
			if(rightTopImage) {
				scaleGrid.right = unscaledWidth - rightTopImage.width;
			} else {
				scaleGrid.right = unscaledWidth;
			}
			if(leftBottomImage) {
				scaleGrid.bottom = unscaledHeight - leftBottomImage.height;
			} else {
				scaleGrid.bottom = unscaledHeight;
			}
			
			var tmpRect:Rectangle = new Rectangle(0, 0, scaleGrid.left, scaleGrid.top);
			drawStyleImage(leftTopImage, tmpRect);
			
			tmpRect.x = scaleGrid.left;
			tmpRect.y = 0;
			tmpRect.width = scaleGrid.right - scaleGrid.left;
			tmpRect.height = scaleGrid.top;
			drawStyleImage(topImage, tmpRect);
			
			tmpRect.x = scaleGrid.right;
			tmpRect.y = 0;
			tmpRect.width = unscaledWidth - scaleGrid.right;
			tmpRect.height = scaleGrid.top;
			drawStyleImage(rightTopImage, tmpRect);
			
			tmpRect.x = 0;
			tmpRect.y = scaleGrid.top;
			tmpRect.width = scaleGrid.left;
			tmpRect.height = scaleGrid.bottom - scaleGrid.top;
			drawStyleImage(leftImage, tmpRect);
			
			tmpRect.x = scaleGrid.left;
			tmpRect.y = scaleGrid.top;
			tmpRect.width = scaleGrid.right - scaleGrid.left;
			tmpRect.height = scaleGrid.bottom - scaleGrid.top;
			drawStyleImage(centerImage, tmpRect);
			
			tmpRect.x = scaleGrid.right;
			tmpRect.y = scaleGrid.top;
			tmpRect.width = unscaledWidth - scaleGrid.right;
			tmpRect.height = scaleGrid.bottom - scaleGrid.top;
			drawStyleImage(rightImage, tmpRect);
			
			tmpRect.x = 0;
			tmpRect.y = scaleGrid.bottom;
			tmpRect.width = scaleGrid.left;
			tmpRect.height = unscaledHeight - scaleGrid.bottom;
			drawStyleImage(leftBottomImage, tmpRect);
			
			tmpRect.x = scaleGrid.left;
			tmpRect.y = scaleGrid.bottom;
			tmpRect.width = scaleGrid.right - scaleGrid.left;
			tmpRect.height = unscaledHeight - scaleGrid.bottom;
			drawStyleImage(bottomImage, tmpRect);
			
			tmpRect.x = scaleGrid.right;
			tmpRect.y = scaleGrid.bottom;
			tmpRect.width = unscaledWidth - scaleGrid.right;
			tmpRect.height = unscaledHeight - scaleGrid.bottom;
			drawStyleImage(rightBottomImage, tmpRect);
			
			graphics.endFill();
		}
		private function drawStyleImage(img:Bitmap, rect:Rectangle):void {
			if(img && img.width > 0 && img.height > 0 && img.bitmapData && rect && rect.width > 0 && rect.height > 0) {
				graphics.beginBitmapFill(img.bitmapData, new Matrix(1, 0, 0, 1, rect.x, rect.y), true);
				graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			}
		}
		private var leftTopImage:Bitmap;
		private var topImage:Bitmap;
		private var rightTopImage:Bitmap;
		private var leftImage:Bitmap;
		private var centerImage:Bitmap;
		private var rightImage:Bitmap;
		private var leftBottomImage:Bitmap;
		private var bottomImage:Bitmap;
		private var rightBottomImage:Bitmap;
		private function updateStyleProp(styleProp:String):void {
			try {
				var tmpC:* = getStyle(styleProp);
				if(tmpC is String) {
                    try {
                        tmpC = getDefinitionByName(tmpC);
                    } catch(e:Error) {
						LogUtil.addLog(this, ["updateStyleProp", e.getStackTrace()], LogUtil.ERROR);
                    }
				}
				if(tmpC) {
					this[styleProp] = new tmpC();
				}
			} catch(err:Error) {
				trace(err.getStackTrace());
			}
		}
		
		override public function updateStyle(styleP:String=null):void {
            super.updateStyle(styleP);
            if(acceptStyle(styleP)) {
                var tmpS:String;
                for each(tmpS in _imgStyles) {
                    if(styleP == null || tmpS == styleP) {
                        updateStyleProp(tmpS);
                    }
                }
                invalidate(INVALIDATE_PROP);
            }
        }
	}
}