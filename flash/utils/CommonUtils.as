package utils
{
    import com.hurlant.crypto.Crypto;
    import com.hurlant.crypto.symmetric.ICipher;
    import com.hurlant.crypto.symmetric.IVMode;
    import com.hurlant.util.Hex;
    
    import flash.utils.ByteArray;
    import mx.utils.Base64Encoder;
    import mx.utils.Base64Decoder;
    
    public class CommonUtils
    {
        private static var regArray:Array = ["&", "<",  ">", "\"", "\'"];
        private static var repArray:Array = ["&amp;", "&lt;",  "&gt;", "&quot;", "&apos;"];
        
        public function CommonUtils()
        {
        }
        public static function escapeHtml(value:String):String {
            var result:String = value;
            if(result) {
                var regExp:RegExp = new RegExp("["+regArray.join("")+"]", "gm");
                result = result.replace(regExp, function():String {
                    var tmpS:String = arguments[0];
                    for(var i:int=0; i<regArray.length; i++) {
                        if(tmpS==regArray[i]) {
                            tmpS = repArray[i];
                            break;
                        }
                    }
                    return tmpS;
                });
            }
            return result;
        }
        public static function unescapeHtml(value:String):String {
            var result:String = value;
            if(result) {
                var regExp:RegExp = new RegExp("("+repArray.join("|")+")", "gm");
                result = result.replace(regExp, function():String {
                    var tmpS:String = arguments[0];
                    for(var i:int=0; i<regpArray.length; i++) {
                        if(tmpS==repArray[i]) {
                            tmpS = regArray[i];
                            break;
                        }
                    }
                    return tmpS;
                });
            }
            return result;
        }
        
        private static const client_key:String = "flex_client_key@feirlau";
        private static const default_iv:String = "12345678";
        private static const MAX_KEY_SIZE:int = 56;
        
        private function getBlowfishKey(sourceKey:ByteArray):String {
            var targetKey:ByteArray = sourceKey;
            if(sourceKey && sourceKey.length>MAX_KEY_SIZE) {
                targetKey = sourceKey[0, MAX_KEY_SIZE];
            }
            return targetKey;
        }
        public function generateLicense(systemUUID:String, encryptKey:String):String {
            var licenseString:String = "";
            try {
                var tmpClientKey:ByteArray = getBlowfishKey(Hex.toArray(Hex.fromString(Hex.fromString(client_key))));
                var tmpSystemKey:ByteArray = getBlowfishKey(Hex.toArray(Hex.fromString(Hex.fromString(systemUUID))));
                var tmpEncryptKey:ByteArray = Hex.toArray(Hex.fromString(Hex.fromString(encryptKey)));
                var tmpCipher:ICipher = Crypto.getCipher("blowfish-cbc", tmpSystemKey);
                (tmpCipher as IVMode).IV = Hex.toArray(Hex.fromString(Hex.fromString(default_iv)));
                tmpCipher.encrypt(tmpEncryptKey);
                tmpCipher.dispose();
                tmpCipher = Crypto.getCipher("blowfish-cbc", tmpClientKey);
                (tmpCipher as IVMode).IV = Hex.toArray(Hex.fromString(Hex.fromString(default_iv)));
                tmpCipher.encrypt(tmpEncryptKey);
                tmpCipher.dispose();
                licenseString = Hex.fromArray(tmpEncryptKey);
            } catch(err:Error) {
                trace(err);
            }
            return licenseString;
        }
        
        public static function decryptLicense(system_id:String, product_license:String):ByteArray {
            var licenseKey:ByteArray = new ByteArray();
            if(!system_id || !product_license) {
                return licenseKey;
            }
            try {
                var tmpLicenseKey:ByteArray = Hex.toArray(product_license);
                var tmpClientKey:ByteArray = getBlowfishKey(Hex.toArray(Hex.fromString(Hex.fromString(client_key))));
                var tmpSystemKey:ByteArray = getBlowfishKey(Hex.toArray(Hex.fromString(Hex.fromString(system_id))));
                var tmpCipher:ICipher = Crypto.getCipher("blowfish-cbc", tmpClientKey);
                (tmpCipher as IVMode).IV = Hex.toArray(Hex.fromString(Hex.fromString(default_iv)));
                tmpCipher.decrypt(tmpLicenseKey);
                tmpCipher.dispose();
                tmpCipher = Crypto.getCipher("blowfish-cbc", tmpSystemKey);
                (tmpCipher as IVMode).IV = Hex.toArray(Hex.fromString(Hex.fromString(default_iv)));
                tmpCipher.decrypt(tmpLicenseKey);
                tmpCipher.dispose();
                licenseKey = tmpLicenseKey;
            } catch(err:Error) {
                trace(err);
            }
            return licenseKey;
        }
        
        public static function encryptBytes(inputBytes:ByteArray, licenseKey:ByteArray):ByteArray {
            var tmpOutput:ByteArray = new ByteArray();
            if(licenseKey==null) {
                return tmpOutput;
            }
            try {
                var tmpInputBytes:ByteArray = new ByteArray();
                inputBytes.position = 0;
                tmpInputBytes.writeBytes(inputBytes);
                var cipherStr:String = "blowfish-cbc";
                var tmpLicenseKey:ByteArray = new ByteArray();
                licenseKey.position = 0;
                tmpLicenseKey.writeBytes(licenseKey, 0, MAX_KEY_SIZE);
                var tmpCipher:ICipher = Crypto.getCipher(cipherStr, tmpLicenseKey);
                (tmpCipher as IVMode).IV = Hex.toArray(Hex.fromString(Hex.fromString(default_iv)));
                tmpInputBytes.compress();
                tmpCipher.encrypt(tmpInputBytes);
                tmpInputBytes.compress();
                tmpOutput.writeBytes(tmpInputBytes);
                tmpCipher.dispose();
            } catch(err:Error) {
                trace(err);
            }
            return tmpOutput;
        }
        
        public static function decryptBytes(inputBytes:ByteArray, licenseKey:ByteArray):ByteArray {
            var tmpOutput:ByteArray = new ByteArray();
            if(licenseKey==null) {
                return tmpOutput;
            }
            try {
                var cipherStr:String = "blowfish-cbc";
                var tmpLicenseKey:ByteArray = new ByteArray();
                licenseKey.position = 0;
                tmpLicenseKey.writeBytes(licenseKey, 0, MAX_KEY_SIZE);
                var tmpCipher:ICipher = Crypto.getCipher(cipherStr, tmpLicenseKey);
                (tmpCipher as IVMode).IV = Hex.toArray(Hex.fromString(Hex.fromString(default_iv)));
                var bs:uint = tmpCipher.getBlockSize();
                inputBytes.position = 0;
                inputBytes.readBytes(tmpOutput);
                tmpOutput.uncompress();
                tmpCipher.decrypt(tmpOutput);
                tmpCipher.dispose();
                tmpOutput.uncompress();
            } catch(err:Error) {
                trace(err);
            }
            return tmpOutput;
        }
        
        public static function decryptBytes2String(inputBytes:ByteArray, licenseKey:ByteArray):String {
            var tmpOutput:String = "";
            try {
                var tmpBytes:ByteArray = decryptBytes(inputBytes, licenseKey);
                tmpBytes.position = 0;
                tmpOutput = tmpBytes.readUTFBytes(tmpBytes.length);
            } catch(err:Error) {
                trace(err);
            }
            return tmpOutput;
        }
        
        public static function encryptString(inputString:String, licenseKey:ByteArray):String {
            var tmpOutput:String = "";
            if(licenseKey==null) {
                return tmpOutput;
            }
            try {
                var tmpInputBytes:ByteArray = new ByteArray();
                tmpInputBytes.writeUTFBytes(inputString);
                var tmpEncoder:Base64Encoder = new Base64Encoder();
                tmpEncoder.encodeBytes(encryptBytes(tmpInputBytes));
                tmpOutput = tmpEncoder.toString();
            } catch(err:Error) {
                trace(err);
            }
            return tmpOutput;
        }
        
        public static function decryptString(inputString:ByteArray, licenseKey:ByteArray):String {
            var tmpOutput:String = "";
            if(licenseKey==null) {
                return tmpOutput;
            }
            try {
                var tmpDecoder:Base64Decoder = new Base64Decoder();
                tmpDecoder.decode(inputString);
                tmpOutput = decryptBytes2String(tmpDecoder.toByteArray())
            } catch(err:Error) {
                trace(err);
            }
            return tmpOutput;
        }
    }
}