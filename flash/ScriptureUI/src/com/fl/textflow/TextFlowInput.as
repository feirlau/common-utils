package com.fl.textflow {
    import com.fl.component.BaseComponent;
    import com.fl.utils.FLUtil;
    
    import flash.display.BlendMode;
    import flash.display.Sprite;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import flash.text.TextFormat;
    import flash.text.engine.FontLookup;
    import flash.text.engine.FontWeight;
    import flash.text.engine.RenderingMode;
    import flash.text.engine.TextBaseline;
    import flash.ui.Mouse;
    import flash.ui.MouseCursor;
    import flash.utils.ByteArray;
    
    import flashx.textLayout.container.ContainerController;
    import flashx.textLayout.edit.SelectionFormat;
    import flashx.textLayout.elements.Configuration;
    import flashx.textLayout.elements.FlowElement;
    import flashx.textLayout.elements.FlowGroupElement;
    import flashx.textLayout.elements.FlowLeafElement;
    import flashx.textLayout.elements.ParagraphElement;
    import flashx.textLayout.elements.SpanElement;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.events.UpdateCompleteEvent;
    import flashx.textLayout.formats.BaselineOffset;
    import flashx.textLayout.formats.LeadingModel;
    import flashx.textLayout.formats.LineBreak;
    import flashx.textLayout.formats.TextAlign;
    import flashx.textLayout.formats.TextDecoration;
    import flashx.textLayout.formats.TextLayoutFormat;
    import flashx.textLayout.formats.VerticalAlign;
    import flashx.undo.UndoManager;
    
    public class TextFlowInput extends BaseComponent {
        public static const NAME:String = "TextFlowInput";
        public var textFlow:TextFlow;
        private var sprite:Sprite = new Sprite();
        private var editMgr:TextFlowEditManager;
        private var controller:ContainerController;
        
        public function TextFlowInput() {
            super();
            height = 20;
            initTextFormat();
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
            textFormat = new TextLayoutFormat();
            textFormat.leadingModel = LeadingModel.ROMAN_UP;
            textFormat.firstBaselineOffset = BaselineOffset.LINE_HEIGHT;
            textFormat.dominantBaseline = TextBaseline.IDEOGRAPHIC_CENTER;
            textFormat.alignmentBaseline = TextBaseline.ASCENT;
            textFormat.fontFamily = "SimSun";
            textFormat.fontWeight = FontWeight.NORMAL;
            textFormat.fontSize = 12;
            textFormat.fontLookup = FontLookup.DEVICE;
            textFormat.lineHeight = _lineHeight;
            textFormat.color = 0xFFFFFF;
            textFormat.renderingMode = RenderingMode.CFF;
            textFormat.lineBreak = _lineBreak;
            textFormat.textAlign = TextAlign.LEFT
            textFormat.verticalAlign = VerticalAlign.MIDDLE;
            textFormat.textDecoration = TextDecoration.NONE;
        }
        
        override protected function initStyle():void {
            _selfStyles.push("state");
            super.initStyle();
        }
        
        override protected function createChildren():void {
            super.createChildren();
            initView();
            addEventListener(MouseEvent.MOUSE_OVER, overHandler);
            addEventListener(MouseEvent.MOUSE_OUT, outHandler);
            addEventListener(MouseEvent.CLICK, clickHandler);
        }
        
        private function initView():void {
            sprite.name = NAME;
            sprite.y = 0;
            sprite.x = 0;
            addChild(sprite);
            
            var config:Configuration = new Configuration();
            config.manageEnterKey = false;
            
            config.textFlowInitialFormat = textFormat;
            
            textFlow = new TextFlow(config);

            controller = new ContainerController(sprite);
            controller.verticalAlign = VerticalAlign.TOP;
            textFlow.flowComposer.addController(controller);
            editMgr = new TextFlowEditManager(new UndoManager());
            editMgr.isPlain = true;
            editMgr.textInput = this;
            textFlow.interactionManager = editMgr;
            editMgr.selectAll();
            
            updateLineBreak(false);
            updateLineHeight();
        }
        
        private var paragraph_:ParagraphElement;
        public function get paragraph():ParagraphElement {
            paragraph_ = textFlow.getChildAt(0) as ParagraphElement;
            return paragraph_;
        }
        
        override public function get focused():Boolean {
            return editMgr && editMgr.focused;
        }
        
        override public function setFocus():void {
            super.setFocus();
            clickHandler(null);
        }
        
        private function overHandler(env:MouseEvent):void {
            Mouse.cursor = MouseCursor.IBEAM;
        }
        private function outHandler(env:MouseEvent):void {
            Mouse.cursor = MouseCursor.AUTO;
        }
        
        private function clickHandler(env:MouseEvent):void {
            if(env == null) {
                editMgr.setFocus();
            } else if(env.target == this) {
                if(!editMgr.focused) {
                    var tmpP:ParagraphElement = paragraph;
                    var i:int = tmpP.getAbsoluteStart() + tmpP.textLength;
                    editMgr.selectRange(i, i);
                    editMgr.refreshSelection();
                    controller.scrollToRange(i,i);
                    editMgr.setFocus();
                }
            }
            FLUtil.setIME(true);
        }
        
        private var _lineHeight:int = 16;
        public function get lineHeight():int {
            return _lineHeight;
        }
        public function set lineHeight(value:int):void {
            if(_lineHeight != value) {
                _lineHeight = value;
                textFlow && updateLineHeight();
            }
        }
        public function updateLineHeight(recompose:Boolean = true):void {
            textFormat.lineHeight = _lineHeight;
            textFlow.lineHeight = _lineHeight;
            recompose && textFlow.flowComposer.updateAllControllers();
        }
        
        /**多行输入：LineBreak.TO_FIT*/
        private var _lineBreak:String = LineBreak.EXPLICIT;
        public function get lineBreak():String {
            return _lineBreak;
        }
        public function set lineBreak(value:String):void {
            if(_lineBreak != value) {
                _lineBreak = value;
                textFlow && updateLineBreak();
            }
        }
        public function updateLineBreak(recompose:Boolean = true):void {
            textFormat.lineBreak = _lineBreak;
            textFlow.lineBreak = _lineBreak;
            recompose && textFlow.flowComposer.updateAllControllers();
        }
        
        override protected function onResize():void {
            super.onResize();
            updateCompositionSize();
        }
        override protected function onStyle():void {
            super.onStyle();
            updateCompositionSize();
        }
        private function updateCompositionSize():void {
            sprite.x = paddings.left;
            sprite.y = paddings.top;
            var cc:ContainerController = textFlow.flowComposer.getControllerAt(0);
            cc.setCompositionSize(width - paddings.pw, height - paddings.ph);
        }
        
        public function insertElement(flowEl:FlowElement):void {
            if(null == flowEl) return;
            if(editMgr.isRangeSelection()) {
                editMgr.deleteText();
            }
            var tmpText:String = flowEl.getText();
            if(!tmpText) tmpText = " ";
            if(!acceptText(tmpText)) return;
            var i:int = editMgr.absoluteStart;
            var tmpP:ParagraphElement = paragraph;
            var e:FlowLeafElement = tmpP.findLeaf(i);
            var index:int = tmpP.getChildIndex(e);
            if(i == e.getAbsoluteStart()) {
                
            } else if(i == e.getAbsoluteStart() + e.textLength - 1) {
                index++;
            } else {
                e.splitAtPosition(i - e.getAbsoluteStart());
                index++;
            }
            if(!(flowEl.lineHeight is Number) || flowEl.lineHeight < textFormat.lineHeight) {
                flowEl.lineHeight = textFormat.lineHeight;
            }
            tmpP.addChildAt(index, flowEl);
            i = flowEl.getAbsoluteStart() + flowEl.textLength;
            updateComposer(i);
        }
        
        public function insertString(str:String):void {
            if(str) {
                str = str.replace(/\n/g, " ");
                if(!acceptText(str)) return;
                var span:SpanElement = new SpanElement();
                span.text = str;
                span.format = textFormat;
                insertElement(span);
            }
        }
        
        public function updateComposer(scrollP:Number = 0):void {
            try {
                textFlow.flowComposer.composeToPosition(int.MAX_VALUE);
                editMgr.updateAllControllers();
                editMgr.selectRange(scrollP, scrollP);
                editMgr.refreshSelection();
                controller.scrollToRange(scrollP, scrollP);
            } catch(err:Error) {
            }
        }
        
        public function acceptText(value:String):Boolean {
            return !(isMaxChars(value) || isMaxShowWidth(value) || isMaxBytes(value) || filter(value));
        }
        
        public var filterFunc:Function;
        private function filter(value:String):Boolean {
            var tmpResult:Boolean = false;
            if(null != filterFunc) {
                tmpResult = filterFunc(value);
            } else {
                tmpResult = defaultFilter(value);
            }
            return tmpResult;
        }
        
        private var includeStr_:String;
        public function get includeStr():String {
            return includeStr_;
        }
        public function set includeStr(value:String):void {
            if(includeStr_ != value) {
                includeStr_ = value;
                includeReg = new RegExp(includeStr);
            }
        }
        
        private var excludeStr_:String;
        public function get excludeStr():String {
            return excludeStr_;
        }
        public function set excludeStr(value:String):void {
            if(excludeStr_ != value) {
                excludeStr_ = value;
                excludeReg = new RegExp(excludeStr_);
            }
        }
        
        private var includeReg:RegExp;
        private var excludeReg:RegExp;
        private function defaultFilter(value:String):Boolean {
            var tmpResult:Boolean = false;
            if(value && includeReg) {
                tmpResult = (null == value.match(includeReg));
            }
            if(!tmpResult && value && excludeReg) {
                tmpResult = (null != value.match(excludeReg));
            }
            return tmpResult;
        }
        
        public var maxBytes:int = -1;
        private function isMaxBytes(value:String):Boolean {
            var tmpResult:Boolean = false;
            var text:String = textFlow ? textFlow.getText() : null;
            if(maxBytes >= 0 && text != null && value) {
                var tmpBytes:ByteArray = new ByteArray();
                tmpBytes.writeUTFBytes(text);
                tmpBytes.writeUTFBytes(value);
                if(tmpBytes.length > maxBytes) {
                    tmpResult = true;
                }
            }
            return tmpResult;
        }
        
        public var maxChars:int = -1;
        private function isMaxChars(value:String):Boolean {
            var tmpResult:Boolean = false;
            var text:String = textFlow ? textFlow.getText() : null;
            if(maxChars >= 0 && text != null && value) {
                if((text + value).length > maxChars) {
                    tmpResult = true;
                }
            }
            return tmpResult;
        }
        
        public var maxShowWidth:int = -1;
        private function isMaxShowWidth(value:String):Boolean {
            var tmpResult:Boolean = false;
            var text:String = textFlow ? textFlow.getText() : null;
            if(maxShowWidth >= 0 && text != null && value) {
                if(FLUtil.getWordWidth(text + value) > maxShowWidth) {
                    tmpResult = true;
                }
            }
            return tmpResult;
        }
        
        public function clear():void {
            textFlow.replaceChildren(0, textFlow.numChildren);
            updateComposer();
        }
    }
}
