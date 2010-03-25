package org.jivesoftware.xiff.filter
{
	import org.jivesoftware.xiff.data.XMPPStanza;
	import org.jivesoftware.xiff.util.Callback;

	public class CallbackPacketFilter implements IPacketFilter
	{
		private var _filterFunction:Function;
		private var _callback:Callback;
		private var _processFunction:Function;
		
		/**
		 * 
		 */
		public function CallbackPacketFilter(callback:Callback, filterFunction:Function = null, processFunction:Function = null) {
			this._callback = callback;
			this._filterFunction = filterFunction;
			this._processFunction = processFunction;
		}
		
		public function accept(packet:XMPPStanza):void
		{
			if(_filterFunction == null || _filterFunction(packet)) {
				var processed:Object = packet;
				if(_processFunction != null) {
					processed = _processFunction(packet);
				}
				_callback.call(processed);
			}
		}
		
	}
}