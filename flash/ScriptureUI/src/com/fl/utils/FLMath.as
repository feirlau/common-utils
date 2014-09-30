/**
 * @author risker
 * Dec 20, 2013
 **/
package com.fl.utils {

    public class FLMath {
        public static function sum(value:Array):Number {
            var tmpResult:Number = 0;
            for each(var tmpI:Number in value) {
                tmpResult += tmpI;
            }
            return tmpResult;
        }
        
        public static function average(value:Array):Number {
            var tmpResult:Number = 0;
            if(value && value.length > 0) {
                tmpResult = sum(value) / value.length;
            }
            return tmpResult;
        }
        
        public static function sumAll(value1:Array, value2:Array):Array {
            var tmpResult:Array = [];
            var n:Number = 0;
            for(var i:int = 0; i < value1.length; i++) {
                n = value1[i] == null ? 0 : value1[i];
                n += value2[i] == null ? 0 : value2[i];
                tmpResult.push(n);
            }
            return tmpResult;
        }
        
        public static function subAll(value1:Array, value2:Array):Array {
            var tmpResult:Array = [];
            var n:Number = 0;
            for(var i:int = 0; i < value1.length; i++) {
                n = value1[i] == null ? 0 : value1[i];
                n -= value2[i] == null ? 0 : value2[i];
                tmpResult.push(n);
            }
            return tmpResult;
        }
        
        public static function num2Nums(v:uint):Array{
            var nums:Array = [];
            do{
                nums.unshift(v%10);
                v = uint(v*0.1);
            }while(v);
            return nums;
        }
        
        public static function getBit1Nums(value:Array):uint {
            var n:uint = 0;
            for each(var m:uint in value) {
                while(m > 0) {
                    if(m & 0x1) n++;
                    m >>>= 1; 
                }
            }
            return n;
        }
    }
}
