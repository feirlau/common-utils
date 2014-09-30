/**
 * @author risker
 * Dec 20, 2013
 **/
package com.fl.extension {
    import com.fl.component.Text;
    import com.fl.utils.ImageHelper;

    public class ImageText extends Text {
        public function ImageText() {
            super();
        }
        
        public var trimLine:Boolean = true;
        override protected function updateText():void {
            var tmpChanged:Boolean = htmlTextChanged;
            super.updateText();
            if(tmpChanged && html) {
                if(textField.length > 0 && trimLine) {
                    var tmpS:String = textField.text.charAt(textField.length - 1);
                    if(tmpS == "\r") {
                        textField.replaceText(textField.length - 1, textField.length, "");
                    }
                }
                ImageHelper.updateImgTags(textField);
            }
        }
    }
}
