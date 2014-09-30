package utils
{
	import flash.events.MouseEvent;
	
	import mx.controls.Tree;

	public class TreeFilter extends Tree
	{
		public function TreeFilter()
		{
			super();
			doubleClickEnabled = true;
			addEventListener(MouseEvent.DOUBLE_CLICK, expandItemByDB);
		}
		
		private var tmpData:Object = null;
		override public function isItemSelectable(data:Object):Boolean {
			tmpData = data;
			if(super.isItemSelectable(data)) {
				return data.@selectable==0?false:true ;
			}
			return false;
		}
		override public function isItemVisible(item:Object):Boolean {
			if(super.isItemVisible(data)) {
				return data.@visible==0?false:true ;
			}
			return false;
		}
		
		private function expandItemByDB(event:MouseEvent):void {
            try {
                var tmpExpanded:Boolean = isItemOpen(tmpData);
                expandItem(tmpData, !tmpExpanded);
            } catch(err:Error) {
                trace(err);
            }
        }
	}
}