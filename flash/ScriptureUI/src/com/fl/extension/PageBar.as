/**
 * @author risker
 * Oct 24, 2013
 **/
package com.fl.extension {
    import com.fl.component.BaseComponent;
    import com.fl.component.Box;
    import com.fl.component.Button;
    import com.fl.component.ComboBox;
    import com.fl.component.ScrollTile;
    import com.fl.event.GlobalEvent;
    import com.fl.vo.ArrayList;
    
    import flash.events.MouseEvent;
    import flash.utils.getTimer;
    
    public class PageBar extends Box {
        public static const EVENT_PAGE_UPDATED:String = "PageUpdatedEvent";
        
        public function PageBar() {
            super();
            
            autoContentSize = false;
        }
        
        override protected function initStyle():void {
            _selfStyles.push("preButtonStyle", "nextButtonStyle", "selectorStyle");
            super.initStyle();
        }
        
        protected var _prePageButton:Button = new Button();
        public function get prePageButton():Button {return _prePageButton;}
        
        protected var _nextPageButton:Button = new Button();
        public function get nextPageButton():Button {return _nextPageButton;}
        
        protected var _pageSelector:ComboBox = new ComboBox();
        public function get pageSelector():Button {return _pageSelector;}
        
        override protected function createChildren():void {
            super.createChildren();
            _prePageButton.addEventListener(MouseEvent.CLICK, gotoPrePage);
            addItem(_prePageButton);
            
            _pageSelector.addEventListener(ComboBox.EVENT_ITEM_CHANGED, selectPage);
            addItem(_pageSelector);
            
            _nextPageButton.addEventListener(MouseEvent.CLICK, gotoNextPage);
            addItem(_nextPageButton);
        }
        
        public function updateData():void {
            updatePageSelector();
            updatePageInfo();
        }
        
        private var curPage_:int = 0;
        public function get curPage():int {
            return curPage_;
        }
        public function set curPage(value:int):void {
            if(curPage_ != value) {
                curPage_ = value;
                _pageSelector.list.selectedItems = curPage_;
                updatePageInfo();
            }
        }
        
        private var maxPage_:int = 1;
        public function get maxPage():int {
            return maxPage_;
        }
        public function set maxPage(value:int):void {
            if(maxPage_ != value) {
                maxPage_ = value;
                if(curPage_ > maxPage_) {
                    curPage_ = maxPage_;
                }
                updatePageSelector();
                updatePageInfo();
            }
        }
        
        private function getPageLabel(item:Object):String {
            var tmpResult:String = item + "/" + maxPage_;
            return tmpResult;
        }
        
        private function selectPage(env:GlobalEvent):void {
            gotoPage(int(_pageSelector.label));
        }
        
        private function gotoNextPage(env:MouseEvent):void {
            gotoPage(curPage_ + 1);
        }
        private function gotoPrePage(env:MouseEvent):void {
            gotoPage(curPage_ - 1);
        }
        
        public function gotoPage(page:int):void {
            if(page > 0 && page <= maxPage_) {
                curPage = page;
                dispatchEvent(new GlobalEvent(EVENT_PAGE_UPDATED, curPage));
            }
        }
        
        public function updatePageSelector():void {
            var pages:ArrayList = new ArrayList();
            for(var i:int = 1; i <= maxPage_; i++) {
                pages.push(i);
            }
            _pageSelector.list.dataProvider = pages;
            _pageSelector.list.selectedItems = curPage_;
        }
        
        public function updatePageInfo():void {
            if(curPage_ < maxPage_) {
                _nextPageButton.enabled = true;
            } else {
                _nextPageButton.enabled = false;
            }
            if(curPage_ > 1) {
                _prePageButton.enabled = true;
            } else {
                _prePageButton.enabled = false;
            }
        }
        
        override public function updateStyle(styleP:String = null):void {
            super.updateStyle(styleP);
            
            if(acceptStyle(styleP)) {
                if(styleP == null || styleP == "preButtonStyle") {
                    _prePageButton.copyStyle(getStyle("preButtonStyle"));
                }
                if(styleP == null || styleP == "nextButtonStyle") {
                    _nextPageButton.copyStyle(getStyle("nextButtonStyle"));
                }
                if(styleP == null || styleP == "selectorStyle") {
                    _pageSelector.copyStyle(getStyle("selectorStyle"));
                }
            }
        }
    }
}
