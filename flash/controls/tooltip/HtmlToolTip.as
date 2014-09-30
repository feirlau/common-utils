/*Copyright (c) 2007-2010 Vitria Technology, Inc.  All rights reserved. */
package controls.tooltip
{
    import mx.controls.ToolTip;

    public class HtmlToolTip extends ToolTip
    {
        override protected function commitProperties():void {
            super.commitProperties();
            if(textField) {
                textField.htmlText = text;
            }
        }
    }
}