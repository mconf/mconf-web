/*
 *This file is part of SparkWeb.
 *
 *SparkWeb is free software: you can redistribute it and/or modify
 *it under the terms of the GNU Lesser General Public License as published by
 *the Free Software Foundation, either version 3 of the License, or
 *(at your option) any later version.
 *
 *SparkWeb is distributed in the hope that it will be useful,
 *but WITHOUT ANY WARRANTY; without even the implied warranty of
 *MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *GNU Lesser General Public License for more details.
 *
 *You should have received a copy of the GNU Lesser General Public License
 *along with SparkWeb.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.jivesoftware.spark.managers
{
	import mx.collections.ArrayCollection;
	import mx.containers.Panel;
	
	import org.jivesoftware.xiff.core.Browser;
	import org.jivesoftware.xiff.core.EscapedJID;
	import org.jivesoftware.xiff.core.UnescapedJID;
	import org.jivesoftware.xiff.core.XMPPConnection;
	import org.jivesoftware.xiff.data.IQ;
	import org.jivesoftware.xiff.data.disco.InfoDiscoExtension;
	import org.jivesoftware.xiff.data.disco.ItemDiscoExtension;
	import org.jivesoftware.xiff.data.forms.FormExtension;
	import org.jivesoftware.xiff.data.forms.FormField;
	import org.jivesoftware.xiff.data.search.SearchExtension;
	import org.jivesoftware.xiff.events.SearchPrepEvent;
	import org.jivesoftware.xiff.filter.CallbackPacketFilter;
	import org.jivesoftware.xiff.filter.IPacketFilter;
	import org.jivesoftware.xiff.util.Callback;
	
	/**
	 * Manages the list of known search services.
	 */
	public class AbstractSearchManager
	{
		/**
		 * Broadcasts when preparations for searching are complete.
		 * 
		 * Will contain the attribute <code>server</code> which contains the JID of the
		 * search server whose services we've discovered.
		 */
		[Event("searchPrepComplete")]
		
		private static var searchManagerConstructed:Boolean = SearchManagerStaticConstructor();
		
		private static function SearchManagerStaticConstructor():Boolean
		{
			SearchExtension.enable();
			return true;
		}
		
		// Contains the list of services found on the server, storing the Name and JID
		// of each service found that provides a search service.
		[Bindable]
		public var services:ArrayCollection = new ArrayCollection();
		
		[Bindable]
		public var searchUnavailable:Boolean = false;
		[Bindable]
		public var searchLoading:Boolean = false;
		
		protected var _connection:XMPPConnection;
		protected var _server:String = null;
		protected var _service:UnescapedJID = null;
		protected var _populated:Boolean = false;
		protected var _nonefound:Boolean;
		protected var _fieldsMap:Object = {};
		protected var _dataFormFieldsMap:Object = {};
		public var _dataFormSearchInUse:Boolean = false;	// FIXME: revert to public before commit
		protected var _popup:Panel;
		protected var _pendingServices:ArrayCollection = new ArrayCollection();
		
		protected function get identityCategory():String
		{
			return "directory";
		}
		
		protected function get identityType():String
		{
			throw new Error("Implement me! get identityType() from AbstractSearchManager");
		}
		
		public static function get sharedInstance():RoomSearchManager
		{
			return null;
		}
		
		// Returns true if the search preparation was already complete.
		public function get searchReady():Boolean
		{
			return _populated;	
		}
		
		// Sets what server we are querying, as well as initializing some caches
		// and various settings.
		public function set server(newServer:String):void
		{
			_fieldsMap = {};
			_dataFormFieldsMap = {};
			_dataFormSearchInUse = false;
			_populated = false;
			_nonefound = true;
			searchUnavailable = false;
			searchLoading = true;
			services.removeAll();
			// Ug, I hate this, but it solves a problem for now.
			services.addItem({Name:Localizator.getText('label.loading.search'), JID:null});			
			_server = newServer;
			_service = null;
			_pendingServices.removeAll();
			_populateServices(true);
		}
		
		// Returns the server we are querying.  Initializes to the main server
		// we are connected to if not set yet.
		public function get server():String
		{
			if (!_server)
				server = _connection.server;
			
			return _server.toString();
		}
		
		// Sets what service we are querying.
		public function set service(service:UnescapedJID):void
		{
			_service = service;
		}
		
		// Sets what service we are currently set to query.
		public function get service():UnescapedJID
		{
			if (!_service && services.length > 0)
				_service = new UnescapedJID(services[0].JID);
			
			return _service;
		}
		
		// If we haven't already probed the server for services, find out what
		// services the server provides, checking specifically for search and also
		// what fields each service requires.  Force will force a new search to be performed.
		private function _populateServices(force:Boolean = false):void
		{
			if (force)
				_populated = false;
 
 			if (!_populated)
				new Browser(SparkManager.connectionManager.connection).getServiceItems(new EscapedJID(server), "_handlePopulateServices", this);
		}
		
		// Callback called to find out what services a server has.
		// Is considered the starting point of a new search, so we perform some resets
		// at first.
		public function _handlePopulateServices(iq:IQ):void
		{
			var extensions:Array = iq.getAllExtensionsByNS(ItemDiscoExtension.NS);
			if (extensions == null || extensions.length < 1) return;
			var itemExt:ItemDiscoExtension = extensions[0];
			for each(var item:Object in itemExt.items) {
				_pendingServices.addItem(item.jid);
				new Browser(SparkManager.connectionManager.connection).getServiceInfo(new EscapedJID(item.jid), "_handlePopulateServicesFromInfo", this);
			}
		}
		
		// Callback called after a service is discovered at a server to see if it
		// support search, specifically user directory search.
		public function _handlePopulateServicesFromInfo(iq:IQ):void
		{
			var extensions:Array = iq.getAllExtensionsByNS(InfoDiscoExtension.NS);
			if (!extensions || extensions.length < 1)
			{
				_checkPending(iq.from.unescaped);
				return;	
			}
			
			var infoExt:InfoDiscoExtension = extensions[0];
			for each (var feature:* in infoExt.features)
			{
				if (feature != SearchExtension.NS)
					continue;
				
				for each(var identity:* in infoExt.identities)
				{
					if (identity.category == identityCategory && identity.type == identityType) 
					{
						_retrieveFields(iq.from, new Callback(this, _handlePopulateFields, identity.name));
						return;
					}
				}
			} 
			// Not a search service, punt it from the list
			_checkPending(iq.from.unescaped);
		}
		
		// Callback called after a search service is detected to determine and cache
		// what fields it requires.
		public function _handlePopulateFields(name:String, iq:IQ):void
		{
			var extensions:Array = iq.getAllExtensionsByNS(SearchExtension.NS);
			if (!extensions || extensions.length == 0)
			{
				_checkPending(iq.from.unescaped);
				return;
			}
			var searchExt:SearchExtension = extensions[0];

			// Cache the Data Form fields, if available.
			_dataFormFieldsMap[iq.from] = extractDataFormFields(searchExt)
			if (_dataFormFieldsMap[iq.from])
				_dataFormSearchInUse = true;

			if (!dataFormsActive)
			{
				var fields:Array = searchExt.getRequiredFieldNames();
				// Hrm, no fields, we can't search this properly.
				if (fields.length == 0)
				{
					_checkPending(iq.from.unescaped);
					return;
				}
				_fieldsMap[iq.from] = fields;
			}

			if (_nonefound)
			{
				services.removeAll();
				_nonefound = false;
			}
			searchLoading = false;
			services.addItem({Name:name, JID:iq.from});
			_checkPending(iq.from.unescaped);
		}
		
		// Extracts Data Form search fields from the Search Extension and returns an
		// array of the field names.
		private function extractDataFormFields(searchExt:SearchExtension):Array
		{
			// Get form fields
			var dataFormExtensions:Array = searchExt.getAllExtensionsByNS(FormExtension.NS);
			if (!dataFormExtensions || dataFormExtensions.length == 0)
				return null;
			
			var dataFormExt:FormExtension = dataFormExtensions[0];
			var formFields:Array = dataFormExt.getAllFields();

			return formFields;
		}
		
		// Returns whether or not our search fields were provided via Data Forms.
		public function get dataFormsActive():Boolean
		{
			return _dataFormSearchInUse;
		}

		// Checks if there are any pending services.  If there aren't, we fire an
		// event to indicate that we're all done/populated.
		private function _checkPending(service:UnescapedJID):void
		{
			//trace("Checking pending after done with service: "+service);
			try
			{
				_pendingServices.removeItemAt(_pendingServices.getItemIndex(service.toString()));
			}
			catch (error:RangeError)
			{
				// Do nothing.
			}
			//trace("Now there are "+_pendingServices.length+" items left");
			if (_pendingServices.length == 0) 
			{
				searchLoading = false;
				_populated = true;
				if (services.length == 1 && services[0].JID == null)
				{
					services.removeAll();
					searchUnavailable = true;
				}						
				else
				{
					var ev:SearchPrepEvent = new SearchPrepEvent(SearchPrepEvent.SEARCH_PREP_COMPLETE, false, false);
					ev.server = _server;
					dispatchEvent(ev);
				}		
			}
		}
		
		// Retrieves the cached list of fields associated with a service JID.
		public function getFields(jid:UnescapedJID):Array
		{
			if (!jid || jid.toString().length == 0) 
				return null;
			
			return _fieldsMap[jid.toString()];
		}
		
		// Retrieves the cached list of data form fields associated with a service JID.
		public function getDataFormFields(jid:UnescapedJID):Array
		{
			if (!jid|| jid.toString().length == 0) 
				return null;
			
			return _dataFormFieldsMap[jid.toString()];
		}
		
		// Queries the search service for the required list of fields.
		// The JID of the service to query and a callback for the results
		// is required.
		private function _retrieveFields(jid:EscapedJID, callback:Callback):void
		{
			var packetFilter:IPacketFilter = new CallbackPacketFilter(callback);
			
			var iqSearch:IQ = new IQ(jid, IQ.GET_TYPE, null, "accept", packetFilter);
			iqSearch.addExtension(new SearchExtension());
			_connection.send(iqSearch);			
		}
		
		// Performs an actual search (jabber:iq:search) with the given query and
		// given list of fields to match on.  The jid is the JID of the service
		// that is being queried and a callback must be specified to receive the
		// search results.  The fields list is optional, and all fields will be 
		// used if null is set.
		public function performSearch(jid:UnescapedJID, query:String, callback:Callback, fields:Array = null):void
		{
			var packetFilter:IPacketFilter = new CallbackPacketFilter(callback);
			
			var iqSearch:IQ = new IQ(jid.escaped, IQ.SET_TYPE, null, "accept", packetFilter);
			var searchExt:SearchExtension = new SearchExtension();
			if (!fields)
				fields = getFields(jid);
			for each (var field:String in fields)
			{
				searchExt.setField(field, query);
			}
			iqSearch.addExtension(searchExt);
			_connection.send(iqSearch);
		}
		
		// Performs an actual search (jabber:iq:search) by submitting a data form
		// filled in with the given form fields to match on.
		// The jid is the JID of the service that is being queried and a callback must
		// be specified to receive the search results.
		public function performDataFormSearch(jid:UnescapedJID, formFields:Array, callback:Callback):void
		{
			if (!formFields)
				return;

			var packetFilter:IPacketFilter = new CallbackPacketFilter(callback);
			
			var iqSearch:IQ = new IQ(jid.escaped, IQ.SET_TYPE, null, "accept", packetFilter);
			var searchExt:SearchExtension = new SearchExtension();
			
			// Setup the Form Extension
			var fieldMap:Object = {FORM_TYPE: [SearchExtension.NS]};
			for each (var field:FormField in formFields)
			{
				fieldMap[field.name] = field.getAllValues();
			}
			var formExt:FormExtension = new FormExtension();
			formExt.type = FormExtension.SUBMIT_TYPE;
			formExt.setFields(fieldMap);
			var formTypeFormField:FormField = formExt.getFormField("FORM_TYPE");
			formTypeFormField.type = FormExtension.FIELD_TYPE_HIDDEN;
			formExt.serialize(searchExt.getNode());
			
			searchExt.addExtension(formExt);
			iqSearch.addExtension(searchExt);
			_connection.send(iqSearch);
		}
	}	
}
