/**
 * @author risker
 * Dec 28, 2013
 **/
package com.fl.textflow {
    import com.fl.component.ScrollBase;
    import com.fl.constants.ScrollPolicyConstants;
    import com.fl.event.GlobalEvent;
    import com.fl.utils.LogUtil;
    
    import flash.display.Bitmap;
    import flash.display.BlendMode;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.engine.BreakOpportunity;
    import flash.text.engine.FontLookup;
    import flash.text.engine.FontWeight;
    import flash.text.engine.RenderingMode;
    import flash.text.engine.TextBaseline;
    import flash.text.engine.TextLine;
    
    import flashx.textLayout.compose.TextFlowLine;
    import flashx.textLayout.container.ContainerController;
    import flashx.textLayout.conversion.ConversionType;
    import flashx.textLayout.conversion.TextConverter;
    import flashx.textLayout.edit.SelectionFormat;
    import flashx.textLayout.edit.SelectionManager;
    import flashx.textLayout.elements.Configuration;
    import flashx.textLayout.elements.FlowElement;
    import flashx.textLayout.elements.InlineGraphicElement;
    import flashx.textLayout.elements.LinkElement;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.events.FlowElementMouseEvent;
    import flashx.textLayout.events.StatusChangeEvent;
    import flashx.textLayout.events.TextLayoutEvent;
    import flashx.textLayout.formats.LeadingModel;
    import flashx.textLayout.formats.TextLayoutFormat;

    public class TextFlowArea extends ScrollBase {
        public static const EVENT_LINK_ELEMENT_CLICK:String = "ClickLinkElementEvent";
        
        private var LINE_HEIGHT:int = 20;
        private var MAX_NUM:int = 60;
        private var DEL_NUM:int = 20;
        public function TextFlowArea(maxNum:int = 60, delNum:int = 20, lineHeight:int = 20) {
            super();
            mouseEnabled = false;
            MAX_NUM = maxNum;
            DEL_NUM = delNum;
            LINE_HEIGHT = lineHeight;
            initTextFormat();
            hScrollPolicy = ScrollPolicyConstants.OFF;
        }
        
        protected var textFormat_:TextLayoutFormat;
        public function get textFormat():TextLayoutFormat {
            return textFormat_;
        }
        public function set textFormat(value:TextLayoutFormat):void {
            if(textFormat_ != value) {
                textFormat_ = value;
                textFlow && ((textFlow.configuration as Configuration).textFlowInitialFormat = textFormat_);
            }
        }
        
        protected function initTextFormat():void {
            textFormat_ = new TextLayoutFormat();
            textFormat_.breakOpportunity = BreakOpportunity.ANY;
            textFormat_.leadingModel = LeadingModel.ROMAN_UP;
            /**中对齐
             textFormat.dominantBaseline = TextBaseline.IDEOGRAPHIC_CENTER;
             textFormat.alignmentBaseline = TextBaseline.ASCENT;
             **/
            textFormat_.dominantBaseline = TextBaseline.DESCENT;
            textFormat_.alignmentBaseline = TextBaseline.USE_DOMINANT_BASELINE;
            textFormat_.fontFamily = "SimSun";
            textFormat_.fontWeight = FontWeight.NORMAL;
            textFormat_.fontSize = 12;
            textFormat_.fontLookup = FontLookup.DEVICE;
            textFormat_.lineHeight = LINE_HEIGHT;
            textFormat_.color = 0xFFFFFF;
            textFormat_.paddingBottom = 2;
            textFormat_.paddingTop = 2;
            textFormat_.paddingLeft = 2;
            textFormat_.paddingRight = 2;
            textFormat_.renderingMode = RenderingMode.CFF;
        }
        
        override protected function createChildren():void {
            super.createChildren();
            initView();
        }
        public var autoScroll:Boolean = true;
        public var textFlow:TextFlow;
        private var sprite:Sprite = new Sprite();
        private function initView():void {
            sprite.mouseEnabled = false;
            addChild(sprite);
            
            var config:Configuration = new Configuration();
            var selectFormat:SelectionFormat = new SelectionFormat(0x3399FF, 0.6, BlendMode.LIGHTEN, 0xffffff, 0);
            config.focusedSelectionFormat = selectFormat;
            config.textFlowInitialFormat = textFormat_;
            
            textFlow = new TextFlow(config);
            var controller:ContainerController = new ContainerController(sprite);
            textFlow.flowComposer.addController(controller);
            textFlow.addEventListener(TextLayoutEvent.SCROLL, textFlowScrollHandler);
            textFlow.addEventListener(FlowElementMouseEvent.CLICK, textClickHandler);
            textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, inlineChangeHandler);
            
            updateSelectable();
            updateFlowText();
        }
        protected function inlineChangeHandler(env:StatusChangeEvent):void {
            var inlineG:InlineGraphicElement = env.element as InlineGraphicElement;
            if(inlineG && inlineG.getStyle("smoothing") == "on" && inlineG.graphic is Loader && (inlineG.graphic as Loader).content is Bitmap) {
                ((inlineG.graphic as Loader).content as Bitmap).smoothing = true;
            }
        }
        /** update the scrollbar with the TextFlow*/
        private function textFlowScrollHandler(event:TextLayoutEvent):void {
            var pos:Number = textFlow.flowComposer.getControllerAt(0).horizontalScrollPosition;
            setHValue(pos, true, false);
            pos = textFlow.flowComposer.getControllerAt(0).verticalScrollPosition;
            setVValue(pos, true, false);
        }
        /** LickElement click handler */
        protected function textClickHandler(e:FlowElementMouseEvent):void {
            var link:LinkElement = e.flowElement as LinkElement;
            if(link) {
                dispatchEvent(new GlobalEvent(EVENT_LINK_ELEMENT_CLICK, {mouseEvent: e.originalEvent, href: link.href, target: link.target, linkInfo: link.userStyles}));
            } else {
                dispatchEvent(e);
            }
        }
        
        override public function get hScrollPolicy():String {
            return height <= 40 ? ScrollPolicyConstants.OFF : super.hScrollPolicy;
        }
        
        override public function get vScrollPolicy():String {
            return height <= 40 ? ScrollPolicyConstants.OFF : super.vScrollPolicy;
        }
        
        override public function setHValue(v:Number, toSet:Boolean = true, toScroll:Boolean = true):void {
            super.setHValue(v, toSet, toScroll);
            if(toScroll) {
                var cc:ContainerController = textFlow.flowComposer.getControllerAt(0);
                cc.horizontalScrollPosition = hValue;
            }
        }
        override public function setVValue(v:Number, toSet:Boolean = true, toScroll:Boolean = true):void {
            super.setVValue(v, toSet, toScroll);
            if(toScroll) {
                var cc:ContainerController = textFlow.flowComposer.getControllerAt(0);
                cc.verticalScrollPosition = vValue;
            }
        }
        
        override protected function scrollContent():void {
            super.scrollContent();
            
            sprite.x = _paddings.left + _scrollEdges.left;
            sprite.y = _paddings.top + _scrollEdges.top;
        }
        
        override protected function onResize():void {
            super.onResize();
            
            var cc:ContainerController = textFlow.flowComposer.getControllerAt(0);
            var tmpW:Number = width - paddings.pw - scrollEdges.pw;
            var tmpH:Number = height - paddings.ph - scrollEdges.ph;
            if(cc.compositionWidth != tmpW || cc.compositionHeight != tmpH) {
                cc.setCompositionSize(tmpW, tmpH);
                updateComposer();
            }
        }
        
        public function updateComposer():void {
            try {
                textFlow.flowComposer.composeToPosition();
                textFlow.flowComposer.updateAllControllers();
                
                var cc:ContainerController = textFlow.flowComposer.getControllerAt(0);
                var rect:Rectangle = cc.getContentBounds();
                contentWidth = rect.width;
                contentHeight = rect.height;
                
                if(stage && sprite.hitTestPoint(stage.mouseX, stage.mouseY)) {
                    var tmpP:Point = sprite.globalToLocal(new Point(stage.mouseX, stage.mouseY));
                    sprite.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER, true, false, tmpP.x, tmpP.y));
                }
            } catch(err:Error) {
                LogUtil.addLog(this, "[updateComposer] " + err.getStackTrace(), LogUtil.ERROR);
            }
        }
        
        public function clear():void {
            textFlow.replaceChildren(0, textFlow.numChildren);
            updateComposer();
            firstTime_ = true;
        }
        
        private var firstTime_:Boolean = true;
        public function appendMsg(element:FlowElement, toUpdate:Boolean = true):void {
            if(firstTime_) {
                textFlow.removeChildAt(0);
                firstTime_=false;
            }
            if(textFlow.numChildren >= MAX_NUM) {
                textFlow.replaceChildren(0, DEL_NUM);
            }
            textFlow.addChild(element);
            toUpdate && updateComposer();
        }
        
        private var flowText_:String;
        public function get flowText():String {
            var tmpS:String = "";
            if(textFlow) {
                tmpS = TextConverter.export(textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE).toString();
            }
            return tmpS;
        }
        public function set flowText(value:String):void {
            if(flowText_ != value) {
                flowText_ = value;
                updateFlowText();
            }
        }
        public function updateFlowText():void {
            if(textFlow && flowText_) {
                var tf:TextFlow = TextConverter.importToFlow(flowText_, TextConverter.TEXT_LAYOUT_FORMAT);
                if(null == tf) {
                    tf = TextConverter.importToFlow(flowText_, TextConverter.PLAIN_TEXT_FORMAT);
                }
                clear();
                var tmpChildren:Array = [];
                for(var i:int = tf.numChildren; i > 0; i--) {
                    tmpChildren.unshift(tf.getChildAt(i - 1));
                }
                for each(var tmpEl:FlowElement in tmpChildren) {
                    appendMsg(tmpEl);
                }
            }
        }
        
        private var selectable_:Boolean = true;
        public function get selectable():Boolean {
            return selectable_;
        }
        public function set selectable(value:Boolean):void {
            if(selectable_ != value) {
                selectable_ = value;
                updateSelectable();
            }
        }
        public function updateSelectable():void {
            if(textFlow) {
                if(selectable_) {
                    textFlow.interactionManager = new SelectionManager();
                    textFlow.interactionManager.selectRange(0, 0);
                } else {
                    textFlow.interactionManager = null;
                }
            }
        }
        
        public function getElementBounds(el:FlowElement):Rectangle {
            var tmpResult:Rectangle = new Rectangle();
            if(textFlow) {
                var i:int = el.getAbsoluteStart();
                var tmpFlowLine:TextFlowLine = textFlow.flowComposer.findLineAtPosition(i);
                if(tmpFlowLine) {
                    var j:int = tmpFlowLine.absoluteStart;
                    var tmpTextLine:TextLine = tmpFlowLine.getTextLine();
                    i = i - j;
                    var tmpRect1:Rectangle = tmpTextLine.getAtomBounds(i);
                    j = Math.min(i + el.textLength, tmpTextLine.atomCount - 1);
                    var tmpRect2:Rectangle = tmpTextLine.getAtomBounds(j);
                    tmpResult.x = sprite.x + tmpTextLine.x + tmpRect1.left;
                    tmpResult.y = sprite.y + tmpTextLine.y - tmpTextLine.ascent;
                    tmpResult.width = tmpRect2.x - tmpRect1.x;
                    tmpResult.height = tmpTextLine.height;
                }
            }
            return tmpResult;
        }
    }
}
