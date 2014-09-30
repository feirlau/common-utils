package com.fl.utils {
    import com.adobe.serialization.json.JSON;
    import com.fl.component.BaseSprite;
    import com.fl.utils.FLUtil;
    import com.fl.utils.LogUtil;
    import com.fl.utils.StringUtil;
    
    import flash.text.TextField;
    
    /**
    * wrap image or class in htmlText and change its params
    **/
    public class ImageHelper {
        public static const IMG_PARAMS_SEP:String = "::";
        private static const IMG_TAG:RegExp = new RegExp("<img [^>]*>", "img");
        private static const IMG_ID_TAG:RegExp = new RegExp("id *= *['\"]([a-zA-Z0-9_]+::[a-zA-Z0-9+/=\\r\\n]+)['\"]", "img");
        public static function updateImgTags(tf:TextField):void {
            if(tf.htmlText && tf) {
                IMG_TAG.lastIndex = 0;
                var imgs:Array = tf.htmlText.match(IMG_TAG);
                for each(var img:String in imgs) {
                    updateImgTag(img, tf);
                }
            }
        }
        private static function updateImgTag(img:String, tf:TextField):void {
            try {
                if(img && tf) {
                    var tmpId:String = getImgId(img);
                    var tmpParam:Object = getImgParam(tmpId);
                    var tmpObj:Object;
                    tmpId && (tmpObj = tf.getImageReference(tmpId));
                    if(tmpObj) {
                        for(var key:Object in tmpParam) {
                            tmpObj.hasOwnProperty(key) && (tmpObj[key] = tmpParam[key]);
                        }
                        updateImageReference(tmpObj);
                    }
                }
            } catch(err:Error) {
                LogUtil.addLog(ImageHelper, ["[updateImgTag] " + img, err], LogUtil.ERROR);
            }
        }
        private static function getImgId(str:String):String {
            IMG_ID_TAG.lastIndex = 0;
            var tmpA:Array = IMG_ID_TAG.exec(str);
            return (tmpA && tmpA.length > 1) ? tmpA[1] : "";
        }
        private static function getImgParam(str:String):Object {
            var tmpParam:Object = {};
            str = StringUtil.joinLines(str);
            var tmpA:Array = str.split(IMG_PARAMS_SEP);
            return (tmpA && tmpA.length == 2) ? com.adobe.serialization.json.JSON.decode(FLUtil.base64Decode(tmpA[1])) : {};
        }
        private static function updateImageReference(ref:Object):void {
            if(ref is BaseSprite) {
                var tmpComp:BaseSprite = (ref as BaseSprite);
                tmpComp.validateNow();
            }
        }
    }
}
