/* global devel: true, console: true */
(function () {
    'use strict';
    if (typeof FLUtils !== 'undefined') {
        return;
    }
    var root = this,
        FLUtils = function () {
        };
    
    FLUtils.nullFunc = function () {
        log(arguments);
    };
    
    if (typeof exports !== 'undefined') {
        if (typeof module !== 'undefined' && module.exports) {
            exports = module.exports = FLUtils;
        }
        exports.FLUtils = FLUtils;
    } else {
        root.FLUtils = FLUtils;
    }
}).call(this);