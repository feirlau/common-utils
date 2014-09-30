package utils
{
    import mx.core.Application;
    import mx.logging.ILogger;
    import mx.logging.Log;
    import mx.managers.CursorManager;
    import mx.styles.StyleManager;

    public class CommonUtils
    {
        private static var regArray:Array = ["&", "<",  ">", "\"", "\'"];
        private static var repArray:Array = ["&amp;", "&lt;",  "&gt;", "&quot;", "&apos;"];
        private static var log_:ILogger = Log.getLogger("CommonUtils");
        
        public function CommonUtils()
        {
        }
        public static function escapeHtml(value:String):String {
            var result:String = value;
            if(result) {
                for(var i:int=0; i<regArray.length; i++) {
                    result = result.replace(new RegExp(regArray[i], "gm"), repArray[i]);
                }
            }
            return result;
        }
        
        private static var busyCursor:int = -1;
        private static var disableCount:int = 0;
        public static var isAppDisabled:Boolean = false;
        public static function disableApplication():void {
            try {
                var app:Application = Application.application as Application;
                app.enabled = false;
                isAppDisabled = true;
                disableCount += 1;
                if(busyCursor==-1) {
                    busyCursor = CursorManager.setCursor(StyleManager.getStyleDeclaration("mx.managers.CursorManager").getStyle("busyCursor"));
                }
            } catch(err:Error) {
                log_.error("[disableApplication]" + err.message);
            }
        }
        public static function enableApplication(force:Boolean=false):void {
            try {
                disableCount -= 1;
                if(disableCount<0 || force) {
                    disableCount = 0;
                }
                if(disableCount==0) {
                    var app:Application = Application.application as Application;
                    app.enabled = true;
                    isAppDisabled = false;
                    removeBusyCursor();
                }
            } catch(err:Error) {
                log_.error("[enableApplication]" + err.message);
            }
        }
        public static function removeBusyCursor():void {
            try {
                if(busyCursor!=-1) {
                    CursorManager.removeCursor(busyCursor);
                    busyCursor = -1;
                }
            } catch(err:Error) {
                log_.error("[removeBusyCursor]" + err.message);
            }
        }
    }
}