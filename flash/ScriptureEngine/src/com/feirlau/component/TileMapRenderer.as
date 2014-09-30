package com.feirlau.component {
    import com.feirlau.global.GlobalUtils;
    import com.feirlau.global.ModelLocator;
    import com.feirlau.map.tilemap.TileMap;
    import com.feirlau.resourceLoader.GameResourceProvider;
    import com.pblabs.engine.resource.XMLResource;
    import com.pblabs.rendering2D.BitmapRenderer;
    
    import flash.display.BitmapData;
    import flash.events.Event;
    
    public class TileMapRenderer extends BitmapRenderer {
        public static const COMP_NAME:String = "TileMapRenderer";
        public static const MAP_DIRTY_EVENT:String = "TileMapDirty";
        private var sceneLoader_:GameResourceProvider;
        private var tileMap_:TileMap;
        private var sceneName_:String = "1001";
        
        override protected function onAdd():void {
            sceneLoader_ = new GameResourceProvider(COMP_NAME);
            mouseEnabled = false;
            layerIndex = 0;
            super.onAdd();
        }
        
        override protected function onReset():void {
            bitmapData = new BitmapData(size.x, size.y, false);
            if(isDirty_) {
                mapDirtyHandler(tileMap_);
            }
            super.onReset();
        }
        
        override protected function onRemove():void {
            clearPreScene();
            if(sceneLoader_) {
                sceneLoader_.dispose();
            }
            sceneLoader_ = null;
            if(bitmapData) {
                bitmapData.dispose();
            }
            super.onRemove();
        }
        
        public function get tileMap():TileMap {
            return tileMap_;
        }
        
        private function clearPreScene():void {
            sceneConf_ = null;
            if(tileMap_) {
                tileMap_.dispose();
            }
            tileMap_ = null;
        }
        
        public function set sceneName(name:String):void {
            if(sceneName_ == name)
                return;
            clearPreScene();
            sceneName_ = name;
            sceneLoader_.load(onSceneLoaded, null, onSceneProvider);
        }
        public function get sceneName():String {
            return sceneName_;
        }
        
        private function onSceneProvider(phase:int):Array {
            return [{url: sceneUrl, type: XMLResource}];
        }
        
        private var sceneConf_:XML;
        private function onSceneLoaded(phase:int):void {
            var res:XMLResource = sceneLoader_.getResource(sceneUrl, XMLResource) as XMLResource;
            sceneConf_ = res.XMLData;
            if(sceneConf_) {
                tileMap_ = TileMap.buildTileMap(sceneName_, sceneConf_.mapInfo, size);
                tileMap_.dirtyHandler = mapDirtyHandler;
            }
        }
        private var isDirty_:Boolean = true;
        private function mapDirtyHandler(map:TileMap):void {
            isDirty_ = true;
            if(displayObject == null) {
                return;
            }
            if(tileMap_) {
                bitmapData.draw(tileMap_.mapData, null, null, null, tileMap_.mapRect);
                isDirty_ = false;
            }
            owner.eventDispatcher.dispatchEvent(new Event(MAP_DIRTY_EVENT));
        }
        
        private function get sceneUrl():String {
            return GlobalUtils.contactPath(ModelLocator.getInstance().sceneRoot, sceneName_, "config.xml");
        }
    }
}
