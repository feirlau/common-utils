package com.fl.extension {
    import com.fl.event.GlobalEvent;
    import com.fl.utils.TimerManager;
    
    import flash.display.GraphicsPathCommand;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.utils.getTimer;

    public class CDMasker extends Sprite {
        public static const EVENT_CD_TIME_UPDATE:String = "EVENT_CD_TIME_UPDATE";
        private var timerMgr:TimerManager;
        private var cdTime_:Number = 1000;
        private var maskWidth_:Number = 32;
        private var maskHeight_:Number = 32;
        private var maskWidthHalf_:Number = 16;
        private var maskHeightHalf_:Number = 16;
        private var maskRadius_:Number = 32;
        
        private var timer_:String;
        private var cdSpeed_:Number = 100;
        private var curTime_:Number = 0;
        
        private var preTimer:int = 0;
        public function CDMasker(w:Number = 32, h:Number = 32, cdTime:Number = 1000) {
            super();
            timerMgr = TimerManager.getInstance(cdSpeed_);
            cdTime_ = cdTime;
            maskWidth_ = w;
            maskHeight_ = h;
            maskWidthHalf_ = w / 2;
            maskHeightHalf_ = h / 2;
            maskRadius_ = Math.sqrt(Math.pow(maskWidthHalf_, 2) + Math.pow(maskHeightHalf_, 2));
            
            var maskShape:Shape = new Shape();
            maskShape.graphics.beginFill(0xff0000, 1);
            maskShape.graphics.drawRect(0, 0, w, h);
            maskShape.graphics.endFill();
            this.mask = maskShape;
            addChild(maskShape);
        }

        private var _showCDTxt:Boolean = false;
        public function get showCDTxt():Boolean {
            return _showCDTxt;
        }
        public function set showCDTxt(value:Boolean):void {
            if(_showCDTxt = value) {
                _showCDTxt = value;
                if(_showCDTxt) {
                    initCDTxt();
                    updateCDTxt();
                    addChild(cdTxt);
                } else {
                    removeChild(cdTxt);
                }
            }
        }

        public var cdTxt:TextField;
        private function initCDTxt():void {
            if(null == cdTxt) {
                cdTxt = new TextField();
                var format:TextFormat = new TextFormat();
                format.size = 20;
                format.font = "SimSun";
                format.bold = true;
                format.color = 0xFF0000;
                format.align = TextFormatAlign.CENTER;
                format.letterSpacing = 1;
                cdTxt.defaultTextFormat = format;
                cdTxt.selectable = false;
                cdTxt.mouseEnabled = false;
                cdTxt.width = width;
                cdTxt.height = 24;
                cdTxt.y = (height - cdTxt.height) / 2;
            }
        }
        
        public var minTxtCD:uint = 1000;
        public var maxTxtCD:uint = 100000;
        private function updateCDTxt():void {
            if(cdTxt) {
                if(cdTime_ < minTxtCD || curTime_ >= maxTxtCD) {
                    cdTxt.text = "";
                } else {
                    cdTxt.text = String(curTime_ >= 0 ? int(curTime_ / 1000) : 0);
                }
            }
        }
        
        public function set cdTime(value:Number):void {
            if(cdTime_ != value) {
                cdTime_ = value;
            }
        }
        public function get cdTime():Number {
            return cdTime_;
        }
        
        public function get curTime():Number {
            return curTime_;
        }
        
        public function start(curTime:Number = -1):void {
            if(curTime >= 0) curTime_ = curTime;
            preTimer = getTimer();
            if(!timer_) {
                timer_ = timerMgr.addVisualTimer(timerHandler);
            } else {
                timerMgr.startVisualTimer(timer_);
            }
        }
        
        public function stop():void {
            timerMgr.removeVisualTimer(timer_);
            timer_ = null;
            curTime_ = 0;
            reset();
            
            if(cdTxt) cdTxt.text = "";
        }
        
        public function pause():void {
            isRunning && timerMgr.stopVisualTimer(timer_);
        }
        
        public function resume():void {
            start();
        }
        
        public function get isRunning():Boolean {
            return timer_ && timerMgr.isItemRunning(timer_);
        }
        
        private function reset():void {
            graphics.clear();
            commands_ = new Vector.<int>();
            commands_.push(GraphicsPathCommand.MOVE_TO);
            commands_.push(GraphicsPathCommand.LINE_TO);
            drawData_ = new Vector.<Number>();
            drawData_.push(maskWidthHalf_, maskHeightHalf_);
            drawData_.push(maskWidthHalf_, 0);
        }
        
        public var maskColor:uint = 0x000000;
        public var maskAlpha:Number = 0.7;
        private var commands_:Vector.<int>;
        private var drawData_:Vector.<Number>;
        public function updateCd(curTime:Number):void {
            preTimer = getTimer();
            curTime_ = curTime;
            updateCDTxt();
            if(isRunning && curTime_ > 0 && curTime_ <= cdTime_) {
                reset();
                graphics.lineStyle(1, maskColor, maskAlpha);
                graphics.beginFill(maskColor, maskAlpha);
                var degree:Number = (1 - curTime_ / cdTime_);
                degree = (degree * 2 - 0.5) * Math.PI;
                var i:Number = Math.cos(degree) * maskRadius_;
                var j:Number = Math.sin(degree) * maskRadius_;
                if(!(j + maskRadius_ <= 0 && i <= 0)) {
                    commands_.push(GraphicsPathCommand.LINE_TO);
                    drawData_.push(0, 0);
                    if(!(j < maskHeightHalf_ && i < 0)) {
                        commands_.push(GraphicsPathCommand.LINE_TO);
                        drawData_.push(0, maskHeight_);
                        if(!(j > maskHeightHalf_ && i < maskWidthHalf_)) {
                            commands_.push(GraphicsPathCommand.LINE_TO);
                            drawData_.push(maskWidth_, maskHeight_);
                            if(j < 0 && i >=0) {
                                commands_.push(GraphicsPathCommand.LINE_TO);
                                drawData_.push(maskWidth_, 0);
                            }
                        }
                    }
                }
                commands_.push(GraphicsPathCommand.LINE_TO);
                drawData_.push(maskWidthHalf_ + i, maskHeightHalf_ + j);
                graphics.drawPath(commands_, drawData_);
            } else if(isRunning) {
                stop();
            }
            dispatchEvent(new GlobalEvent(EVENT_CD_TIME_UPDATE, curTime));
        }
        
        private function timerHandler(cur:Number):void {
            updateCd(curTime_ - (getTimer() - preTimer));
        }
    }
}
