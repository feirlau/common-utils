package utils
{
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class HTTPServiceUtil
	{
	    private static var logger_:ILogger = Log.getLogger('HTTPServiceUtil');
		public static var URL_PREFIX:String = "/do" ;
		
		public static function initHTTPService():HTTPService {
			var service:HTTPService = new HTTPService();
			service.resultFormat = "e4x";
			service.addEventListener(FaultEvent.FAULT, httpFault);
			return service ;
		}
		public static function requestXMLForGet(reqURL:String, parameters:Object=null, result:Function=null, fault:Function=null, baseURL:String=null):HTTPService {
			var service:HTTPService = initHTTPService();
			service.url = (baseURL?baseURL:URL_PREFIX) + reqURL;
			service.method = "GET";
			var resultCallback:Function = function(event:ResultEvent):void {
                CommonUtils.enableApplication();
                if(!checkSessionTimeout(event) && result!=null) {
                    result(event);
                }
            }
			var faultCallback:Function = function(event:FaultEvent):void {
			    logger_.debug(event.toString());
                CommonUtils.enableApplication();
                if(fault!=null) {
                    fault(event);
                }
            }
            service.addEventListener(ResultEvent.RESULT, resultCallback);
			service.addEventListener(FaultEvent.FAULT, faultCallback);
			service.send(parameters);
            CommonUtils.disableApplication();
			return service;
		}
		public static function requestXMLForPost(reqURL:String, parameters:Object=null, result:Function=null, fault:Function=null, baseURL:String=null):HTTPService {
			var service:HTTPService = initHTTPService();
			service.url = (baseURL?baseURL:URL_PREFIX) + reqURL;
			service.method = "POST";
			var resultCallback:Function = function(event:ResultEvent):void {
                CommonUtils.enableApplication();
                if(!checkSessionTimeout(event) && result!=null) {
			        result(event);
			    }
			}
			var faultCallback:Function = function(event:FaultEvent):void {
			    logger_.debug(event.toString());
                CommonUtils.enableApplication();
                if(fault!=null) {
                    fault(event);
                }
            }
			service.addEventListener(ResultEvent.RESULT, resultCallback);
			service.addEventListener(FaultEvent.FAULT, faultCallback);
			service.send(parameters);
            CommonUtils.disableApplication();
			return service;
		}
		public static function httpResult(event:ResultEvent):void {
			var resultString:String = event.result.toString() ;
			Alert.show(resultString,ApplicationInfo.getInfoString("success"));
		}
		public static function httpFault(event:FaultEvent):void {
			var faultString:String = event.fault.faultString ;
			Alert.show(faultString, ApplicationInfo.getInfoString("fault"));
		}
		public static function httpAlert(event:ResultEvent):void {
			Alert.show(event.result.msg, ApplicationInfo.getInfoString("info"));
		}
		public static function nullCallback(event:ResultEvent):void {
			
		}
		
		public static function checkSessionTimeout(event:ResultEvent):Boolean {
		    if(event && event.result is XML && (event.result as XML).@resultCode.toString()=='-3') {
		        Alert.show(ApplicationInfo.getHomeString("sessionTimeout"), ApplicationInfo.getInfoString("info"));
		        Application.application.header.logout();
		        return true;
		    }
		    return false
		}
	}
}