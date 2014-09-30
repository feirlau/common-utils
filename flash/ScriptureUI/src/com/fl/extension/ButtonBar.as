/**
 * @author risker
 * Dec 30, 2013
 **/
package com.fl.extension {
    import com.fl.component.Box;
    import com.fl.component.IItemRenderer;
    import com.fl.component.RadioButton;
    import com.fl.component.RadioButtonGroup;
    import com.fl.event.GlobalEvent;
    import com.fl.utils.ClassFactory;
    import com.fl.vo.ArrayList;
    
    import flash.display.DisplayObject;

    public class ButtonBar extends Box {
        public function ButtonBar() {
            super();
            
            autoContentSize = true;
        }
        
        protected var _buttonGroup:RadioButtonGroup = new RadioButtonGroup();
        public function get buttonGroup():RadioButtonGroup {
            return _buttonGroup;
        }
        
        override public function addItemAt(item:DisplayObject, i:int):DisplayObject {
            super.addItemAt(item, i);
            if(item is RadioButton) {
                _buttonGroup.addItem(item as RadioButton);
            }
            return item;
        }
        
        override public function removeItemAt(i:int):DisplayObject {
            var item:DisplayObject = super.removeItemAt(i);
            if(item is RadioButton) {
                _buttonGroup.removeItem(item as RadioButton);
            }
            return item;
        }
        
        protected var _itemRenderer:ClassFactory = new ClassFactory(BarItemRenderer);
        public function get itemRenderer():ClassFactory {
            return _itemRenderer;
        }
        public function set itemRenderer(value:ClassFactory):void {
            if(_itemRenderer != value) {
                _itemRenderer = value;
                updateDataProvider();
            }
        }
        
        protected var _dataProvider:ArrayList;
        public function get dataProvider():ArrayList {
            return _dataProvider;
        }
        public function set dataProvider(value:ArrayList):void {
            if(_dataProvider != value) {
                _dataProvider && _dataProvider.removeEventListener(ArrayList.EVENT_UPDATE, dataProviderChanged);
                _dataProvider = value;
                updateDataProvider();
                _dataProvider && _dataProvider.addEventListener(ArrayList.EVENT_UPDATE, dataProviderChanged);
            }
        }
        private function dataProviderChanged(env:GlobalEvent):void {
            updateDataProvider();
        }
        protected var renders:Array = [];
        public function updateDataProvider():void {
            removeAllItem();
            var n:int = _dataProvider ? _dataProvider.length : 0;
            var r:*;
            var i:int;
            for(i = 0; i < n; i++) {
                r = renders[i] ||= _itemRenderer.newInstance();
                r.data = _dataProvider[i];
                addItem(r);
            }
            n = renders.length;
            for(i; i < n; i++) {
                r = renders[i];
                r.data = null;
            }
        }
    }
}
