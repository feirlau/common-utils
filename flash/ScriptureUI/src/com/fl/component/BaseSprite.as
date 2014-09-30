package com.fl.component {
    import com.fl.event.GlobalEvent;
    import com.fl.utils.LogUtil;
    
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    
    import org.as3commons.ui.framework.core.as3commons_ui;
    import org.as3commons.ui.layer.tooltip.ToolTipAdapter;
    import org.as3commons.ui.lifecycle.lifecycle.LifeCycleView;
    
    use namespace as3commons_ui;
    public class BaseSprite extends LifeCycleView {
        public static const INVALIDATE_RESIZE:String = "resize";
        public static const INVALIDATE_MOVE:String = "move";
        public static const INVALIDATE_PROP:String = "prop";
        
        public static const EVENT_MOVE:String = "EVENT_MOVE";
        public static const EVENT_RESIZE:String = "EVENT_RESIZE";
        public static const EVENT_RAW_RESIZE:String = "EVENT_RAW_RESIZE";
        public static const EVENT_RENDER:String = "EVENT_RENDER";
        public static const EVENT_CHILDREN_CHANGED:String = "EVENT_CHILDREN_CHANGED";
        public static const EVENT_DATA_CHANGED:String = "EVENT_DATA_CHANGED";
        
        public function BaseSprite() {
            super();
            
            tabEnabled = tabChildren = false;
        }
        
        protected var _rawChangeEnable:Boolean = false;
        /**
         * Sets/gets whether this component is enabled or not.
         */
        public function set rawChangeEnable(value:Boolean):void {
            if(_rawChangeEnable != value) {
                _rawChangeEnable = value;
                updateRawChangeState();
            }
        }
        public function get rawChangeEnable():Boolean {
            return _rawChangeEnable;
        }
        protected function updateRawChangeState():void {
            if(_rawChangeEnable) {
                addEventListener(Event.ADDED, addedHandler);
                addEventListener(Event.REMOVED, removedHandler);
                updateRawSize(true);
            } else {
                removeEventListener(Event.ADDED, addedHandler);
                removeEventListener(Event.REMOVED, removedHandler);
            }
        }
        
        protected function addedHandler(env:Event):void {
            var v:DisplayObject = env.target as DisplayObject;
            if(isRawChildren(v)) {
                if(v is BaseSprite) {
                    v.addEventListener(EVENT_RESIZE, childrenResizeHandler, false, 0, true);
                    v.addEventListener(EVENT_MOVE, childrenMoveHandler, false, 0, true);
                }
                updateRawSize(true);
                dispatchEvent(new GlobalEvent(EVENT_CHILDREN_CHANGED, env));
            }
        }
        protected function removedHandler(env:Event):void {
            var v:DisplayObject = env.target as DisplayObject;
            if(isRawChildren(v)) {
                if(v is BaseSprite) {
                    v.removeEventListener(EVENT_RESIZE, childrenResizeHandler);
                    v.removeEventListener(EVENT_MOVE, childrenMoveHandler);
                }
                updateRawSize(true);
                dispatchEvent(new GlobalEvent(EVENT_CHILDREN_CHANGED, env));
            }
        }
        protected function isRawChildren(v:DisplayObject):Boolean {
            return v && v.parent == this;
        }
        protected function childrenResizeHandler(env:Event):void {
            updateRawSize(true);
        }
        protected function childrenMoveHandler(env:Event):void {
            updateRawSize(true);
        }
        private var _rawWidth:Number = Number.NaN;
        public function get rawWidth():Number {
            if(isNaN(_rawWidth)) {
                updateRawSize();
            }
            return _rawWidth;
        }
        private var _rawHeight:Number = Number.NaN;
        public function get rawHeight():Number {
            if(isNaN(_rawHeight)) {
                updateRawSize();
            }
            return _rawHeight;
        }
        public function updateRawSize(fireEvent:Boolean = false):void {
            if(fireEvent) {
                _rawWidth = NaN;
                _rawHeight = NaN;
                dispatchEvent(new GlobalEvent(EVENT_RAW_RESIZE));
            } else {
                var w:Number = 0;
                var h:Number = 0;
                for(var i:int = 0; i < numChildren; i++) {
                    var v:DisplayObject = getChildAt(i);
                    if(isRawChildren(v)) {
                        w = Math.max(w, v.x + v.width);
                        h = Math.max(h, v.y + v.height);
                    }
                }
                _rawWidth = isNaN(w) ? 0 : w;
                _rawHeight = isNaN(h) ? 0 : h;
            }
        }
        
        ///////////////////////////////////
        // lifecycle hooks start
        ///////////////////////////////////
        protected var _inited:Boolean = false;
        public function get inited():Boolean {
            return _inited;
        }
        
        /**
         * init()->createChildren()->postInit()
         * When it is invoked
         *
         *    Once for a component
         *    Right after the component has been registered with LifeCycle – if the component already has been added to the display list.
         *    Immediately after the component has been added to the display list – if the component was not in the display list the time it has been registered with LifeCycle.
         *
         * Purpose
         *
         *    Set up initial property values
         *    Set up general event listeners
         *    Perform display list related operations such as calculating styles that depend on parent components or the display list depth of the component
         *    Create and add all sub components
         *
         **/
        override protected function init():void {
            super.init();
        }
        /**
         * init()->createChildren()->postInit()
         * When it is invoked
         *    After inited
         */
        override protected function createChildren():void {
            super.createChildren();
        }
        
        /**
         * init()->createChildren()->postInit()
         **/
        override as3commons_ui function init_internal():void {
            super.init_internal();
            postInit();
            _inited = true;
        }
        /**
        * init()->createChildren()->postInit()
        **/
        protected function postInit():void {
        }
        
        /**invoked before init()*/
        override protected function onAddedToStage():void {
            super.onAddedToStage();
        }
        override protected function onRemovedFromStage():void {
            super.onRemovedFromStage();
        }
        
        /**
         * When it is invoked
         * 
         *    LifeCycle triggers the onValidate() callback of a LifeCycle adapter whenever the component has been invalidated beforehand for the validation phase (first phase).
         * 
         * Purpose
         * 
         *    Check and update properties
         *    Set properties to children or other objects (which will probably invalidate them again for the first phase)
         *    Invalidate the component for the calculation or/and the rendering phase.
         * 
         * invalidate(property), invalidates the component so that its validation method gets called during the next validation cycle.
         **/
        override protected function validate():void {
            super.validate();
            
            if(isInvalid(INVALIDATE_MOVE)) {
                onMove();
            }
            if(isInvalid(INVALIDATE_RESIZE)) {
                onResize();
            }
            if(isInvalid(INVALIDATE_PROP)) {
                onProp();
            }
        }
        
        protected function onMove():void {
            scheduleRendering(INVALIDATE_MOVE);
        }
        private var oldX:Number = 0;
        private var oldY:Number = 0;
        protected function dispatchMoveEvent(force:Boolean = false):void {
            if(oldX != x || oldY != y || force) {
                dispatchEvent(new GlobalEvent(EVENT_MOVE, [oldX, oldY]));
                oldX = x;
                oldY = y;
            }
        }
        
        protected function onResize():void {
            if(autoClip) {
                scrollRect = clipContent ? new Rectangle(0, 0, width, height) : null;
            }
            
            scheduleRendering(INVALIDATE_RESIZE);
        }
        private var oldW:Number = 0;
        private var oldH:Number = 0;
        protected function dispatchResizeEvent(force:Boolean = false):void {
            if(oldW != width || oldH != height || force) {
                dispatchEvent(new GlobalEvent(EVENT_RESIZE, [oldW, oldH]));
                oldW = width;
                oldH = height;
            }
        }
        
        protected function onProp():void {
            scheduleRendering(INVALIDATE_PROP);
        }
        
        /**
         * When it is invoked
         * 
         *     Whenever the component has been invalidated beforehand for the defaults calculation phase (second phase).
         * 
         * Purpose
         * 
         *     Calculate values for all properties not set yet
         *     Update properties
         *     Set properties to children or other objects (which will probably invalidate them again for the first phase)
         *     Invalidate the component for the rendering phase. You cannot invalidate the component here for the defaults calculation phase again.
         * 
         * invalidateDefaults(property), invalidates the component so that its calculate defaults method gets called during the next validation cycle.
         **/
        override protected function calculateDefaults():void {
            super.calculateDefaults();
        }
        
        /**
         * When it is invoked
         * 
         *     Whenever the component has been invalidated beforehand for the rendering phase (third phase).
         *     
         * Purpose
         * 
         *     Execute the update of the component’s appearance.
         *     Perform some drawings.
         *     Layout children.
         *     You cannot invalidate the component here for any of the phases. The component already must have set all properties before entering the rendering phase.
         * 
         * scheduleRendering(property), invalidates the component so that its render method gets called during the next validation cycle.
         **/
        override protected function render():void {
            super.render();
            
            if(shouldRender(INVALIDATE_RESIZE) || shouldRender(INVALIDATE_PROP)) {
                updateGraphics();
            }
            dispatchEvent(new GlobalEvent(EVENT_RENDER));
        }
        protected function updateGraphics():void {
            if(null != graphicsHandler) {
                graphicsHandler(graphics, width, height);
            }
        }
        /**
         * When it is invoked
         * 
         *     After the component has been unregistered from LifeCycle.
         * 
         * Purpose
         * 
         *     Remove all foreign references and event registrations to make the component eligible for garbage collection.
         **/
        override protected function onCleanUp():void {
            super.onCleanUp();
        }
        ///////////////////////////////////
        // lifecycle hooks end
        ///////////////////////////////////
        
        /**
         *  @private
         *  This property allows access to the Player's native implementation
         *  of the 'width' property, which can be useful since components
         *  can override 'width' and thereby hide the native implementation.
         *  Note that this "base property" is final and cannot be overridden,
         *  so you can count on it to reflect what is happening at the player level.
         */
        public final function get $width():Number {
            return super.width;
        }
        
        /**
         *  @private
         *  This property allows access to the Player's native implementation
         *  of the 'height' property, which can be useful since components
         *  can override 'height' and thereby hide the native implementation.
         *  Note that this "base property" is final and cannot be overridden,
         *  so you can count on it to reflect what is happening at the player level.
         */
        public final function get $height():Number {
            return super.height;
        }
        
        /**
         * Moves the component to the specified position.
         * @param xpos the x position to move the component
         * @param ypos the y position to move the component
         */
        public function move(xpos:Number, ypos:Number):void {
            x = xpos;
            y = ypos;
        }
        
        /**
         * Sets the size of the component.
         * @param w The width of the component.
         * @param h The height of the component.
         */
        public function setSize(w:Number, h:Number):void {
            width = w;
            height = h;
        }
        
        ///////////////////////////////////
        // getter/setters
        ///////////////////////////////////
        /**
         * Overrides the setter for x to always place the component on a whole pixel.
         */
        override public function set x(value:Number):void {
            if(x != value) {
                super.x = value;
                invalidate(INVALIDATE_MOVE);
                dispatchMoveEvent();
            }
        }
        
        /**
         * Overrides the setter for y to always place the component on a whole pixel.
         */
        override public function set y(value:Number):void {
            if(y != value) {
                super.y = value;
                invalidate(INVALIDATE_MOVE);
                dispatchMoveEvent();
            }
        }
        
        protected var _width:Number = 0;
        /**
         * Sets/gets the width of the component.
         */
        override public function set width(w:Number):void {
            if(_width != w) {
                _width = w;
                invalidate(INVALIDATE_RESIZE);
                dispatchResizeEvent();
            }
        }
        override public function get width():Number {
            return _width;
        }
        
        
        protected var _height:Number = 0;
        /**
         * Sets/gets the height of the component.
         */
        override public function set height(h:Number):void {
            if(_height != h) {
                _height = h;
                invalidate(INVALIDATE_RESIZE);
                dispatchResizeEvent();
            }
        }
        override public function get height():Number {
            return _height;
        }
        
        protected var _tag:int = -1;
        /**
         * Sets/gets in integer that can identify the component.
         */
        public function set tag(value:int):void {
            if(_tag != value) {
                _tag = value;
            }
        }
        public function get tag():int {
            return _tag;
        }
        
        protected var _enabled:Boolean = true;
        /**
         * Sets/gets whether this component is enabled or not.
         */
        public function set enabled(value:Boolean):void {
            if(_enabled != value) {
                _enabled = value;
                mouseEnabled = mouseChildren = value;
                invalidate(INVALIDATE_PROP);
            }
        }
        public function get enabled():Boolean {
            return _enabled;
        }
        
        /**
         * Sets/gets whether this component's scrollRect is set.
         */
        public var autoClip:Boolean = true;
        protected var _clipContent:Boolean = true;
        /**
         * Sets/gets whether this component is constraint on its size.
         */
        public function set clipContent(value:Boolean):void {
            if(_clipContent != value) {
                _clipContent = value;
                invalidate(INVALIDATE_RESIZE);
            }
        }
        public function get clipContent():Boolean {
            return _clipContent;
        }
        
        protected var _graphicsHandler:Function = defaultGraphics;
        /**
         * Sets/gets whether this component is enabled or not.
         */
        public function set graphicsHandler(value:Function):void {
            if(_graphicsHandler != value) {
                _graphicsHandler = value;
                invalidate(INVALIDATE_PROP);
            }
        }
        public function get graphicsHandler():Function {
            return _graphicsHandler;
        }
        protected function defaultGraphics(g:Graphics, w:Number, h:Number):void {
            g.clear();
            if(w > 0 && h > 0) {
                g.beginFill(0x0, 0);
                g.lineStyle(0, 0x0, 0);
                g.drawRect(0, 0, w, h);
                g.endFill();
            }
        }
        
        protected var _data:*;
        public function set data(value:*):void {
            if(_data != value) {
                _data = value;
                dispatchEvent(new GlobalEvent(EVENT_DATA_CHANGED));
            }
        }
        public function get data():* {
            return _data;
        }
        
        protected var _tooltipType:int = 0;
        public function set tooltipType(value:int):void {
            if(_tooltipType != value) {
                _tooltipType = value;
                updateTooltipType();
            }
        }
        public function get tooltipType():int {
            return _tooltipType;
        }
        protected function updateTooltipType():void {
            if(_tooltipType == 0) {
                removeEventListener(MouseEvent.ROLL_OVER, tipsOverHandler);
                removeEventListener(MouseEvent.ROLL_OUT, tipsOutHandler);
            } else {
                addEventListener(MouseEvent.ROLL_OVER, tipsOverHandler);
                addEventListener(MouseEvent.ROLL_OUT, tipsOutHandler);
            }
        }
        protected function tipsOverHandler(env:MouseEvent):void {
            showTips();
        }
        protected function tipsOutHandler(env:MouseEvent):void {
            hideTips();
        }
        public function showTips(isUpdate:Boolean = false):void {
            var adp:ToolTipAdapter = UIGlobal.tooltip.currentAdapter;
            if(adp && adp.owner == this) {
                if(_tooltip) {
                    adp.updateContent(_tooltip);
                } else {
                    UIGlobal.tooltip.hide();
                }
            } else if(_tooltip && !isUpdate) {
                UIGlobal.tooltip.show(this, _tooltip);
            }
        }
        public function hideTips():void {
            var adp:ToolTipAdapter = UIGlobal.tooltip.currentAdapter;
            if(adp && adp.owner == this) {
                UIGlobal.tooltip.hide();
            }
        }
        
        protected var _tooltip:*;
        public function set tooltip(value:*):void {
            if(_tooltip != value) {
                _tooltip = value;
                showTips(true);
            }
        }
        public function get tooltip():* {
            return _tooltip;
        }
        
        public function get focused():Boolean {
            return stage && stage.focus == this;
        }
        public function setFocus():void {
            try { stage && (stage.focus = this); } catch(e:Error) {LogUtil.addLog(this, e.message, LogUtil.ERROR)};
        }
    }
}
