package com.kashirov.models 
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author 
	 */
	public class Store
	{
		
		protected var _models:Object;
		protected var _assign:Class;
		
		public var addSignal:Signal;
		public var removeSignal:Signal;
		
		public function Store() 
		{
			_models = { };
			
			addSignal = new Signal(Unit);
			removeSignal = new Signal(Unit);
			
			var structure:XML = describeType(this);
			var assignType:String = structure.variable.(@name == 'assign').@type;
			_assign = getDefinitionByName(assignType) as Class;
		}
		
		public function data():Object
		{
			var rt:Object = { };
			
			for (var name:String in _models) 
			{
				var item:Unit = getItem(name);
				rt[name] = item.data();
			}
			
			return rt;
		}
		
		public function dispose():void
		{
			addSignal.removeAll();
			removeSignal.removeAll();
			
			for (var name:String in _models) 
			{
				var item:Unit = getItem(name);
				item.dispose();
			}
		}
		
		public function getItem(key:String):Unit
		{
			return _models[key];
		}
		
		public function addItem(key:String):Unit
		{
			var item:Unit = new _assign() as Unit;
			_models[key] = item;
			item.prefix = key;
			addSignal.dispatch(item);
			return item;
		}
		
		public function removeItem(key:String):Unit
		{
			var item:Unit = _models[key] as Unit;
			delete _models[key];
			removeSignal.dispatch(item);
			item.dispose();
			return item;
		}
		
	}

}