package org.feirlau.loader
{
    import org.feirlau.core.FLUtils;
    
    import flash.system.LoaderContext;
    import flash.utils.Dictionary;
    
    import mx.collections.ArrayCollection;
    import mx.logging.ILogger;
    import mx.logging.Log;
    
    public class ResourcesManager
    {
        private static const logger_:ILogger = Log.getLogger("ResourcesManager");
        private static var instance_:ResourcesManager;
        public static function getInstance():ResourcesManager {
            if(instance_ == null) {
                instance_ = new ResourcesManager();
            }
            return instance_;
        }
        
        private var resources:Dictionary = new Dictionary();
        private var libDefines:XML = <Libs/>;
        private var loaders:Array = [DataLoader.getInstance(), LocalLoader.getInstance(), StyleLoader.getInstance(), LibraryLoader.getInstance()];
        private var resourceTypes:Array = [Resource.RESOURCE_TYPE_DATA, Resource.RESOURCE_TYPE_LOCAL, Resource.RESOURCE_TYPE_STYLE, Resource.RESOURCE_TYPE_LIBRARY];
        
        /***
         * @param id, lib id
         * @param callback, can be a function or function array, as callback after finishing loading libraries. 
         *    the parameters of callback function are callback(successList, failedList).
         * @param loaderContext_, loader context
         */ 
        public function loadLib(id:String, callback:*=null, loaderContext_:LoaderContext=null):void {
            var tmpSuccessList:Array = new Array();
            var tmpFailedList:Array = new Array();
            var tmpRes:Array = getResourcesByLibId(id);
            var i:int = 0;
            var f1:Function = function(a1:Array = null, a2:Array = null):void {
                a1 && (tmpSuccessList = tmpSuccessList.concat(a1));
                a2 && (tmpFailedList = tmpFailedList.concat(a2));
                if(tmpRes.length == 0) {
                    FLUtils.apply(callback, tmpSuccessList, tmpFailedList);
                } else {
                    doLoad(tmpRes.shift(), loaders[i++], f1, loaderContext_);
                }
            };
            f1();
        }
        private function doLoad(resources:Array, loader:ILoader, callback:*=null, loaderContext_:LoaderContext=null):void {
            if(loader) {
                loader.load(resources, callback, loaderContext_);
            } else {
                FLUtils.apply(callback);
            }
        }
        
        /***
         * @param resources, resource list to be loaded.
         * @param callback, can be a function or function array, as callback after finishing loading libraries. 
         *    the parameters of callback function are callback(successList, failedList).
         * @param loaderContext_, loader context
         */ 
        public function loadResources(resources:Array, callback:*=null, loaderContext_:LoaderContext=null):void {
            var tmpSuccessList:Array = new Array();
            var tmpFailedList:Array = new Array();
            var f1:Function = function(a1:Array = null, a2:Array = null):void {
                a1 && (tmpSuccessList = tmpSuccessList.concat(a1));
                a2 && (tmpFailedList = tmpFailedList.concat(a2));
                if(resources.length == 0) {
                    FLUtils.apply(callback, tmpSuccessList, tmpFailedList);
                } else {
                    var tmpRes:Resource = resources.shift();
                    doLoad([tmpRes], loaders[resourceTypes.indexOf(tmpRes.type)], f1, loaderContext_);
                }
            };
            f1();
        }
        
        /**
         * Add resource to cache
         * @param resource, the resource to be added
         * @param update, true - replace the exist one in the cache
         * @return true - if add/replace successfully
         **/
        public function addResource(resource:Resource, update:Boolean = false):Boolean {
            var tmpResult:Boolean = false;
            if(!resources.hasOwnProperty(resource.id) || update) {
                resources[resource.id] = resource;
                tmpResult = true;
            }
            return tmpResult;
        }
        
        /**
         * Get resource from cache by resource id
         * @param id, the resource id
         * @return the correspond resource
         **/
        public function getResourceById(id:String):Resource {
            var tmpResource:Resource = null;
            if(resources.hasOwnProperty(id)) {
                tmpResource = resources[id];
            }
            return tmpResource;
        }
        
        /**
         * Remove resource from cache
         * @param resource, the resource to be removed
         * @return true - if contains in cache and removed successfully
         **/
        public function removeResource(resource:Resource):Boolean {
            var tmpResult:Boolean = false;
            if(resources.hasOwnProperty(resource.id)) {
                delete resources[resource.id];
                tmpResult = true;
            }
            return tmpResult;
        }
        /**
         * Remove resource from cache by resource id
         * @param id, the resource id to be removed
         * @return true - if contains in cache and removed successfully
         **/
        public function removeResourceById(id:String):Boolean {
            var tmpResult:Boolean = false;
            if(resources.hasOwnProperty(id)) {
                delete resources[id];
                tmpResult = true;
            }
            return tmpResult;
        }
        
        /**
         * Add defines
         * @param defs, an xml like this:
         * <root>
         *   <Lib id="id1" url="url1" version="1.0" name="lib1"/>
         *   <Lib id="id2" url="url1" version="1.0" name="lib2">
         *      ...
         *   </Lib>
         *   <Local id="id2" url="url1" version="1.0" name="local1"/>
         *   <Style id="id2" url="url1" version="1.0" name="style1"/>
         *   <Data id="id3" url="url2" subtype="img" version="1.0" name="data1"/>
         * </root>
         * @param update, update the resource url with the new one if it exist in the cache already
         **/
        public function addDefines(defs:XML, update:Boolean = false):Array {
            var tmpResources:Array = new Array();
            var tmpDef:XML;
            for each(tmpDef in defs.Data) {
                tmpResources.push(addDataDefine(tmpDef));
            }
            for each(tmpDef in defs.Local) {
                tmpResources.push(addLocalDefine(tmpDef));
            }
            for each(tmpDef in defs.Style) {
                tmpResources.push(addStyleDefine(tmpDef));
            }
            for each(tmpDef in defs.Lib) {
                tmpResources.push(addLibDefine(tmpDef));
            }
            return tmpResources;
        }
        
        /**
         * Add local defines
         * @param dataDefs, an xml like this:
         * <root>
         *   <Data id="id1" url="url1" subtype="xml" version="1.0" name="data1"/>
         *   <Data id="id1" url="url2" subtype="img" version="1.0" name="data1"/>
         * </root>
         * @param update, update the resource url with the new one if it exist in the cache already
         **/
        public function addDataDefines(dataDefs:XML, update:Boolean = false):Array {
            var tmpResources:Array = new Array();
            if(dataDefs) {
                for each(var dataDef:XML in dataDefs.Data) {
                    var tmpResource:Resource = addDataDefine(dataDef, update);
                    if(tmpResource) {
                        tmpResources.push(tmpResource);
                    }
                }
            }
            return tmpResources;
        }
        /**
         * <Data id="id1" url="url1" subtype="" version="1.0" name="data1"/>
         **/
        public function addDataDefine(dataDef:XML, update:Boolean = false):Resource {
            var tmpResource:Resource;
            if(dataDef) {
                tmpResource = new Resource(dataDef.@id, dataDef.@url, dataDef.@name, dataDef.@version, Resource.RESOURCE_TYPE_DATA, dataDef.@subtype);
                addResource(tmpResource, update);
            }
            return tmpResource;
        }
        
        /**
         * Add local defines
         * @param localDefs, an xml like this:
         * <root>
         *   <Local id="id1" url="url1" version="1.0" name="local1"/>
         *   <Local id="id1" url="url2" version="1.0" name="local2"/>
         * </root>
         * @param update, update the resource url with the new one if it exist in the cache already
         **/
        public function addLocalDefines(localDefs:XML, update:Boolean = false):Array {
            var tmpResources:Array = new Array();
            if(localDefs) {
                for each(var localDef:XML in localDefs.Local) {
                    var tmpResource:Resource = addLocalDefine(localDef, update);
                    if(tmpResource) {
                        tmpResources.push(tmpResource);
                    }
                }
            }
            return tmpResources;
        }
        /**
         * <Local id="id1" url="url1" version="1.0" name="local1"/>
         **/
        public function addLocalDefine(localDef:XML, update:Boolean = false):Resource {
            var tmpResource:Resource;
            if(localDef) {
                tmpResource = new Resource(localDef.@id, localDef.@url, localDef.@name, localDef.@version, Resource.RESOURCE_TYPE_LOCAL);
                addResource(tmpResource, update);
            }
            return tmpResource;
        }
        
        /**
         * Add style defines
         * @param styleDefs, an xml like this:
         * <root>
         *   <Style id="id1" url="url1" version="1.0" name="style1"/>
         *   <Style id="id2" url="url2" version="1.0" name="style1"/>
         * </root>
         * @param update, update the resource url with the new one if it exist in the cache already
         **/
        public function addStyleDefines(styleDefs:XML, update:Boolean = false):Array {
            var tmpResources:Array = new Array();
            if(styleDefs) {
                for each(var styleDef:XML in styleDefs.Style) {
                    var tmpResource:Resource = addStyleDefine(styleDef, update);
                    if(tmpResource) {
                        tmpResources.push(tmpResource);
                    }
                }
            }
            return tmpResources;
        }
        /**
         * <Style id="id1" url="url1" version="1.0" name="style1"/>
         **/
        public function addStyleDefine(styleDef:XML, update:Boolean = false):Resource {
            var tmpResource:Resource;
            if(styleDef) {
                tmpResource = new Resource(styleDef.@id, styleDef.@url, styleDef.@name, styleDef.@version, Resource.RESOURCE_TYPE_STYLE);
                addResource(tmpResource, update);
            }
            return tmpResource;
        }
        
        /**
         * * Add lib defines and store the libDefs in libDefines
         * @param libDefs, an xml like this:
         * <root>
         *   <Lib id="id1" url="url1" version="1.0" name="lib1">
         *       <Lib id="id2"/>
         *       <Local id="id3"/>
         *       <Style id="id4"/>
         *   </Lib>
         *   <Lib id="id2" url="url2" version="1.0" name="lib2">
         *       <Local id="id5"/>
         *       <Style id="id6"/>
         *       <Data id="id7"/>
         *   </Lib>
         * </root>
         *  @param update, update the resource url with the new one if it exist in the cache already
         **/
        public function addLibDefines(libDefs:XML, update:Boolean = false):Array {
            var tmpResources:Array = new Array();
            if(libDefs) {
                for each(var libDef:XML in libDefs.Lib) {
                    var tmpResource:Resource = addLibDefine(libDef, update);
                    if(tmpResource) {
                        tmpResources.push(tmpResource);
                    }
                }
            }
            return tmpResources;
        }
        /**
         * <Lib id="id1" url="url1" version="1.0" name="lib1">
         *       <Lib id="id2"/>
         *       <Local id="id3"/>
         *       <Style id="id4"/>
         *       <Data id="id5"/>
         * </Lib>
         **/
        public function addLibDefine(libDef:XML, update:Boolean = false):Resource {
            var tmpResource:Resource;
            if(libDef) {
                var tmpLibExist:Boolean = (libDefines.Lib.(hasOwnProperty("@id") && @id == libDef.@id).length() > 0);
                if(tmpLibExist && update) {
                    delete libDefines.Lib.(hasOwnProperty("@id") && @id == libDef.@id)[0];
                }
                if(!tmpLibExist || update) {
                    libDefines.appendChild(libDef);
                }
                tmpResource = new Resource(libDef.@id, libDef.@url, libDef.@name, libDef.@version, Resource.RESOURCE_TYPE_LIBRARY);
                addResource(tmpResource, update);
            }
            return tmpResource;
        }
        
        public function getLibDefineById(id:String):XML {
            var tmpLibDef:XML = <Lib/>;
            var tmpList:XMLList = libDefines.Lib.(hasOwnProperty("@id") && @id == id);
            if(tmpList.length() > 0) {
                tmpLibDef = tmpList[0];
            }
            return tmpLibDef;
        }
        
        /**
         * Get the resources the lib used or depend by the lib id
         * @return Array, an array of [dataResources, localResources, styleResources, libResources]
         **/
        public function getResourcesByLibId(id:String, type:String="*"):Array {
            var tmpDataResources:Array = new Array();
            var tmpLocalResources:Array = new Array();
            var tmpStyleResources:Array = new Array();
            var tmpLibResources:Array = new Array();
            var tmpResourceIds:ArrayCollection = new ArrayCollection();
            var libDefs:XMLList = libDefines.Lib.(hasOwnProperty("@id") && @id == id);
            if(libDefs.length() > 0) {
                getDependResources(libDefs[0], type, tmpDataResources, tmpLocalResources, tmpStyleResources, tmpLibResources, tmpResourceIds);
            }
            return [tmpDataResources, tmpLocalResources, tmpStyleResources, tmpLibResources];
        }
        
        /**
         * Get the resources the lib used or depend by the lib define
         * @return Array, an array of [dataResources, localResources, styleResources, libResources]
         **/
        public function getResourcesByLibDef(libDef:XML, type:String="*"):Array {
            var tmpDataResources:Array = new Array();
            var tmpLocalResources:Array = new Array();
            var tmpStyleResources:Array = new Array();
            var tmpLibResources:Array = new Array();
            var tmpResourceIds:ArrayCollection = new ArrayCollection();
            getDependResources(libDef, type, tmpDataResources, tmpLocalResources, tmpStyleResources, tmpLibResources, tmpResourceIds);
            return [tmpDataResources, tmpLocalResources, tmpStyleResources, tmpLibResources];
        }
        private function getDependResources(libDef:XML, type:String, tmpDataResources:Array, tmpLocalResources:Array, tmpStyleResources:Array, tmpLibResources:Array, tmpResourceIds:ArrayCollection):Array {
            var tmpDef:XML;
            var tmpId:String;
            var tmpResource:Resource;
            
            for each(tmpDef in libDef.Lib) {
                getDependResources(tmpDef, type, tmpDataResources, tmpLocalResources, tmpStyleResources, tmpLibResources, tmpResourceIds);
                if(type==Resource.RESOURCE_TYPE_LIBRARY || type==Resource.RESOURCE_TYPE_ALL) {
                    tmpId = tmpDef.@id;
                    if(!tmpResourceIds.contains(tmpId)) {
                        tmpResource = getResourceById(tmpId);
                        if(tmpResource) {
                            tmpLibResources.push(tmpResource);
                            tmpResourceIds.addItem(tmpId);
                        }
                    }
                }
            }
            if(type==Resource.RESOURCE_TYPE_LIBRARY || type==Resource.RESOURCE_TYPE_ALL) {
                tmpId = libDef.@id;
                if(!tmpResourceIds.contains(tmpId)) {
                    tmpResource = getResourceById(tmpId);
                    if(tmpResource) {
                        tmpLibResources.push(tmpResource);
                        tmpResourceIds.addItem(tmpId);
                    }
                }
            }
            
            if(type==Resource.RESOURCE_TYPE_LOCAL || type==Resource.RESOURCE_TYPE_ALL) {
                for each(tmpDef in libDef.Local) {
                    tmpId = tmpDef.@id;
                    if(!tmpResourceIds.contains(tmpId)) {
                        tmpResource = getResourceById(tmpId);
                        if(tmpResource) {
                            tmpLocalResources.push(tmpResource);
                            tmpResourceIds.addItem(tmpId);
                        }
                    }
                }
            }
            
            if(type==Resource.RESOURCE_TYPE_STYLE || type==Resource.RESOURCE_TYPE_ALL) {
                for each(tmpDef in libDef.Style) {
                    tmpId = tmpDef.@id;
                    if(!tmpResourceIds.contains(tmpId)) {
                        tmpResource = getResourceById(tmpId);
                        if(tmpResource) {
                            tmpStyleResources.push(tmpResource);
                            tmpResourceIds.addItem(tmpId);
                        }
                    }
                }
            }
            
            if(type==Resource.RESOURCE_TYPE_DATA || type==Resource.RESOURCE_TYPE_ALL) {
                for each(tmpDef in libDef.Data) {
                    tmpId = tmpDef.@id;
                    if(!tmpResourceIds.contains(tmpId)) {
                        tmpResource = getResourceById(tmpId);
                        if(tmpResource) {
                            tmpDataResources.push(tmpResource);
                            tmpResourceIds.addItem(tmpId);
                        }
                    }
                }
            }
            
            return [tmpDataResources, tmpLocalResources, tmpStyleResources, tmpLibResources];
        }
        
        public var loaderProgress:ILoaderProgress;
        public function updateResourceStatus(resource:Resource):void {
            logger_.debug("[updateResourceStatus] " + resource.loaderURL + "(" + resource.bytesTotal + ":" + resource.bytesLoaded + ")");
            loaderProgress && loaderProgress.setProgress(resource.name, resource.bytesTotal, resource.bytesLoaded);
        }
    }
}