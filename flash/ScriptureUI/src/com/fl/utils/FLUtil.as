/**
 * @author risker
 **/
package com.fl.utils
{
	
	import com.adobe.utils.Base64Decoder;
	import com.adobe.utils.Base64Encoder;
	import com.adobe.utils.ObjectUtil;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.system.IME;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	
	public class FLUtil
	{
		/**
		 * invoke the funcs with the parameter.
		 * @param funcs, a Function instance or an array of functions.
		 * @param param, the paramter to be passed to the funcs.
         * @param toArray, should or not convert the param to array
		 **/
		public static function calls(funcs:*, param:Object, toArray:Boolean = true):void {
			if(funcs == null) {
				return;
			}
			if(funcs is Function) {
				var item:Function = funcs as Function;
				item.apply(null, !toArray && param is Array ? param : [param]);                
			} else if(funcs is Array) {
				for each(var func:* in funcs) {
					if(func != null) {
						calls(func, param, toArray);
					}
				}
			} else {
				trace("Your callback is not Function or Array of Function");
			}
		}
		
		/**
		 * invoke the funcs with the parameters.
		 * @param funcs, a Function instance or an array of functions.
		 * @param args, the paramters to be passed to the funcs.
		 **/
		public static function apply(funcs:*, ...args):void {
			if(funcs == null) {
				return;
			}
			if(funcs is Function) {
				var item:Function = funcs as Function;
				item.apply(null, args);                
			} else if(funcs is Array) {
				for each(var func:* in funcs) {
					if(func != null) {
                        calls(func, args, false);
					}
				}
			} else {
				trace("Your callback is not Function or Array of Function");
			}
		}
		
        public static function nullFunc(...args):void {
            LogUtil.addLog(FLUtil, ["nullFunc", args], LogUtil.DEBUG);
        }
        
		/**
		 * Check if the soruce string matched the target string/regexp.
		 * @param source, the source string to match.
		 * @param target, the target string or regexp to match.
		 * @return boolean, true if they are matched fully; elase false.
		 **/
		public static function stringFullMatch(source:String, target:String):Boolean {
			var tmpResult:Boolean = false;
			if(source == target) {
				tmpResult = true;
			} else if(source==null || target==null) {
				tmpResult = false;
			} else {
				var tmpReg:RegExp = new RegExp('^'+target+'$', 'm');
				tmpResult = (null!=source.match(tmpReg));
			}
			return tmpResult;
		}
		
		public static function getAppRoot(url:String = ""):String {
			var tmpI:int = url.lastIndexOf(".swf");
			if(tmpI != -1) {
				tmpI = url.lastIndexOf("/", tmpI);
			}
			if(tmpI != -1) {
				url = url.substring(0, tmpI);
			}
			return url;
		}
		
		/**
		 * Create a formated url with three parts:
		 * @param url, the original url string
		 * @param parameters, the parameters to be append to the url
		 * @param fragments, the fragments to be append to the url
		 * @return the formated url.
		 **/
		public static function getURL(url:String, parameters:Object = null, fragments:Object = null, autoPrefix:Boolean = true, appRoot:String = null):String {
			var tmpA:Array = parseURL(url);
			var addressStr:String = tmpA[0];
			var parameterStr:String = tmpA[1];
			var fragementStr:String = tmpA[2];
			for(var key1:Object in parameters) {
				if(parameterStr) parameterStr += "&";
				parameterStr += encodeURIComponent(key1.toString());
				if(parameters[key1] != null) parameterStr += "=" + encodeURIComponent(parameters[key1].toString());
			}
			for(var key2:Object in fragments) {
				if(fragementStr) fragementStr += "&";
				fragementStr += encodeURIComponent(key1.toString());
				if(fragments[key1] != null) fragementStr += "=" + encodeURIComponent(fragments[key1].toString());
			}
			if(autoPrefix && addressStr.indexOf("file://") != 0 && addressStr.indexOf("http://") != 0 && addressStr.indexOf("https://") != 0) {
				if(addressStr.indexOf("/") != 0) {
					addressStr = "/" + addressStr;
				}
                if(appRoot == null) appRoot = getAppRoot();
				addressStr = appRoot + addressStr;
			}
			return addressStr + (parameterStr ? "?" + parameterStr : "") + (fragementStr ? "#" + fragementStr : "");
		}
		
		/**
		 * http://www.a.b/c?e=f&g#h=i&j
		 * Parse the url to three parts: address part, parameter part, fragement part.
		 * @return a three elements array, ["http://www.a.b/c", "e=f&g", "h=i&j"]
		 **/
		public static function parseURL(url:String):Array {
			var addressStr:String = "";
			var parameterStr:String = "";
			var fragementStr:String = "";
			var i:int = url.indexOf("?");
			var j:int = url.indexOf("#");
			if(i == -1 && j == -1) {
				addressStr = url;
			} else if(i == -1) {
				addressStr = url.substring(0, j);
				fragementStr = url.substr(j + 1);
			} else if(j == -1) {
				addressStr = url.substring(0, i);
				parameterStr = url.substr(i + 1);
			} else if(i < j) {
				addressStr = url.substring(0, i);
				parameterStr = url.substring(i + 1, j);
				fragementStr = url.substr(j + 1);
			} else if(i > j) {
				addressStr = url.substring(0, j);
				fragementStr = url.substr(j + 1);
			}
			return [addressStr, parameterStr, fragementStr];
		}
		
		public static function getClassName(value:*, sep:String = "::"):String {
			var tmpS:String = "";
			if(value) {
				tmpS = getQualifiedClassName(value);
				if(sep) {
					var tmpI:int = tmpS.lastIndexOf(sep);
					if(tmpI >= 0) {
						tmpS = tmpS.substr(tmpI + sep.length);
					}
				}
			}
			return tmpS;
		}
        
        public static function getClassHierarchy(base:*, sup:*, sep:String = "::"):Array {
            var tmpA:Array = [];
            if(!base) return tmpA;
            
            var baseS:String = getQualifiedClassName(base);
            var supS:String = sup ? getQualifiedClassName(sup) : "";
            while(baseS) {
                tmpA.push(getClassName(base, sep));
                
                if(baseS == supS) break;
                
                try {
                    baseS = getQualifiedSuperclassName(base);
                    base = getDefinitionByName(baseS);
                } catch(err:Error) {
                    baseS = null;
                    LogUtil.addLog(FLUtil, ["[getClassHierarchy]", err.getStackTrace()], LogUtil.ERROR);
                }
            }
            
            return tmpA;
        }
        
        public static function getObjectsUnderPoint(obj:DisplayObject, pt:Point, arr:Array = null):Array {
            arr ||= [];
            if(!obj.visible) return arr;
            
            if(obj.hitTestPoint(pt.x, pt.y, true)) {
                if (obj is InteractiveObject && InteractiveObject(obj).mouseEnabled)
                    arr.push(obj);
                if (obj is DisplayObjectContainer) {
                    var doc:DisplayObjectContainer = obj as DisplayObjectContainer;
                    if (doc.mouseChildren) {
                        var n:int = doc.numChildren;
                        for(var i:int = 0; i < n; i++) {
                            try {
                                var child:DisplayObject = doc.getChildAt(i);
                                getObjectsUnderPoint(child, pt, arr);
                            } catch(e:Error) {
                                //
                            }
                        }
                    }
                }
            }
            
            return arr;
        }
        
        public static function copy(s:Object, d:Object, deep:Boolean = false, excludes:Array = null):void {
            if(s == null || d == null) return;
            var tmpA:Array = ObjectUtil.getClassInfo(s, excludes, {includeReadOnly: false, uris: null, includeTransient: false}).properties;
            for each(var tmpP:* in tmpA) {
                try {
                    if(deep) {
                        d[tmpP] = ObjectUtil.copy(s[tmpP]);
                    } else {
                        d[tmpP] = s[tmpP];
                    }
                } catch(err:Error) {}
            }
        }
        
        private static var playerVersion:Object;
        public static function getPlayerVersion():Object {
            if(playerVersion == null) {
                playerVersion = {};
                var versionArr:Array = Capabilities.version.split(",");
                var osPlusVersion:Array = versionArr[0].split(" ");
                playerVersion["os"] = osPlusVersion[0];
                playerVersion["major"] = osPlusVersion[1];
                playerVersion["minor"] = versionArr[1];
                playerVersion["build"] = versionArr[2];
            }
            return playerVersion;
        }
        
        private static var base64Encoder:Base64Encoder = new Base64Encoder();
        public static function number2base64(value:Number, ba:Class = null):String {
            ba ||= ByteArray;
            var bytes:ByteArray = new ba();
            bytes.endian = Endian.LITTLE_ENDIAN;
            bytes.writeDouble(value);
            bytes.position = 0;
            base64Encoder.reset();
            base64Encoder.encodeBytes(bytes, 0, bytes.length);
            return base64Encoder.flush();
        }
        private static var base64Decoder:Base64Decoder = new Base64Decoder();
        public static function base642number(value:String, ba:Class = null):Number {
            base64Decoder.reset();
            base64Decoder.decode(value);
            var bytes:ByteArray = base64Decoder.flush();
            bytes.endian = Endian.LITTLE_ENDIAN;
            bytes.position = 0;
            
            ba ||= ByteArray;
            var cbyteArray:ByteArray = new ba();
            cbyteArray.endian = Endian.LITTLE_ENDIAN;
            cbyteArray.writeBytes(bytes,0,bytes.length);
            cbyteArray.position = 0;
            return cbyteArray.readDouble();
        }
        
        public static function base64Encode(value:String):String {
            var tmpResult:String = "";
            try {
                base64Encoder.reset();
                base64Encoder.encodeUTFBytes(value);
                tmpResult = base64Encoder.flush();
            } catch(err:Error) {
                LogUtil.addLog(FLUtil, err.getStackTrace(), LogUtil.ERROR);
            }
            return tmpResult;
        }
        public static function base64Decode(value:String):String {
            var tmpResult:String = "";
            try {
                base64Decoder.reset();
                base64Decoder.decode(value);
                var bytes:ByteArray = base64Decoder.flush();
                tmpResult = bytes.readUTFBytes(bytes.length);
            } catch(err:Error) {
                LogUtil.addLog(FLUtil, err.getStackTrace(), LogUtil.ERROR);
            }
            return tmpResult;
        }
        
        public static function decodeHash(hash:String, size:uint = 20):ByteArray {
            var tmpBytes:ByteArray = new ByteArray();
            if(hash) {
                hash = decodeURIComponent(hash);
                base64Decoder.reset();
                base64Decoder.decode(hash);
                tmpBytes = base64Decoder.flush();
            }
            var i:uint = tmpBytes.length;
            tmpBytes.position = i;
            for( ; i < size; i++) {
                tmpBytes.writeByte(0);
            }
            return tmpBytes;
        }
        public static function decodeHex(hex:String, size:uint = 20):ByteArray {
            var tmpBytes:ByteArray = new ByteArray();
            var i:uint;
            if(hex) {
                var n:int = 0;
                for(i = 0; i < hex.length; i += 2) {
                    n = parseInt(hex.charAt(i), 16) << 4;
                    n += parseInt(hex.charAt(i+1), 16);
                    tmpBytes.writeByte(n);
                }
            }
            i = tmpBytes.length;
            tmpBytes.position = i;
            for( ; i < size; i++) {
                tmpBytes.writeByte(0);
            }
            return tmpBytes;
        }
        
        public static function setIME(value:Boolean):void {
            try{
                IME.enabled = value;
            }catch(error:Error){}
        }
        
        public static function getWordWidth(value:String):uint {
            var tmpResult:int = 0;
            for(var i:int = 0; i < value.length; i++) {
                var tmpC:int = value.charCodeAt(i);
                if(tmpC >= 0 && tmpC <= 126) {
                    tmpResult += 1;
                } else {
                    tmpResult += 2;
                }
            }
            return tmpResult;
        }
        
        private static const regArray:Array = ["&", "<",  ">", "\"", "\'"];
        private static const repArray:Array = ["&amp;", "&lt;",  "&gt;", "&quot;", "&apos;"];
        public static function escapeHtml(value:String):String {
            var result:String = escapeStr(value, regArray, repArray);
            return result;
        }
        public static function unescapeHtml(value:String):String {
            var result:String = unescapeStr(value, regArray, repArray);
            return result;
        }
        /**
         * escape the special chars in a string to other chars
         **/
        public static function escapeStr(value:String, regA:Array, repA:Array):String {
            var result:String = value;
            if(result) {
                var regExp:RegExp = new RegExp("["+regA.join("")+"]", "gm");
                result = result.replace(regExp, function():String {
                    var tmpS:String = arguments[0];
                    for(var i:int=0; i<regA.length; i++) {
                        if(tmpS==regA[i]) {
                            tmpS = repA[i];
                            break;
                        }
                    }
                    return tmpS;
                });
            }
            return result;
        }
        public static function unescapeStr(value:String, regA:Array, repA:Array):String {
            var result:String = value;
            if(result) {
                var regExp:RegExp = new RegExp("("+repA.join("|")+")", "gm");
                result = result.replace(regExp, function():String {
                    var tmpS:String = arguments[0];
                    for(var i:int=0; i<repA.length; i++) {
                        if(tmpS==repA[i]) {
                            tmpS = regA[i];
                            break;
                        }
                    }
                    return tmpS;
                });
            }
            return result;
        }
	}
}