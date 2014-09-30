/**
 * @author risker
 **/
package com.fl.utils {
	import flash.display.Graphics;
	import flash.geom.Matrix;

    public class GraphicsUtil {
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Draws a rounded rectangle using the size of a radius to draw the rounded corners. 
		 * You must set the line style, fill, or both 
		 * on the Graphics object before 
		 * you call the <code>drawRoundRectComplex()</code> method 
		 * by calling the <code>linestyle()</code>, 
		 * <code>lineGradientStyle()</code>, <code>beginFill()</code>, 
		 * <code>beginGradientFill()</code>, or 
		 * <code>beginBitmapFill()</code> method.
		 * 
		 * @param graphics The Graphics object that draws the rounded rectangle.
		 *
		 * @param x The horizontal position relative to the 
		 * registration point of the parent display object, in pixels.
		 * 
		 * @param y The vertical position relative to the 
		 * registration point of the parent display object, in pixels.
		 * 
		 * @param width The width of the round rectangle, in pixels.
		 * 
		 * @param height The height of the round rectangle, in pixels.
		 * 
		 * @param topLeftRadius The radius of the upper-left corner, in pixels.
		 * 
		 * @param toRightRadius The radius of the upper-right corner, in pixels.
		 * 
		 * @param bottomLeftRadius The radius of the bottom-left corner, in pixels.
		 * 
		 * @param bottomRightRadius The radius of the bottom-right corner, in pixels.
		 *
		 */
		public static function drawRoundRectComplex(graphics:Graphics, x:Number, y:Number, 
													width:Number, height:Number, 
													topLeftRadius:Number, topRightRadius:Number, 
													bottomLeftRadius:Number, bottomRightRadius:Number):void
		{
			var xw:Number = x + width;
			var yh:Number = y + height;
			
			// Make sure none of the radius values are greater than w/h.
			// These are all inlined to avoid function calling overhead
			var minSize:Number = width < height ? width * 2 : height * 2;
			topLeftRadius = topLeftRadius < minSize ? topLeftRadius : minSize;
			topRightRadius = topRightRadius < minSize ? topRightRadius : minSize;
			bottomLeftRadius = bottomLeftRadius < minSize ? bottomLeftRadius : minSize;
			bottomRightRadius = bottomRightRadius < minSize ? bottomRightRadius : minSize;
			
			// Math.sin and Math,tan values for optimal performance.
			// Math.rad = Math.PI / 180 = 0.0174532925199433
			// r * Math.sin(45 * Math.rad) =  (r * 0.707106781186547);
			// r * Math.tan(22.5 * Math.rad) = (r * 0.414213562373095);
			//
			// We can save further cycles by precalculating
			// 1.0 - 0.707106781186547 = 0.292893218813453 and
			// 1.0 - 0.414213562373095 = 0.585786437626905
			
			// bottom-right corner
			var a:Number = bottomRightRadius * 0.292893218813453;		// radius - anchor pt;
			var s:Number = bottomRightRadius * 0.585786437626905; 	// radius - control pt;
			graphics.moveTo(xw, yh - bottomRightRadius);
			graphics.curveTo(xw, yh - s, xw - a, yh - a);
			graphics.curveTo(xw - s, yh, xw - bottomRightRadius, yh);
			
			// bottom-left corner
			a = bottomLeftRadius * 0.292893218813453;
			s = bottomLeftRadius * 0.585786437626905;
			graphics.lineTo(x + bottomLeftRadius, yh);
			graphics.curveTo(x + s, yh, x + a, yh - a);
			graphics.curveTo(x, yh - s, x, yh - bottomLeftRadius);
			
			// top-left corner
			a = topLeftRadius * 0.292893218813453;
			s = topLeftRadius * 0.585786437626905;
			graphics.lineTo(x, y + topLeftRadius);
			graphics.curveTo(x, y + s, x + a, y + a);
			graphics.curveTo(x + s, y, x + topLeftRadius, y);
			
			// top-right corner
			a = topRightRadius * 0.292893218813453;
			s = topRightRadius * 0.585786437626905;
			graphics.lineTo(xw - topRightRadius, y);
			graphics.curveTo(xw - s, y, xw - a, y + a);
			graphics.curveTo(xw, y + s, xw, y + topRightRadius);
			graphics.lineTo(xw, yh - bottomRightRadius);
		}
		
		/**
		 *  Programatically draws a rectangle into this skin's Graphics object.
		 *
		 *  <p>The rectangle can have rounded corners.
		 *  Its edges are stroked with the current line style
		 *  of the Graphics object.
		 *  It can have a solid color fill, a gradient fill, or no fill.
		 *  A solid fill can have an alpha transparency.
		 *  A gradient fill can be linear or radial. You can specify
		 *  up to 15 colors and alpha values at specified points along
		 *  the gradient, and you can specify a rotation angle
		 *  or transformation matrix for the gradient.
		 *  Finally, the rectangle can have a rounded rectangular hole
		 *  carved out of it.</p>
		 *
		 *  <p>This versatile rectangle-drawing routine is used by many skins.
		 *  It calls the <code>drawRect()</code> or
		 *  <code>drawRoundRect()</code>
		 *  methods (in the flash.display.Graphics class) to draw into this
		 *  skin's Graphics object.</p>
		 *
		 *	@param x Horizontal position of upper-left corner
		 *  of rectangle within this skin.
		 *
		 *	@param y Vertical position of upper-left corner
		 *  of rectangle within this skin.
		 *
		 *	@param width Width of rectangle, in pixels.
		 *
		 *	@param height Height of rectangle, in pixels.
		 *
		 *	@param cornerRadius Corner radius/radii of rectangle.
		 *  Can be <code>null</code>, a Number, or an Object.
		 *  If it is <code>null</code>, it specifies that the corners should be square
		 *  rather than rounded.
		 *  If it is a Number, it specifies the same radius, in pixels,
		 *  for all four corners.
		 *  If it is an Object, it should have properties named
		 *  <code>tl</code>, <code>tr</code>, <code>bl</code>, and
		 *  <code>br</code>, whose values are Numbers specifying
		 *  the radius, in pixels, for the top left, top right,
		 *  bottom left, and bottom right corners.
		 *  For example, you can pass a plain Object such as
		 *  <code>{ tl: 5, tr: 5, bl: 0, br: 0 }</code>.
		 *  The default value is null (square corners).
		 *
		 *	@param color The RGB color(s) for the fill.
		 *  Can be <code>null</code>, a uint, or an Array.
		 *  If it is <code>null</code>, the rectangle not filled.
		 *  If it is a uint, it specifies an RGB fill color.
		 *  For example, pass <code>0xFF0000</code> to fill with red.
		 *  If it is an Array, it should contain uints
		 *  specifying the gradient colors.
		 *  For example, pass <code>[ 0xFF0000, 0xFFFF00, 0x0000FF ]</code>
		 *  to fill with a red-to-yellow-to-blue gradient.
		 *  You can specify up to 15 colors in the gradient.
		 *  The default value is null (no fill).
		 *
		 *	@param alpha Alpha value(s) for the fill.
		 *  Can be null, a Number, or an Array.
		 *  This argument is ignored if <code>color</code> is null.
		 *  If <code>color</code> is a uint specifying an RGB fill color,
		 *  then <code>alpha</code> should be a Number specifying
		 *  the transparency of the fill, where 0.0 is completely transparent
		 *  and 1.0 is completely opaque.
		 *  You can also pass null instead of 1.0 in this case
		 *  to specify complete opaqueness.
		 *  If <code>color</code> is an Array specifying gradient colors,
		 *  then <code>alpha</code> should be an Array of Numbers, of the
		 *  same length, that specifies the corresponding alpha values
		 *  for the gradient.
		 *  In this case, the default value is <code>null</code> (completely opaque).
		 *
		 *  @param gradientMatrix Matrix object used for the gradient fill. 
		 *  The utility methods <code>horizontalGradientMatrix()</code>, 
		 *  <code>verticalGradientMatrix()</code>, and
		 *  <code>rotatedGradientMatrix()</code> can be used to create the value for 
		 *  this parameter.
		 *
		 *	@param gradientType Type of gradient fill. The possible values are
		 *  <code>GradientType.LINEAR</code> or <code>GradientType.RADIAL</code>.
		 *  (The GradientType class is in the package flash.display.)
		 *
		 *	@param gradientRatios (optional default [0,255])
		 *  Specifies the distribution of colors. The number of entries must match
		 *  the number of colors defined in the <code>color</code> parameter.
		 *  Each value defines the percentage of the width where the color is 
		 *  sampled at 100%. The value 0 represents the left-hand position in 
		 *  the gradient box, and 255 represents the right-hand position in the 
		 *  gradient box. 
		 *
		 *	@param hole (optional) A rounded rectangular hole
		 *  that should be carved out of the middle
		 *  of the otherwise solid rounded rectangle
		 *  { x: #, y: #, w: #, h: #, r: # or { br: #, bl: #, tl: #, tr: # } }
		 *
		 *  @see flash.display.Graphics#beginGradientFill()
		 */
		public static function drawRoundRect(graphics:Graphics,
			x:Number, y:Number, width:Number, height:Number,
			cornerRadius:Object = null,
			color:Object = null,
			alpha:Object = null,
			gradientMatrix:Matrix = null,
			gradientType:String = "linear",
			gradientRatios:Array /* of Number */ = null,
			hole:Object = null):void
		{
			var g:Graphics = graphics;
			
			// Quick exit if weight or height is zero.
			// This happens when scaling a component to a very small value,
			// which then gets rounded to 0.
			if (width == 0 || height == 0)
				return;
			
			// If color is an object then allow for complex fills.
			if (color !== null)
			{
				if (color is uint)
				{
					g.beginFill(uint(color), Number(alpha));
				}
				else if (color is Array)
				{
					var alphas:Array = alpha is Array ?
						alpha as Array :
						[ alpha, alpha ];
					
					if (!gradientRatios)
						gradientRatios = [ 0, 0xFF ];
					
					g.beginGradientFill(gradientType,
						color as Array, alphas,
						gradientRatios, gradientMatrix);
				}
			}
			
			var ellipseSize:Number;
			
			// Stroke the rectangle.
			if (!cornerRadius)
			{
				g.drawRect(x, y, width, height);
			}
			else if (cornerRadius is Number)
			{
				ellipseSize = Number(cornerRadius) * 2;
				g.drawRoundRect(x, y, width, height, 
					ellipseSize, ellipseSize);
			}
			else
			{
				GraphicsUtil.drawRoundRectComplex(g,
					x, y, width, height,
					cornerRadius.tl, cornerRadius.tr,
					cornerRadius.bl, cornerRadius.br);
			}
			
			// Carve a rectangular hole out of the middle of the rounded rect.
			if (hole)
			{
				var holeR:Object = hole.r;
				if (holeR is Number)
				{
					ellipseSize = Number(holeR) * 2;
					g.drawRoundRect(hole.x, hole.y, hole.w, hole.h, 
						ellipseSize, ellipseSize);
				}
				else
				{
					GraphicsUtil.drawRoundRectComplex(g,
						hole.x, hole.y, hole.w, hole.h,
						holeR.tl, holeR.tr, holeR.bl, holeR.br);
				}	
			}
			
			if (color !== null)
				g.endFill();
		}
    }
}
