package com.kashirov.models 
{
	import flash.utils.describeType;
	import flash.utils.flash_proxy;
	import flash.utils.getDefinitionByName;
	import flash.utils.Proxy;
	import org.as3commons.collections.framework.core.SetIterator;
	import org.as3commons.collections.Map;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author 
	 */
	public class Unit extends Proxy implements IModel
	{
		
		public var signal:Signal;
		
		protected var modelFields:Array;
		protected var exclude:Array = ['prefix', 'signal'];
		protected var className:String;
		protected var _prefix:String;
		
		public function toString():String
		{
			return '[object ' + className.split('::')[1] + ']';
		}
		
		override flash_proxy function nextNameIndex(index:int):int 
		{
			if (index < modelFields.length) {
				return index + 1;
			} else {
				return 0;
			}
		}
		
		override flash_proxy function nextName (index:int):String
		{
			return modelFields[index - 1];
		}
		
		override flash_proxy function nextValue(index:int):*
		{
			var field:String = modelFields[index - 1];
			return this[field];
		}
		
		public function Unit() 
		{	
			signal = new Signal(Array);
			parseModelFields();
			prefix = '';
		}
		
		public function updateField(field:String, value:*):void
		{
			if (value != this[field]) {
				parseField(field, value);
				signal.dispatch([field]);
			}
		}
		
		public function dispose():void
		{
			signal.removeAll();
			
			for (var name:String in this) 
			{
				var field:* = this[name];
				
				if (field is Unit || field is Store || field is Hash) {
					field.dispose();
				}
			}
		}
		
		public function data():Object
		{
			var rt:Object = { };
			
			for (var name:String in this) 
			{
				var field:* = this[name];
				
				if (field is Unit || field is Store || field is Hash) {
					rt[name] = field.data();
				} else {
					rt[name] = this[name];
				}
			}
			
			return rt;
		}
		
		public function updateData(data:Object):void
		{
			var fields:Array = [];
			
			for (var name:String in data) 
			{
				var field:* = this[name];
				var itemData:Object = data[name];
				
				if (field is Unit) {
					parseBaseModel(field as Unit, itemData);
				} else if (field is Store) {
					(field as Store).updateData(itemData);
					
				} else if (field is Hash) {
					parseHash(field as Hash, itemData);
					
				} else if (field is List) {
					parseList(field as List, itemData as Array);
					
				} else {
					if (itemData != this[name]) {
						parseField(name, itemData)
						fields.push(name);
					}
				}
				
			}
			
			if (fields.length) {
				signal.dispatch(fields);
			}
		}
		
		private function parseModelFields():void 
		{
			modelFields = [];
			var structure:XML = describeType(this);
			className = structure.@name;
			for each (var childNode:XML in structure.variable) {
				var name:String = childNode.@name;
				if (exclude.indexOf(name) != -1) continue;
				if (childNode..metadata.(@name == 'Inject').length()) continue
				var type:String = childNode.@type;
				var clazz:Class = getDefinitionByName(type) as Class;
				if (!this[name]) this[name] = new clazz();
				modelFields.push(name);
				
				if (this[name] is Unit) {
					var unit:Unit = this[name] as Unit;
					unit.prefix = name;
				} else if (this[name] is Store) {
					var store:Store = this[name] as Store;
					store.prefix = name;
				}
			}
			modelFields = modelFields.sort();
		}
		
		private function parseField(name:String, data:Object):void
		{
			this[name] = data;
		}
		
		private function parseHash(hash:Hash, data:Object):void
		{
			hash.updateData(data);
		}
		
		private function parseList(list:List, data:Array):void
		{
			list.updateData(data);
		}		
		
		private function parseBaseModel(model:Unit, data:Object):void
		{
			model.updateData(data);
		}
		
		public function get prefix():String 
		{
			return _prefix;
		}
		
		public function set prefix(value:String):void 
		{
			_prefix = value;
		}
		
	}

}