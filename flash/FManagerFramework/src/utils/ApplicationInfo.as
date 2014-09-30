package utils
{
	import mx.core.Container;
	import mx.resources.ResourceManager;
	
	public class ApplicationInfo
	{
		public static var currentPanel:Container;
		[Bindable]
		public static var loginInfo:Object = {username:"", password:"", login:false, usertype:0, sessionid:0, userid:0};
		
		public static function getInfoString(key:String, resource:String='fmf_info'):String {
			return ResourceManager.getInstance().getString(resource, key) ;
		}
		public static function getHomeString(key:String, resource:String='fmf_home'):String {
			return ResourceManager.getInstance().getString(resource, key) ;
		}
		
		public static function getInfoObject(key:String, resource:String='fmf_info'):Object {
			return ResourceManager.getInstance().getObject(resource, key) ;
		}
		public static function getHomeObject(key:String, resource:String='fmf_home'):Object {
			return ResourceManager.getInstance().getObject(resource, key) ;
		}
	}
}