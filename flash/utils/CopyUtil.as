package utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.describeType;
	
	import mx.collections.ArrayCollection;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.managers.SystemManager;
	import mx.utils.UIDUtil;
	
	public class CopyUtil
	{
		public function CopyUtil()
		{
		}
		
		public static function clone(instance:Object, deep:Boolean=true):Object {
			var newInstance:Object = instance;
			if(deep&&instance&&!isPrimitive(instance)) {
				var classRef:Class = instance['constructor'] as Class;
				var classInfo:XML = describeType(instance);
				var propertyName:String;
				var propertyValue:Object;
				try {
					newInstance = new classRef();
				}catch(e:Error) {
					newInstance = instance;
					return newInstance;
				}
				var comp:UIComponent = newInstance as UIComponent;
				
				for each(var v:XML in classInfo..variable) {
					propertyName = v.@name;
					propertyValue = instance[propertyName];
					if(isDisplayObject(comp)) {
						if(propertyName=="uid") {
							
						}else if(propertyName=="id") {
							comp.id = UIDUtil.createUID();
						}else if(isPrimitive(propertyValue)) {
							newInstance[propertyName] = propertyValue;
						}
						continue;
					}else if(propertyValue!=null) {
						cloneProperty(propertyName, propertyValue, newInstance, deep);
					}
				}
				for each(var a:XML in classInfo..accessor) {
					if(a.@access == 'readwrite') {
						propertyName = a.@name;
						propertyValue = instance[propertyName];
						if(isDisplayObject(comp)) {
							if(propertyName=="uid") {
							
							}else if(propertyName=="id") {
								comp.id = UIDUtil.createUID();
							}else if(isPrimitive(propertyValue)) {
								newInstance[propertyName] = propertyValue;
							}else if(propertyValue!=null) {
								cloneProperty(propertyName, propertyValue, newInstance, deep);
							}
						}else if(propertyValue!=null) {
							cloneProperty(propertyName, propertyValue, newInstance, deep);
						}
					}
				}
				if(comp) {
					for(var i:int=0; i<comp.numChildren; i++) {
						var child:DisplayObject = clone(comp.getChildAt(i), deep) as DisplayObject;
						(newInstance as UIComponent).addChild(child);
					}
				}
			}
			return newInstance;
		}
		
		public static function cloneProperty(propertyName:String, propertyValue:Object, instance:Object, deep:Boolean=true):void {
			if(!deep) {
				instance[propertyName] = propertyValue;
				return;
			}
			if(propertyValue is Array) {
                instance[propertyName] = cloneArray(propertyValue as Array, deep);
            }else if(propertyValue is ArrayCollection) {
                instance[propertyName] = new ArrayCollection(cloneArray(ArrayCollection(propertyValue).source, deep));
            }else{
                instance[propertyName] = clone(propertyValue, deep);
            }
		}
		
		public static function cloneArray(instance:Array, deep:Boolean=true):Array {
            if(!deep) return instance;
            
            var array:Array = new Array;
            for(var i:int=0; i<instance.length; i++) {
                if(instance[i] is Array) {
                    array[i] = cloneArray(instance[i], deep);
                }else if(instance[i] is ArrayCollection ) {
                    array[i] = new ArrayCollection(cloneArray(ArrayCollection(instance[i]).source , deep));
                }else {
                    array[i] = clone(instance[i], deep);;
                }
            }
            return array;
        }
        
        public static function isPrimitive(o:Object):Boolean {
        	var result:Boolean = false;
        	if((o is Boolean)||(o is uint)||(o is int)||(o is Number)||(o is String)) {
        		result = true;
        	}
        	return result;
        }
        
        public static function isDisplayObject(o:Object):Boolean {
        	var result:Boolean = false;
        	if((o is DisplayObject)||(o is IFlexDisplayObject)||(o is Sprite)) {
        		result = true;
        	}
        	return result;
        }
	}
}