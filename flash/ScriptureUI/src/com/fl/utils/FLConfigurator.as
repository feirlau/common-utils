/**
 * parse xml to fl components
    <comps>
        <Text id="myLabel" x="10" y="10" autoContentSize="true" text="waiting..."/>
        <Button x="10" y="40" label="click me" event="click:onClick"/>
        <com.fl.component.Box x="10" y="70" addFunc="addItem">
            <Text autoContentSize="true" text="waiting..."/>
            <Button label="click me" event="click:onClick"/>
        </com.fl.component.Box>
        <com.fl.demo.Custom x="10" y="130" parseFunc="parseComp" label="click me" event="click:onClick">
            some custom data, can be anything
        </com.fl.demo.Custom>
    </comps>
   the addFunc is to handler the add action
   the parseFunc is to handler the parse action
 * @author risker
 * Dec 17, 2013
 **/
package com.fl.utils {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.utils.Dictionary;
    import flash.utils.getDefinitionByName;

    public class FLConfigurator {
        public function FLConfigurator() {
        }
        
        private static var clzs:Dictionary = new Dictionary();
        public static function register(clz:Class, name:String = null):void {
            if(!clz) return;
            name ||= FLUtil.getClassName(clz);
            clzs[name] = clz;
        }
        public static function unregister(name:*):void {
            if(!name) return;
            if(name is Class) {
                name = FLUtil.getClassName(name);
            }
            delete clzs[name];
        }

        /**
         * Parses a string as xml.
         * @param string The xml string to parse.
         * @param p The event handlers holder
         * @param addFunc The function to add child
         * @return the root comp lists
         */
        public static function parseXMLString(string:String, p:Object = null, addFunc:Function = null):Array {
            var arr:Array = [];
            try {
                var xml:XML = new XML(string);
                arr = parseXML(xml, p, addFunc);
            } catch(e:Error) {
                LogUtil.addLog(FLConfigurator, e.getStackTrace(), LogUtil.ERROR);
            }
            return arr;
        }
        
        /**
         * Parses xml and creates componetns based on it.
         * @param p The event handlers holder
         * @param addFunc The function to add child or handler the child
         * @return the root comp lists
         */
        public static function parseXML(xml:XML, p:Object = null, addFunc:Function = null):Array {
            var arr:Array = [];
            // root tag should contain one or more component tags
            for(var i:int = 0; i < xml.children().length(); i++) {
                var comp:XML = xml.children()[i];
                var compInst:* = parseComp(comp, p);
                if(compInst != null) {
                    arr.push(compInst);
                    FLUtil.apply(addFunc, compInst);
                }
            }
            return arr;
        }

        /**
         * Parses a single component's xml.
         * @param xml The xml definition for this component.
         * @param p The event handlers holder
         * @param addFunc The function to add child or handler the child
         * @return A component instance.
         */
        private static function parseComp(xml:XML, p:Object = null, addFunc:Function = null):DisplayObject {
            var compInst:Object;
            var specialProps:Object = {};
            try {
                //get class instance from register or by name
                var name:String = xml.name().localName;
                var classRef:Class = clzs[name] as Class;
                classRef ||= getDefinitionByName(name) as Class;
                compInst = new classRef();

                // id is special case, maps to name as well.
                var id:String = xml.@id.toString();
                if(id != "") {
                    compInst.name = id;
                    // if id exists on parent as a public property, assign this component to it.
                    if(p.hasOwnProperty(id)) {
                        p[id] = compInst;
                    }
                }

                // event is another special case
                if(xml.@event.toString() != "") {
                    // events are in the format: event="eventName:eventHandler"
                    // i.e. event="click:onClick"
                    var parts:Array = xml.@event.split(":");
                    var eventName:String = parts[0];
                    var handler:String = parts[1];
                    if(p.hasOwnProperty(handler)) {
                        // if event handler exists on parent as a public method, assign it as a handler for the event.
                        compInst.addEventListener(eventName, p[handler]);
                    }
                }

                // every other attribute handled essentially the same
                for each(var attrib:XML in xml.attributes()) {
                    var prop:String = attrib.name().toString();
                    // if the property exists on the component, assign it.
                    if(compInst.hasOwnProperty(prop)) {
                        // special handling to correctly parse booleans
                        if(compInst[prop] is Boolean) {
                            compInst[prop] = attrib == "true";
                        }
                        
                        compInst[prop] = attrib;
                    }
                }
                var parse:String = xml.@parseFunc.toString();
                if(parse && compInst.hasOwnProperty(parse)) {
                    FLUtil.apply(compInst[parse], xml);
                } else {
                    var func:String = xml.@addFunc.toString();
                    func ||= "addChild";
                    addFunc ||= compInst[func];
                    
                    var cs:XMLList = xml.children();
                    // child nodes will be added as children to the instance just created.
                    for(var j:int = 0; j < cs.length(); j++) {
                        var child:DisplayObject = parseComp(cs[j], p);
                        if(child != null) {
                            FLUtil.apply(addFunc, child);
                        }
                    }
                }
            } catch(e:Error) {
                LogUtil.addLog(FLConfigurator, e.getStackTrace(), LogUtil.ERROR);
            }
            return compInst as DisplayObject;
        }
    }
}
