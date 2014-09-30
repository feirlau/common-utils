/**
 * @author risker
 * Dec 20, 2013
 **/
package com.fl.tooltip {
    import flash.geom.Rectangle;

    public interface ITooltip {
        //----------------------------------
        //  text
        //----------------------------------
        
        /**
         *  The data that appears in the tooltip.
         */
        function get data():*;
        
        /**
         *  @private
         */
        function set data(value:*):void;
    }
}
