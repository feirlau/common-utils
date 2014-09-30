/**
 * @author risker
 **/
package com.fl.utils
{
	import flash.utils.Dictionary;

	public class DictionaryUtil {
		
		public static function isEmpty(d:Dictionary):Boolean
		{
			for (var key:* in d)
			{
				return false;
			}
			return true;
		}
		
		public static function length(d:Dictionary):uint {
			var i:int = 0;
			for(var key:Object in d) {
				i ++;
			}
			return i;
		}
		
		public static function empty(d:Dictionary):void {
			for(var key:Object in d) {
				delete d[key];
			}
		}
		
		/**
		 *	Returns an Array of all keys within the specified dictionary.
		 *
		 * 	@param d The Dictionary instance whose keys will be returned.
		 * 	@return Array of keys contained within the Dictionary
		 */
		public static function getKeys(d:Dictionary):Array {
			var a:Array = [];
			for(var key:Object in d) {
				a.push(key);
			}
			return a;
		}
		
		/**
		 *	Returns an Array of all values within the specified dictionary.
		 *
		 * 	@param d The Dictionary instance whose values will be returned.
		 * 	@return Array of values contained within the Dictionary
		 */
		public static function getValues(d:Dictionary):Array {
			var a:Array = [];
			for each(var value:Object in d) {
				a.push(value);
			}
			return a;
		}
	}
}