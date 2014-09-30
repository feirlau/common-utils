package utils.network
{
	import flash.net.URLRequestMethod;
	import flash.utils.setTimeout;
	
	import mx.core.Application;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import utils.common.UIUtil;
	
	public class HTTPServiceUtil
	{
		public static var URL_PREFIX:String = "/";
		
		public static function initHTTPService(resultFormat:String="e4x"):HTTPService {
			var service:HTTPService = new HTTPService();
			service.resultFormat = resultFormat;
			service.addEventListener(FaultEvent.FAULT, httpFault);
			service.addEventListener(ResultEvent.RESULT, httpResult);
			return service ;
		}
		
		public static function requestXMLForRequest(type:String, reqURL:String, parameters:Object=null, result:Function=null, fault:Function=null,  modal:Boolean=false, obj:Object=null, baseURL:String=null, loop:int=0, wait:int=1000):HTTPService {
            var service:HTTPService = initHTTPService("e4x");
            service.url = (baseURL?baseURL:URL_PREFIX) + reqURL;
            service.method = type;
            if(modal) {
            	if(!obj) {
            		obj = Application.application;
            	}
        		UIUtil.disableUI(obj, true);
            }
            var f1:Function = function(event:ResultEvent):void {
            	if(result!=null) {
            	   result.apply(null, [event]);
            	}
            	if(loop==0) {
	                UIUtil.enableUI(obj);
            		return;
            	}
            	if(loop>0) {
            		loop = loop -1;
            	}
            	if(wait<0) wait = 0;
            	setTimeout(requestXMLForRequest, wait, [type, reqURL, parameters, result, fault,  modal, obj, baseURL, loop, wait]);
            };
            if(result!=null) {
                service.addEventListener(ResultEvent.RESULT, f1);
            }
            var f2:Function = function(event:FaultEvent):void {
                UIUtil.enableUI(obj);
                if(fault!=null) {
                   fault.apply(null, [event]);
                }
            };
            if(fault!=null)  {
                service.addEventListener(FaultEvent.FAULT, f2);
            }
            service.send(parameters);
            return service;
        }
        
		public static function requestXMLForGet(reqURL:String, parameters:Object=null, result:Function=null, fault:Function=null,  modal:Boolean=false, obj:Object=null, baseURL:String=null, loop:int=0, wait:int=1000):HTTPService {
			return requestXMLForRequest(URLRequestMethod.GET, reqURL, parameters, result, fault,  modal, obj, baseURL, loop, wait);
		}
		public static function requestXMLForPost(reqURL:String, parameters:Object=null, result:Function=null, fault:Function=null,  modal:Boolean=false, obj:Object=null, baseURL:String=null, loop:int=0, wait:int=1000):HTTPService {
			return requestXMLForRequest(URLRequestMethod.POST, reqURL, parameters, result, fault,  modal, obj, baseURL, loop, wait);
		}
		public static function httpResult(event:ResultEvent):void {
			trace(event);
		}
		public static function httpFault(event:FaultEvent):void {
			trace(event);
		}
		public static function httpAlert(event:ResultEvent):void {
			trace(event);
		}
		public static function nullCallback(event:ResultEvent):void {
			trace(event);
		}
	}
}