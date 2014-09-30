package utils
{
	import flash.display.DisplayObject;
	
	import mx.core.Application;
	import mx.managers.PopUpManager;
	
	public class WaitingManager
	{
		public function WaitingManager()
		{
		}
		
		private static var wc:WaitCanvas=null;		
		
		public static function showWC(des:String=""):void
		{			
			if(WaitingManager.wc==null)
			{
				WaitingManager.wc=PopUpManager.createPopUp(Application.application as DisplayObject,WaitCanvas,false,null) as WaitCanvas;
				WaitingManager.wc.width=Application.application.width;
				WaitingManager.wc.height=Application.application.height;
				WaitingManager.wc.description=des;
				PopUpManager.centerPopUp(WaitingManager.wc);				
			}			
		}
		
		public static function setDes(s:String):void
		{
			WaitingManager.wc.description=s;
		}
		
		public static function removeWC():void
		{
			if(WaitingManager.wc!=null)
			{
				PopUpManager.removePopUp(WaitingManager.wc);
				WaitingManager.wc=null;				
			}	
		}

	}
}