package com.feirlau.resourceLoader {
    import com.pblabs.engine.resource.Resource;
    import com.pblabs.engine.resource.provider.BulkLoaderResourceProvider;
    
    public class GameResourceProvider extends BulkLoaderResourceProvider {
        public function GameResourceProvider(name:String = "GameResourceProvider", numConnections:int = 12, registerAsProvider:Boolean = true) {
            super(name, numConnections, registerAsProvider);
        }
        
        public function unload():void {
            for(var uri:String in resources) {
                var resource:Resource = resources[uri];
                resource.dispose();
                delete resources[uri];
            }
        }
        
        public function dispose():void {
            load();
            unload();
            loader.clear();
        }
            
    }
}