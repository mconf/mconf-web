package org.jivesoftware.xiff.privatedata
{
	import flash.events.EventDispatcher;
	
	import org.jivesoftware.xiff.core.XMPPConnection;
	import org.jivesoftware.xiff.data.ExtensionClassRegistry;
	import org.jivesoftware.xiff.data.IQ;
	import org.jivesoftware.xiff.data.privatedata.PrivateDataExtension;
	import org.jivesoftware.xiff.filter.CallbackPacketFilter;
	import org.jivesoftware.xiff.filter.IPacketFilter;
	import org.jivesoftware.xiff.util.Callback;

	public class PrivateDataManager extends EventDispatcher
	{
		private static var privateDataManagerConstructed:Boolean = privateDataManagerStaticConstructor();
		
		private static function privateDataManagerStaticConstructor():Boolean
		{
			ExtensionClassRegistry.register( PrivateDataExtension );
			return true;
		}
		
		private var _connection:XMPPConnection;
		
		public function PrivateDataManager(connection:XMPPConnection) {
			this._connection = connection;
		}
		
		public function getPrivateData(elementName:String, elementNamespace:String, callback:Callback):void {
			var packetFilter:IPacketFilter = new CallbackPacketFilter(callback);
			var privateDataGet:IQ = new IQ(null, IQ.GET_TYPE, null, "accept", packetFilter);
			privateDataGet.addExtension(new PrivateDataExtension(elementName, elementNamespace));
			
			this._connection.send(privateDataGet);
		}
		
		public function setPrivateData(elementName:String, elementNamespace:String, payload:IPrivatePayload):void {
			var privateDataSet:IQ = new IQ(null, IQ.SET_TYPE);
			privateDataSet.addExtension(new PrivateDataExtension(elementName, elementNamespace, payload));
			
			this._connection.send(privateDataSet);
		}
	}
}