/**
 * @author risker
 **/
package com.fl.vo
{
	/**
	 *  The EdgeMetrics class specifies the thickness, in pixels,
	 *  of the four edge regions around a visual component.
	 **/
	public class EdgeMetrics {
		/**
		 *  An EdgeMetrics object with a value of zero for its
		 *  <code>left</code>, <code>top</code>, <code>right</code>,
		 *  and <code>bottom</code> properties.
		 */
		public static const EMPTY:EdgeMetrics = new EdgeMetrics(0, 0, 0, 0);
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *
		 *  @param left The width, in pixels, of the left edge region.
		 *
		 *  @param top The height, in pixels, of the top edge region.
		 *
		 *  @param right The width, in pixels, of the right edge region.
		 *
		 *  @param bottom The height, in pixels, of the bottom edge region.
		 */
		public function EdgeMetrics(left:Number = 0, top:Number = 0,
									right:Number = 0, bottom:Number = 0)
		{
			super();
			
			this.left = left;
			this.top = top;
			this.right = right;
			this.bottom = bottom;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  bottom
		//----------------------------------
		
		/**
		 *  The height, in pixels, of the bottom edge region.
		 */
		public var bottom:Number;
		
		//----------------------------------
		//  left
		//----------------------------------
		
		/**
		 *  The width, in pixels, of the left edge region.
		 */
		public var left:Number;
		
		//----------------------------------
		//  right
		//----------------------------------
		
		/**
		 *  The width, in pixels, of the right edge region.
		 */
		public var right:Number;
		
		//----------------------------------
		//  top
		//----------------------------------
		
		/**
		 *  The height, in pixels, of the top edge region.
		 */
		public var top:Number;
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
        public function get pw():Number {
            return left + right;
        }
        public function get ph():Number {
            return top + bottom;
        }
        
		/**
		 *  Returns a copy of this EdgeMetrics object.
		 */
		public function clone():EdgeMetrics
		{
			return new EdgeMetrics(left, top, right, bottom);
		}
        
        public function checkNaN(v:Number = 0):void {
            if(isNaN(left)) left = v;
            if(isNaN(right)) right = v;
            if(isNaN(top)) top = v;
            if(isNaN(bottom)) bottom = v;
        }
        
        public function reset(v:Number = 0):void {
            left = v;
            right = v;
            top = v;
            bottom = v;
        }
	}
}