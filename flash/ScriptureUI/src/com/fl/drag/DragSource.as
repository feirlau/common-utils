package com.fl.drag {
	public class DragSource {
		private var dataHolder:Object = {};
		private var formatHandlers:Object = {};
		/**
		 * 存放 formats 属性.
		 */
		private var _formats:Array /* of String */ = [];
	
		/**
		 * 包含拖动数据的格式，以字符串 Array 的形式表示。使用 addData() 或 addHandler() 方法设置此属性。默认值取决于添加到 DragSource 对象的数据。
		 */
		public function get formats():Array /* of String */
		{
			return _formats;
		}
		/**
		 *  向拖动源添加数据和相应的格式 String。此方法不返回值。
		 * 
		 *  @param data 用于指定拖动数据的对象。这可以是任何对象，如，String、DataProvider，等等。
		 *  @param format 字符串，用于指定一个标签来描述此数据格式。
		 */
		public function addData(data:Object, format:String):void
		{
			_formats.push(format);
			
			dataHolder[format] = data;
		}
		
		/**
		 *  添加一个处理函数，当请求指定格式的数据时将调用此处理函数。当拖动大量数据时，此函数非常有用。仅当请求数据时才调用该处理函数。此方法不返回值。
		 *
		 *  @param handler 一个函数，用于指定请求数据时需要调用的处理函数。此函数必须返回指定格式的数据。
		 *  @param format 用于指定此数据的格式的字符串。
		 */
		public function addHandler(handler:Function,
								   format:String):void
		{
			_formats.push(format);
	
			formatHandlers[format] = handler;
		}
		
		/**
		 * 检索指定格式的数据。如果此数据是使用 addData() 方法添加的，则可以直接返回此数据。如果此数据是使用 addHandler() 方法添加的，则需调用处理程序函数来返回此数据。
		 * 
		 *  @param format 字符串，用于指定一个标签来描述要返回的数据的格式。如果要用 addData() 方法创建自定义放置目标，则此字符串可以是自定义值。
		 *  <p>基于 List 的控件对于 format 参数有预定义的值。如果启动拖动操作的控件是 Tree，则格式为 "treeItems"，且项目实现 ITreeDataProvider 接口。
		 *  对于本身即支持拖放的所有其他基于 List 的控件，格式为 "items"，且项目实现 IDataProvider 接口。</p>
		 *
		 *  @return 包含所请求格式的数据的 Object。如果拖动多个项目，则返回值是一个 Array。对于基于 List 的控件，返回值始终为 Array，即使其中只包含一个项目也是如此。
		 */
		public function dataForFormat(format:String):Object
		{
			var data:Object = dataHolder[format];
			if (data)
				return data;
			
			if (formatHandlers[format])
				return formatHandlers[format]();
			
			return null;
		}
		
		/**
		 * 如果数据源中包含所请求的格式，则返回 true；否则，返回 false。
		 *
		 *  @param format 字符串，用于指定一个标签来描述此数据的格式。
		 *  @return 如果数据源中包含所请求的格式，则返回 true。
		 */
		public function hasFormat(format:String):Boolean
		{
			var n:int = _formats.length;
			for (var i:int = 0; i < n; i++)
			{
				if (_formats[i] == format)
					return true;
			}
			
			return false;
		}
	}
}
