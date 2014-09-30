/* Copyright (c) 2010-2011 Vitria Technology, Inc.  All rights reserved. */
package controls.tooltip
{
    import mx.containers.FormItem;

    public class CustomFormItem extends FormItem
    {
        /**
        * For FormItem used in custom tooltip(CustomFormToolTip), we should set the toolTip of the itemLabel to empty and disable the tooltip reset.
        * Otherwise, there will be exception for some situation, such as:
        *   1. Mouse on one item and show the toolTip
        *   2. Move mouse down to another item covered by pre toolTip
        *   3. There will be exception:
        *      TypeError: Error #1009: Cannot access a property or method of a null object reference.
        *        at mx.managers::ToolTipManagerImpl/http://www.adobe.com/2006/flex/mx/internal::positionTip()[C:\autobuild\3.2.0\frameworks\projects\framework\src\mx\managers\To olTipManagerImpl.as:1003]
        *        at mx.managers::ToolTipManagerImpl/http://www.adobe.com/2006/flex/mx/internal::targetChanged()[C:\autobuild\3.2.0\frameworks\projects\framework\src\mx\managers\To olTipManagerImpl.as:778]
        *        at mx.managers::ToolTipManagerImpl/http://www.adobe.com/2006/flex/mx/internal::checkIfTargetChanged()[C:\autobuild\3.2.0\frameworks\projects\framework\src\mx\managers\To olTipManagerImpl.as:678]
        *        at mx.managers::ToolTipManagerImpl/http://www.adobe.com/2006/flex/mx/internal::toolTipMouseOverHandler()[C:\autobuild\3.2.0\frameworks\projects\framework\src\mx\managers\To olTipManagerImpl.as:1341]
        */
        override protected function createChildren():void {
            super.createChildren();
            if(itemLabel) {
                itemLabel.toolTip = "";
            }
        }
    }
}