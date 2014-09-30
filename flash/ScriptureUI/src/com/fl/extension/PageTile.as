package com.fl.extension {
    import com.fl.component.Box;
    import com.fl.component.ScrollTile;
    import com.fl.event.GlobalEvent;
    import com.fl.vo.ArrayList;
    
    import flash.display.DisplayObject;
    
    import org.as3commons.ui.layout.VGroup;
    import org.as3commons.ui.layout.constants.Align;

    public class PageTile extends Box {
        public function PageTile() {
            super();
            
            autoContentSize = false;
            
            var vg:VGroup = new VGroup();
            vg.hAlign = Align.CENTER;
            vg.vAlign = Align.MIDDLE;
            layout = vg;
            
            _tile.autoContentSize = false;
            _bar.autoContentSize = true;
        }
        
        override protected function initStyle():void {
            _selfStyles.push("barStyle", "tileStyle");
            super.initStyle();
        }
        override public function updateStyle(styleP:String = null):void {
            super.updateStyle(styleP);
            
            if(acceptStyle(styleP)) {
                if(styleP == null || styleP == "barStyle") {
                    _bar.copyStyle(getStyle("barStyle"));
                }
                if(styleP == null || styleP == "tileStyle") {
                    _tile.copyStyle(getStyle("tileStyle"));
                }
            }
        }
        
        protected var _bar:PageBar = new PageBar();
        public function get bar():PageBar {
            return _bar;
        }
        protected var _tile:ScrollTile = new ScrollTile();
        public function get tile():ScrollTile {
            return _tile;
        }
        override protected function createChildren():void {
            super.createChildren();
            
            addItem(_tile);
            
            _bar.addEventListener(PageBar.EVENT_PAGE_UPDATED, pageHandler);
            updateBar();
            
            updatePageSize();
        }
        override protected function isRawChildren(v:DisplayObject):Boolean {
            return super.isRawChildren(v) && (v != bar || _showBar) 
        }
        
        private function pageHandler(env:GlobalEvent = null):void {
            curPage = _bar.curPage;
        }
        
        public function get column():int {
            return _tile.column;
        }
        public function set column(value:int):void {
            if(_tile.column != value) {
                _tile.column = value;
                updatePageSize();
            }
        }
        
        public function get row():int {
            return _tile.row;
        }
        public function set row(value:int):void {
            if(_tile.row != value) {
                _tile.row = value;
                updatePageSize();
            }
        }
        private var _pageSize:int = 1;
        private function updatePageSize():void {
            _pageSize = row * column;
            updateDataProvider();
        }
        
        private var _showBar:Boolean = true;
        public function get showBar():Boolean {
            return _showBar;
        }
        public function set showBar(value:Boolean):void {
            if(_showBar != value) {
                _showBar = value;
                updateBar();
            }
        }
        protected function updateBar():void {
            if(_showBar) {
                addItem(_bar);
            } else {
                removeItem(_bar);
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
        public function updateDataProvider():void {
            if(_dataProvider) {
                var n:int = _dataProvider.length / _pageSize;
                (n == 0 || _dataProvider.length % _pageSize > 0) && n++;
                bar.maxPage = n;
            } else {
                bar.maxPage = 1;
            }
            updateCurPage();
        }
        
        private var _curPage:uint = 0;
        public function get curPage():uint {
            return _curPage;
        }
        public function set curPage(value:uint):void {
            if(_curPage != value) {
                _curPage = value;
                updateCurPage();
            }
        }
        private var pageDataChanged:Boolean = true;
        public function updateCurPage():void {
            if(_curPage == 0) {
                _curPage = 1;
            } else if(_curPage > _bar.maxPage) {
                _curPage = _bar.maxPage;
            }
            _bar.curPage = _curPage;
            
            pageDataChanged = true;
            invalidate(INVALIDATE_PROP);
        }
        public function updateCurPageData():void {
            pageDataChanged = false;
            var i:int = (_curPage - 1) * _pageSize;
            if(_dataProvider) {
                _tile.dataProvider = new ArrayList(_dataProvider.slice(i, i + _pageSize));
            } else {
                _tile.dataProvider = null;
            }
        }
        
        override protected function onProp():void {
            super.onProp();
            
            updateCurPageData();
        }
    }
}
