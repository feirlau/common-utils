/**
 * @author risker
 * Oct 16, 2013
 **/
package com.fl.constants {

    public class ScrollPolicyConstants {
        /**
         *  Show the scrollbar if the children exceed the owner's dimension.
         *  The size of the owner is not adjusted to account
         *  for the scrollbars when they appear, so this may cause the
         *  scrollbar to obscure the contents of the control or container.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static const AUTO:String = "auto";
        
        /**
         *  Never show the scrollbar.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static const OFF:String = "off";
        
        /**
         *  Always show the scrollbar.
         *  The size of the scrollbar is automatically added to the size
         *  of the owner's contents to determine the size of the owner
         *  if explicit sizes are not specified.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static const ON:String = "on";
    }
}
