package org.jivesoftware.xiff.util
{
	public class Callback
	{
		
		private var _scope:Object;
		private var _callback:Function;
		private var _args:Array;
		
		public function Callback(scope:Object, callback:Function, ... args) {
			this._scope = scope;
			this._callback = callback;
			this._args = args.slice();
		}
		
		public function call(... args):Object {
			var callbackArgs:Array = _args.slice();
			for each(var arg:Object in args) {
				callbackArgs.push(arg);
			}

			return _callback.apply(_scope, callbackArgs);
		}
	}
}