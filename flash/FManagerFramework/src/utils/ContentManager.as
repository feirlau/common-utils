package utils
{
    import content.IContent;
    
    import mx.collections.ArrayCollection;
    import mx.events.ChildExistenceChangedEvent;
    
    public class ContentManager
    {
        public function ContentManager()
        {
        }
        
        private var contents_:ArrayCollection = new ArrayCollection();
        public function get contents():ArrayCollection {
            return contents_;
        }
        public function set contents(cons:ArrayCollection):void {
            if(cons == null) {
                cons = new ArrayCollection();
            }
            contents_ = cons;
            updateContentsAndContainer();
        }
        
        private var contentsContainer_:Content;
        public function get contentsContainer():Content {
            return contentsContainer_;
        }
        public function set contentsContainer(container:Content):void {
            if(contentsContainer_ != container) {
                var tmpContents:Array = contents_.toArray();
                removeContainerListeners();
                removeContents(tmpContents);
                contentsContainer_ = container;
                addContents(tmpContents);
                addContainerListeners();
            }
        }
        
        public function updateContentsAndContainer():void {
            if(contentsContainer_) {
                var tmpContents:Array = contents_.toArray();
                removeContainerListeners();
                removeContents(tmpContents);
                contentsContainer_.validateNow();
                addContents(tmpContents);
                addContainerListeners();
            }
        }
        
        public function cleanup():void {
            var tmpContents:Array = contents_.toArray();
            removeContainerListeners();
            removeContents(tmpContents);
        }
        
        private function addContainerListeners():void {
            if(contentsContainer_) {
                contentsContainer_.addEventListener(ChildExistenceChangedEvent.CHILD_REMOVE, contentRemoved);
            }
        }
        private function removeContainerListeners():void {
            if(contentsContainer_) {
                contentsContainer_.removeEventListener(ChildExistenceChangedEvent.CHILD_REMOVE, contentRemoved);
            }
        }
        private function contentRemoved(event:ChildExistenceChangedEvent):void {
            if(event.relatedObject is Manager) {
                removeContent(event.relatedObject as Manager);
            }
        }
        
        public function addContents(cons:Array, index:int=-1):void {
            if(index<0 || index>=contentsContainer_.getChildren().length) {
                index = contentsContainer_.getChildren().length;
            }
            for each(var con:Manager in cons) {
                addContent(con, index);
                index++;
            }
        }
        
        public function removeContents(cons:Array):void {
            for each(var con:Manager in cons) {
                removeContent(con);
            }
        }
        
        public function addContent(con:Manager, index:int=-1):Manager {
            var tmpResult:Manager;
            if(contentsContainer_) {
                if(index<0 || index>=contentsContainer_.getChildren().length) {
                    index = contentsContainer_.getChildren().length;
                }
                if(!contentsContainer_.contains(con)) {
                    tmpResult = contentsContainer_.addChildAt(con, index) as Manager;
                } else {
                    tmpResult = con;
                    index = contentsContainer_.getChildIndex(con);
                }
                contentsContainer_.setClosePolicyForTab(index, tmpResult.closePolicy);
            }
            if(!contents_.contains(con)) {
                contents_.addItem(tmpResult);
            }
            return tmpResult;
        }

        public function removeContent(con:Manager):Manager {
            var tmpResult:Manager;
            if(contentsContainer_ && contentsContainer_.contains(con)) {
                tmpResult = contentsContainer_.removeChild(con) as Manager;
            }
            var tmpIndex:int = contents_.getItemIndex(con);
            if(tmpIndex>=0) {
                contents_.removeItemAt(tmpIndex);
            }
            return tmpResult;
        }
        
        public function updateContent(con:Manager):void {
            if(con && contentsContainer_ && contentsContainer_.contains(con)) {
                var tmpIndex:int = contentsContainer_.getChildIndex(con);
                contentsContainer_.setClosePolicyForTab(tmpIndex, con.closePolicy);
            }
        }
    }
}