/**
 * @author risker
 **/
package com.fl.skin {
    import com.fl.style.StyleEvent;
    import com.fl.utils.ColorUtil;
    import com.fl.utils.GraphicsUtil;
    
    import flash.display.DisplayObjectContainer;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.events.Event;
    import com.fl.vo.EdgeMetrics;
	
	/***
	 * styles {
	 * 	borderStyle: default/none/solid/inset/outset, borderColor: #000000, borderAlpha: 1, borderThickness: 2, borderSides: left top right bottom,
	 *  cornerRadius: 2, roundedBottomCorners: false,
	 *  backgroundColor: #000000, backgroundAlpha: 1,
	 *  mouseShield: false, mouseShieldChildren: false,
	 * }
	 */
    public class GraphicsBorderSkin extends Skin {
        /**
         *  @private
         *  A look up table for the offsets.
         */
        private static var BORDER_WIDTHS:Object =
            {
                none: 0,
                solid: 1,
                inset: 2,
                outset: 2
            };

        public function GraphicsBorderSkin() {
            super();
			
			
			BORDER_WIDTHS["default"] = 3;
        }
        
        override protected function initStyle():void {
			_selfStyles.push("borderStyle", "borderColor", "borderAlpha", "borderThickness", "borderSides",
				"cornerRadius", "roundedBottomCorners", "backgroundColor", "backgroundAlpha",
				"mouseShield", "mouseShieldChildren");
            super.initStyle();
        }
        /**
         *  @private
         *  Internal object that contains the thickness of each edge
         *  of the border
         */
        protected var _borderMetrics:EdgeMetrics;

        /**
         *  @private
         *  Return the thickness of the border edges.
         *
         *  @return Object	top, bottom, left, right thickness in pixels
         */
        public function get borderMetrics():EdgeMetrics {
            if(_borderMetrics)
                return _borderMetrics;

            var borderThickness:Number;

            // Add support for "custom" style type here when we support it.
            var borderStyle:String = getStyle("borderStyle");

            if(borderStyle == "default") {
                return EdgeMetrics.EMPTY;
            }

            else if(borderStyle == "solid") {
                borderThickness = getStyle("borderThickness");
                if(isNaN(borderThickness))
                    borderThickness = 0;

                _borderMetrics = new EdgeMetrics(borderThickness,
                                                 borderThickness,
                                                 borderThickness,
                                                 borderThickness);

                var borderSides:String = getStyle("borderSides");
                if(borderSides != "left top right bottom") {
                    // Adjust metrics based on which sides we have				
                    if(borderSides.indexOf("left") == -1)
                        _borderMetrics.left = 0;

                    if(borderSides.indexOf("top") == -1)
                        _borderMetrics.top = 0;

                    if(borderSides.indexOf("right") == -1)
                        _borderMetrics.right = 0;

                    if(borderSides.indexOf("bottom") == -1)
                        _borderMetrics.bottom = 0;
                }
            }

            else {
                borderThickness = BORDER_WIDTHS[borderStyle];
                if(isNaN(borderThickness))
                    borderThickness = 0;

                _borderMetrics = new EdgeMetrics(borderThickness,
                                                 borderThickness,
                                                 borderThickness,
                                                 borderThickness);
            }
            _borderMetrics.checkNaN();
            
            return _borderMetrics;
        }

        override protected function styleHandler(env:StyleEvent = null):void {
			super.styleHandler(env);
            var styleProp:* = env.data;
			if(acceptStyle(styleProp)) {
	            if(styleProp == null ||
					styleProp == "borderStyle" ||
	                styleProp == "borderThickness" ||
	                styleProp == "borderSides") {
	                _borderMetrics = null;
	            }
	            invalidate(INVALIDATE_PROP);
			}
        }
		
		protected var backgroundHole:Object;
		protected var bRoundedCorners:Boolean;
		protected var radius:Number;
		protected var radiusObj:Object;
		/**
		 *  @private
		 *  Draw the border, either 3D or 2D or nothing at all.
		 */
        override protected function render():void {	
			super.render();
			
			bRoundedCorners = false;
			backgroundHole = null;
			radius = 0;
			radiusObj = null;
			
			drawBorder();		
			drawBackground();	
		}
		
		/**
		 *  @private
		 */
		protected function drawBorder():void
		{
			var w:Number = width;
			var h:Number = height;
			
			var backgroundColor:Number = getStyle("backgroundColor");
			
			var borderStyle:String = getStyle("borderStyle");
			var borderColor:uint = getStyle("borderColor");
			
			var borderSides:String;
			var borderThickness:Number;
			
			var hole:Object;
			
			var borderColorDrk1:Number
			var borderColorDrk2:Number
			var borderColorLt1:Number
			
			var borderInnerColor:Object;
			
			var g:Graphics = graphics;
			g.clear();
			
			if (borderStyle)
			{
				switch (borderStyle)
				{
					case "none":
					{
						break;
					}
						
					case "inset": // used for text input & numeric stepper
					{
						borderColorDrk1 =
							ColorUtil.adjustBrightness2(borderColor, -40);
						borderColorDrk2 =
							ColorUtil.adjustBrightness2(borderColor, +25);
						borderColorLt1 = 
							ColorUtil.adjustBrightness2(borderColor, +40);
						
						borderInnerColor = backgroundColor;
						if (borderInnerColor === null ||
							borderInnerColor === "")
						{
							borderInnerColor = borderColor;
						}
						
						draw3dBorder(borderColorDrk2, borderColorDrk1, borderColorLt1,
							Number(borderInnerColor), 
							Number(borderInnerColor), 
							Number(borderInnerColor));
						break;
					}
						
					case "outset":
					{
						borderColorDrk1 =
							ColorUtil.adjustBrightness2(borderColor, -40);
						borderColorDrk2 =
							ColorUtil.adjustBrightness2(borderColor, -25);
						borderColorLt1 = 
							ColorUtil.adjustBrightness2(borderColor, +40);
						
						borderInnerColor = backgroundColor;
						if (borderInnerColor === null ||
							borderInnerColor === "")
						{
							borderInnerColor = borderColor;
						}
						
						draw3dBorder(borderColorDrk2, borderColorLt1, borderColorDrk1,
							Number(borderInnerColor), 
							Number(borderInnerColor), 
							Number(borderInnerColor));
						break;
					}
					
					case "default":
					{
						break;
					}
						
					default: // ((borderStyle == "solid") || (borderStyle == null))
					{
						borderThickness = getStyle("borderThickness");
						borderSides = getStyle("borderSides");
						var bHasAllSides:Boolean = true;
						radius = getStyle("cornerRadius");
						
						bRoundedCorners =
							getStyle("roundedBottomCorners").toString().toLowerCase() == "true";
						
						var holeRadius:Number =
							Math.max(radius - borderThickness, 0);
						
						hole = { x: borderThickness,
							y: borderThickness,
							w: w - borderThickness * 2,
								h: h - borderThickness * 2,
								r: holeRadius };
						
						if (!bRoundedCorners)
						{
							radiusObj = {tl:radius, tr:radius, bl:0, br:0};
							hole.r = {tl:holeRadius, tr:holeRadius, bl:0, br:0};
						}
						
						if (borderSides != "left top right bottom")
						{
							// Convert the radius values from a scalar to an object
							// because we need to adjust individual radius values
							// if we are missing any sides.
							hole.r = { tl: holeRadius,
								tr: holeRadius,
								bl: bRoundedCorners ? holeRadius : 0,
									br: bRoundedCorners ? holeRadius : 0 };
							
							radiusObj = { tl: radius,
								tr: radius,
								bl: bRoundedCorners ? radius : 0,
									br: bRoundedCorners ? radius : 0};
							
							borderSides = borderSides.toLowerCase();
							
							if (borderSides.indexOf("left") == -1)
							{
								hole.x = 0;
								hole.w += borderThickness;
								hole.r.tl = 0;
								hole.r.bl = 0;
								radiusObj.tl = 0;
								radiusObj.bl = 0;
								bHasAllSides = false;
							}
							
							if (borderSides.indexOf("top") == -1)
							{
								hole.y = 0;
								hole.h += borderThickness;
								hole.r.tl = 0;
								hole.r.tr = 0;
								radiusObj.tl = 0;
								radiusObj.tr = 0;
								bHasAllSides = false;
							}
							
							if (borderSides.indexOf("right") == -1)
							{
								hole.w += borderThickness;
								hole.r.tr = 0;
								hole.r.br = 0;
								radiusObj.tr = 0;
								radiusObj.br = 0;
								bHasAllSides = false;
							}
							
							if (borderSides.indexOf("bottom") == -1)
							{
								hole.h += borderThickness;
								hole.r.bl = 0;
								hole.r.br = 0;
								radiusObj.bl = 0;
								radiusObj.br = 0;
								bHasAllSides = false;
							}
						}
						
						if (radius == 0 && bHasAllSides)
						{
							g.beginFill(borderColor);
							g.drawRect(0, 0, w, h);
							g.drawRect(borderThickness, borderThickness,
								w - 2 * borderThickness,
								h - 2 * borderThickness);
							g.endFill();
						}
						else if (radiusObj)
						{
							GraphicsUtil.drawRoundRect(g,
								0, 0, w, h, radiusObj,
								borderColor, 1,
								null, null, null, hole);
							
							// Reset radius here so background drawing
							// below is correct.
							radiusObj.tl = Math.max(radius - borderThickness, 0);
							radiusObj.tr = Math.max(radius - borderThickness, 0);
							radiusObj.bl = bRoundedCorners ? Math.max(radius - borderThickness, 0) : 0;
							radiusObj.br = bRoundedCorners ? Math.max(radius - borderThickness, 0) : 0;
						}
						else
						{
							GraphicsUtil.drawRoundRect(g,
								0, 0, w, h, radius,
								borderColor, 1,
								null, null, null, hole);
							
							// Reset radius here so background drawing
							// below is correct.
							radius = Math.max(getStyle("cornerRadius") -
								borderThickness, 0);
						}									
					}
				} // switch
			}
		}
		
		
		/**
		 *  @private
		 *  Draw a 3D border.
		 */
		protected function draw3dBorder(c1:Number, c2:Number, c3:Number,
										  c4:Number, c5:Number, c6:Number):void {
			var w:Number = width;
			var h:Number = height;
			
			var g:Graphics = graphics;
			
			// outside sides
			g.beginFill(c1);
			g.drawRect(0, 0, w, h);
			g.drawRect(1, 0, w - 2, h);
			g.endFill();
			
			// outside top
			g.beginFill(c2);
			g.drawRect(1, 0, w - 2, 1);
			g.endFill();
			
			// outside bottom
			g.beginFill(c3);
			g.drawRect(1, h - 1, w - 2, 1);
			g.endFill();
			
			// inside top
			g.beginFill(c4);
			g.drawRect(1, 1, w - 2, 1);
			g.endFill();
			
			// inside bottom
			g.beginFill(c5);
			g.drawRect(1, h - 2, w - 2, 1);
			g.endFill();
			
			// inside sides
			g.beginFill(c6);
			g.drawRect(1, 2, w - 2, h - 4);
			g.drawRect(2, 2, w - 4, h - 4);
			g.endFill();
		}
		
		/**
		 *  @private
		 */
		protected function drawBackground():void {
			var w:Number = width;
			var h:Number = height;
			
			var backgroundColor:* = getStyle("backgroundColor");
			
			// The behavior used to be that we always create a background
			// regardless of whether we have a background color or not.
			// Now we only create a background if we have a color
			// or if the mouseShield or mouseShieldChildren styles are true.
			// Look at Container.addEventListener and Container.isBorderNeeded
			// for the mouseShield logic. JCS 6/24/05
			if ((backgroundColor !== null &&
				backgroundColor !== "") ||
				getStyle("mouseShield") ||
				getStyle("mouseShieldChildren"))
			{
				var nd:Number = Number(backgroundColor);
				var alpha:Number = 1.0;
				var bm:EdgeMetrics = borderMetrics;
				var g:Graphics = graphics;
				
				if (isNaN(nd) ||
					backgroundColor === "" ||
					backgroundColor === null)
				{
					alpha = 0;
					nd = 0xFFFFFF;
				}
				else
				{
					alpha = getStyle("backgroundAlpha");
				}
				
				// If we have a non-zero radius, use drawRoundRect()
				// to fill in the background.
				if (radius != 0 || backgroundHole)
				{			
					var bottom:Number = bm.bottom;
					
					if (radiusObj)
					{
						var topRadius:Number =
							Math.max(radius - Math.max(bm.top, bm.left, bm.right), 0);
						var bottomRadius:Number = bRoundedCorners ?
							Math.max(radius - Math.max(bm.bottom, bm.left, bm.right), 0) : 0;
						
						radiusObj = { tl: topRadius,
							tr: topRadius,
							bl: bottomRadius,
							br: bottomRadius };
						
						GraphicsUtil.drawRoundRect(g,
							bm.left, bm.top,
							w - (bm.left + bm.right),
							h - (bm.top + bottom), 
							radiusObj,
							nd, alpha, null,
							GradientType.LINEAR, null,
							backgroundHole);
					}
					else
					{
						GraphicsUtil.drawRoundRect(g,
							bm.left, bm.top,
							w - (bm.left + bm.right),
							h - (bm.top + bottom), 
							radius,
							nd, alpha, null,
							GradientType.LINEAR, null,
							backgroundHole);
					}
				}
				else
				{
					g.beginFill(nd, alpha);
					g.drawRect(bm.left, bm.top,
						w - bm.right - bm.left, h - bm.bottom - bm.top);
					g.endFill();
				}
			}
		}
    }
}
