/* global devel: true, console: true */
(function () {
    'use strict';
    if (typeof JSA.JSAAnimation !== 'undefined') {
        return;
    }
    var root = this;
    
    JSA.textureHandler = function(data) {
        if(!data.texture) {
            var jsa = data.pack.jsa;
            data.texture = new PIXI.Texture(jsa.zip);
            data.texture.frame = new PIXI.Rectangle(data.textureOffset[0], data.textureOffset[1], data.textureOffset[2], data.textureOffset[3]);
        }
        return data.texture;
    };
    /**
     * base on pixijs: http://www.pixijs.com
     */
    JSA.JSAAnimation = function (pack) {
        var i, item, texture, textures = [];
        
        this.timeInfo = new FPS.TimeInfo(0, 0, 0);
        if (pack && pack.items) {
            for (i = 0; i < pack.items.length; i += 1) {
                item = pack.items[i];
                if (item.data && item.type == JSA.JSAType.FILE) {
                    if(JSA.isTexture(item.data.type)) {
                        texture = item.data.loadImage();
                    } else {
                        texture = new PIXI.BaseTexture(item.data.loadImage());
                        texture = new PIXI.Texture(texture);
                    }
                    if (item.data.offset) {
                        //a bug wait to be fixed, set the trim will cause the texture doesn't display
                        //texture.trim = new PIXI.Rectangle(item.data.offset[0], item.data.offset[1], item.data.offset[2], item.data.offset[3]);
                    }
                    textures.push(texture);
                }
            }
            if (pack.info && pack.info.fps) {
                this.timeInfo.interval = 1000 / pack.info.fps;
            }
        }
        
        if (textures.length == 0) {
            texture = new PIXI.BaseTexture(new Image());
            texture = new PIXI.Texture(texture);
            textures.push(texture);
        }
        PIXI.extras.MovieClip.call(this, textures);
    };
    // constructor
    JSA.JSAAnimation.prototype = Object.create( PIXI.extras.MovieClip.prototype );
    JSA.JSAAnimation.prototype.constructor = JSA.JSAAnimation;
    JSA.JSAAnimation.prototype.updateTransform = function () {
        var toUpdate = true;
        if (this.playing) {
            this.timeInfo.time = FPS.timeInfo.time;
            if (this.timeInfo.interval && this.timeInfo.preTime && this.timeInfo.getIntervalCount() < 1) {
                toUpdate = false;
            } else {
                if (this._currentTime < 0 && !this.loop) {
                    this.gotoAndStop(0);

                    if (this.onComplete) {
                        this.onComplete();
                    }
                }
                else if (this._currentTime >= this._textures.length && !this.loop) {
                    this.gotoAndStop(this._textures.length - 1);

                    if (this.onComplete) {
                        this.onComplete();
                    }
                }
                else {
                    if (this._currentTime < 0) {
                        this._currentTime = 0;
                    } else if(this._currentTime >= this._textures.length) {
                        this._currentTime = 0;
                    }
                    this._texture = this._textures[this.currentFrame];
                    this._currentTime++;
                }
            }
        }
        if(toUpdate) {
            this.timeInfo.preTime = this.timeInfo.time;
        }
        PIXI.extras.MovieClip.prototype.updateTransform.call(this);
        
    };
    JSA.JSAAnimation.prototype.update = function (deltaTime) {
        //do nothing
    };
    
    JSA.JSAContainer = function() {
        PIXI.Container.call(this);
        
        this.animations = [];
    };
    // constructor
    JSA.JSAContainer.prototype = Object.create( PIXI.Container.prototype );
    JSA.JSAContainer.prototype.constructor = JSA.JSAContainer;
    JSA.JSAContainer.prototype.addAnimation = function (animation, sync) {
        var i = this.animations.indexOf(animation);
        if (i < 0) {
            if (sync && this.animations.length > 0) {
                animation.gotoAndPlay(this.animations[0].currentFrame);
            } else {
                animation.gotoAndPlay(0);
            }
            this.addChild(animation);
            this.animations.push(animation);
        }
        return animation;
    };
    JSA.JSAContainer.prototype.removeAnimation = function (animation, dataOnly) {
        var i = this.animations.indexOf(animation);
        if (i >= 0) {
            animation.stop();
            if (!dataOnly) this.removeChild(animation);
            this.animations.splice(i, 1);
        }
        return animation;
    };
    JSA.JSAContainer.prototype.removeAnimations = function () {
        var i = this.animations.length - 1;
        for (i; i >= 0; i -= 1) {
            this.removeAnimation(this.animations[i]);
        }
    };
    JSA.JSAContainer.prototype.removeChildren = function (beginI, endI) {
        var i, removed = PIXI.Container.prototype.removeChildren.call(this, beginI, endI);
        for (i = 0; i < removed.length; i += 1) {
            this.removeAnimation(removed[i], true);
        }
        return removed;
    };
}).call(this);