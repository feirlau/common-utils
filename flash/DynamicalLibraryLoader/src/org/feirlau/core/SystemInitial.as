/* Copyright (c) 2010-2011 FeirLau.  All rights reserved. */
package org.feirlau.core {
    import flash.net.getClassByAlias;
    import flash.net.registerClassAlias;
    import flash.system.ApplicationDomain;
    
    import mx.collections.ArrayCollection;
    import mx.collections.ArrayList;
    import mx.core.Application;
    import mx.core.mx_internal;
    /**
    * For FDS, you can add it if using fds and have fds.swc.
    import mx.data.CacheDataDescriptor;
    import mx.data.DataMessageCache;
    import mx.data.DataService;
    import mx.data.ManagedObjectProxy;
    import mx.data.MessageBatch;
    import mx.data.UpdateCollectionRange;
    import mx.data.messages.DataErrorMessage;
    import mx.data.messages.DataMessage;
    import mx.data.messages.PagedMessage;
    import mx.data.messages.SequencedMessage;
    import mx.data.messages.UpdateCollectionMessage;
    import mx.data.utils.SerializationProxy;
    **/
    import mx.effects.EffectManager;
    import mx.logging.ILogger;
    import mx.logging.Log;
    import mx.managers.ISystemManager;
    /**
    * For flex message framework
    import mx.messaging.config.ConfigMap;
    import mx.messaging.messages.AcknowledgeMessage;
    import mx.messaging.messages.AcknowledgeMessageExt;
    import mx.messaging.messages.AsyncMessage;
    import mx.messaging.messages.AsyncMessageExt;
    import mx.messaging.messages.CommandMessage;
    import mx.messaging.messages.CommandMessageExt;
    import mx.messaging.messages.ErrorMessage;
    import mx.messaging.messages.HTTPRequestMessage;
    import mx.messaging.messages.MessagePerformanceInfo;
    import mx.messaging.messages.RemotingMessage;
    import mx.messaging.messages.SOAPMessage;
    **/
    import mx.resources.ResourceManager;
    import mx.styles.StyleManager;
    import mx.utils.ObjectProxy;

    /***
    * Init the application when using RSLs. Init the sdk tags in runtime library, such as [ResourceBundle], [Style], [Effect] tags.
    */
    public class SystemInitial {
        private static var logger_:ILogger = Log.getLogger("SystemInitial");
        private static var instance_:SystemInitial;
        /**
        * Use singleton and cache the loaded library bundles to avoid the reduplicate library bundles to be loaded.
        **/
        public static function getInstance():SystemInitial {
            if(null == instance_) {
                instance_ = new SystemInitial();
            }
            return instance_;
        }

        public function initApp(app:Application = null):void {
            if(app == null && Application.application is Application) {
                app = (Application.application as Application);
            }
            if(app) {
                // Include the required classes in main.swf. You can add/remove some classes as your requirement, also for import statement.
                initRequiredClasses();
                initCompiledResourceBundleNames(app);
                initCompiledStyleNames();
                initCompiledEffectTriggers();
                // If using fds/blazeds, please enable it. You can add/remove some classes as your requirement, also for import statement.
                initClassAlias();
            }
        }
        
        /**
        * Init the required classes which need to be built into main.swf.
        * You can add/remove some classes as your requirement, also for import statement.
        **/
        private function initRequiredClasses():void {
            /**
            * For FDS, you can add it if using fds and have fds.swc.
            // Include Data Service class in fds.swc
            DataService;
            **/
        }
        
        /**
        * Register the metadata tag [ResourceBundle].
        * Specify the flex sdk resource bundles to be included in the main swf:
        * 1. Resource bundles in framework_rb.swc: collections, containers, controls, core, effects, formatters, logging, SharedResources, skins, states, styles, utils, validators
        * 2. Resource bundles in rpc_rb.swc: messaging, rpc
        **/
        private var compiledResourceBundleNames:Array = ["collections", "containers", "controls", "core", "effects", "formatters", "logging", "SharedResources", "skins", "states", "styles", "utils", "validators", /** "messaging", "rpc" */];
        private function initCompiledResourceBundleNames(app:Application):void {
            try {
                var systemManager:ISystemManager = app.systemManager;
                var info:Object = systemManager.info();
                var applicationDomain:ApplicationDomain = info["currentDomain"];
                var compiledLocales:Array = info["compiledLocales"];
                ResourceManager.getInstance().installCompiledResourceBundles(applicationDomain, compiledLocales, compiledResourceBundleNames);
            } catch(err:Error) {
                logger_.error(err.getStackTrace());
            }
        }

        /**
        * Register the metadata tag [Style].
        * Register these inheriting style names, which is identified by the Style metadata, such as [Style(name="rollOverColor", type="uint", format="Color", inherit="yes")] in DateChooser, to StyleManager.
        * Otherwise there will be some style issue when using RSLs and DateChooser isn't used by main directly.
        * If used by main swf directly, it will be found by mxmlc and registered by the main swf in the generated class _Main_FlexInit.
        **/
        private var compiledStyledNames:Array = ["kerning", "iconColor", "textRollOverColor", "textDecoration", "adjustedRadius", "dividerColor", "fontThickness", "depthColors", "itemSelectionColor", "selectionDisabledColor", "letterSpacing", "rollOverColor", "itemRollOverColor", "fontSize", "shadowColor", "strokeColor", "fontWeight", "indicatorGap", "leading", "barColor", "fontSharpness", "axisTitleStyleName", "modalTransparencyDuration", "footerColors", "fontAntiAliasType", "errorColor", "horizontalGridLineColor", "backgroundDisabledColor", "modalTransparencyColor", "textIndent", "themeColor", "verticalGridLineColor", "itemDisabledColor", "modalTransparency", "todayColor", "headerColors", "textAlign", "fontFamily", "textSelectedColor", "strokeWidth", "labelWidth", "fontGridFitType", "fontStyle", "dropShadowColor", "disabledColor", "selectionColor", "dropdownBorderColor", "disabledIconColor", "modalTransparencyBlur", "color", "alternatingItemColors"];
        private function initCompiledStyleNames():void {
            try {
                for each(var compiledStyleName:String in compiledStyledNames) {
                    StyleManager.registerInheritingStyle(compiledStyleName);
                }
            } catch(err:Error) {
                logger_.error(err.getStackTrace());
            }
        }

        /**
        * Register the metadata tag [Effect].
        * Register these effect triggers.
        **/
        private function initCompiledEffectTriggers():void {
            EffectManager.mx_internal::registerEffectTrigger("addedEffect", "added");
            EffectManager.mx_internal::registerEffectTrigger("completeEffect", "complete");
            EffectManager.mx_internal::registerEffectTrigger("creationCompleteEffect", "creationComplete");
            EffectManager.mx_internal::registerEffectTrigger("focusInEffect", "focusIn");
            EffectManager.mx_internal::registerEffectTrigger("focusOutEffect", "focusOut");
            EffectManager.mx_internal::registerEffectTrigger("hideDataEffect", "hideData");
            EffectManager.mx_internal::registerEffectTrigger("hideEffect", "hide");
            EffectManager.mx_internal::registerEffectTrigger("itemsChangeEffect", "itemsChange");
            EffectManager.mx_internal::registerEffectTrigger("mouseDownEffect", "mouseDown");
            EffectManager.mx_internal::registerEffectTrigger("mouseUpEffect", "mouseUp");
            EffectManager.mx_internal::registerEffectTrigger("moveEffect", "move");
            EffectManager.mx_internal::registerEffectTrigger("removedEffect", "removed");
            EffectManager.mx_internal::registerEffectTrigger("resizeEffect", "resize");
            EffectManager.mx_internal::registerEffectTrigger("resizeEndEffect", "resizeEnd");
            EffectManager.mx_internal::registerEffectTrigger("resizeStartEffect", "resizeStart");
            EffectManager.mx_internal::registerEffectTrigger("rollOutEffect", "rollOut");
            EffectManager.mx_internal::registerEffectTrigger("rollOverEffect", "rollOver");
            EffectManager.mx_internal::registerEffectTrigger("showDataEffect", "showData");
            EffectManager.mx_internal::registerEffectTrigger("showEffect", "show");
        }
        
        /** 
        * Register the remote object classes.
        * You can add/remove some classes as your requirement, also for import statement.
        * Identified by RemoteClass tag, such as [RemoteClass(alias="flex.messaging.messages.AcknowledgeMessage")].
        **/
        private function initClassAlias():void {
            try {
                if(getClassByAlias("flex.messaging.io.ArrayCollection") == null) {
                    registerClassAlias("flex.messaging.io.ArrayCollection", ArrayCollection);
                }
                if(getClassByAlias("flex.messaging.io.ArrayList") == null) {
                    registerClassAlias("flex.messaging.io.ArrayList", ArrayList);
                }
                /**
                * For FDS, you can add it if using fds and have fds.swc.
                // ****** START FDS class alias ******
                if(getClassByAlias(">mx.data.CacheDataDescriptor") == null) {
                    registerClassAlias(">mx.data.CacheDataDescriptor", CacheDataDescriptor);
                }
                if(getClassByAlias(">mx.data.DataMessageCache") == null) {
                    registerClassAlias(">mx.data.DataMessageCache", DataMessageCache);
                }
                if(getClassByAlias("flex.messaging.io.ManagedObjectProxy") == null) {
                    registerClassAlias("flex.messaging.io.ManagedObjectProxy", ManagedObjectProxy);
                }
                if(getClassByAlias(">mx.data.MessageBatch") == null) {
                    registerClassAlias(">mx.data.MessageBatch", MessageBatch);
                }
                if(getClassByAlias("flex.data.UpdateCollectionRange") == null) {
                    registerClassAlias("flex.data.UpdateCollectionRange", UpdateCollectionRange);
                }
                if(getClassByAlias("flex.data.messages.DataErrorMessage") == null) {
                    registerClassAlias("flex.data.messages.DataErrorMessage", DataErrorMessage);
                }
                if(getClassByAlias("flex.data.messages.DataMessage") == null) {
                    registerClassAlias("flex.data.messages.DataMessage", DataMessage);
                }
                if(getClassByAlias("flex.data.messages.PagedMessage") == null) {
                    registerClassAlias("flex.data.messages.PagedMessage", PagedMessage);
                }
                if(getClassByAlias("flex.data.messages.SequencedMessage") == null) {
                    registerClassAlias("flex.data.messages.SequencedMessage", SequencedMessage);
                }
                if(getClassByAlias("flex.data.messages.UpdateCollectionMessage") == null) {
                    registerClassAlias("flex.data.messages.UpdateCollectionMessage", UpdateCollectionMessage);
                }
                if(getClassByAlias("flex.messaging.io.SerializationProxy") == null) {
                    registerClassAlias("flex.messaging.io.SerializationProxy", SerializationProxy);
                }
                // ****** END FDS ******
                **/
                
                /**
                 * For flex message framework.
                // ****** START RPC ******
                if(getClassByAlias("flex.messaging.config.ConfigMap") == null) {
                    registerClassAlias("flex.messaging.config.ConfigMap", ConfigMap);
                }
                if(getClassByAlias("flex.messaging.messages.AcknowledgeMessage") == null) {
                    registerClassAlias("flex.messaging.messages.AcknowledgeMessage", AcknowledgeMessage);
                }
                if(getClassByAlias("DSK") == null) {
                    registerClassAlias("DSK", AcknowledgeMessageExt);
                }
                if(getClassByAlias("flex.messaging.messages.AsyncMessage") == null) {
                    registerClassAlias("flex.messaging.messages.AsyncMessage", AsyncMessage);
                }
                if(getClassByAlias("DSA") == null) {
                    registerClassAlias("DSA", AsyncMessageExt);
                }
                if(getClassByAlias("flex.messaging.messages.CommandMessage") == null) {
                    registerClassAlias("flex.messaging.messages.CommandMessage", CommandMessage);
                }
                if(getClassByAlias("DSC") == null) {
                    registerClassAlias("DSC", CommandMessageExt);
                }
                if(getClassByAlias("flex.messaging.messages.ErrorMessage") == null) {
                    registerClassAlias("flex.messaging.messages.ErrorMessage", ErrorMessage);
                }
                if(getClassByAlias("flex.messaging.messages.HTTPMessage") == null) {
                    registerClassAlias("flex.messaging.messages.HTTPMessage", HTTPRequestMessage);
                }
                if(getClassByAlias("flex.messaging.messages.MessagePerformanceInfo") == null) {
                    registerClassAlias("flex.messaging.messages.MessagePerformanceInfo", MessagePerformanceInfo);
                }
                if(getClassByAlias("flex.messaging.messages.RemotingMessage") == null) {
                    registerClassAlias("flex.messaging.messages.RemotingMessage", RemotingMessage);
                }
                if(getClassByAlias("flex.messaging.messages.SOAPMessage") == null) {
                    registerClassAlias("flex.messaging.messages.SOAPMessage", SOAPMessage);
                }
                // ***** END RPC ******
                
                if(getClassByAlias("flex.messaging.io.ObjectProxy") == null) {
                    registerClassAlias("flex.messaging.io.ObjectProxy", ObjectProxy);
                }
                **/
            } catch(e:Error) {
                logger_.error(e.getStackTrace());
            }
        }
    }
}
