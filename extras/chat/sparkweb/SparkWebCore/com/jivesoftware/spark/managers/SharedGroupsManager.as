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
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	
	import org.jivesoftware.xiff.core.XMPPConnection;
	import org.jivesoftware.xiff.data.IQ;
	import org.jivesoftware.xiff.data.XMPPStanza;
	import org.jivesoftware.xiff.data.im.RosterGroup;
	import org.jivesoftware.xiff.data.sharedgroups.SharedGroupsExtension;
	
	/**
	 * Retrieves from the server and manages locally, a list of shared groups.
	 */
	public class SharedGroupsManager
	{
		private var sharedGroups:ArrayCollection;
		private var connection:XMPPConnection;
		

		public function SharedGroupsManager(connection:XMPPConnection):void
		{
			sharedGroups = new ArrayCollection();
			this.connection = connection;
		}
		
		/**
		 * Sends an IQ to the server to retrieve the current list of shared
		 * groups.
		 */
		public function retrieveSharedGroups():void
		{
			var iq:IQ = new IQ(null, IQ.GET_TYPE, XMPPStanza.generateID("get_shared_groups_"), "_receivedSharedGroups", this);
			iq.addExtension(new SharedGroupsExtension());
			connection.send(iq);
		}
		
		public function _receivedSharedGroups(resultIQ:IQ):void
		{
			var iqNode:XMLNode = resultIQ.getNode();
			if (!iqNode)
				return;
			
			var sharedgroupNode:XMLNode = iqNode.firstChild;
			if (!sharedgroupNode)
				return;
			
			// Store the shared groups we received from the server
			for each(var groupNode:XMLNode in sharedgroupNode.childNodes)
			{
				if (groupNode.firstChild != null)
				{
					if (!sharedGroups.contains(groupNode.firstChild.nodeValue))
					{
						sharedGroups.addItem(groupNode.firstChild.nodeValue);
					}
				}
			}
			
			updateLocalGroups();
		}
		
		/**
		 * Updates the collection of our locally cached groups, setting their
		 * 'shared' flag to indicate if they are shared groups or not. 
		 */
		public function updateLocalGroups():void
		{
			for each(var sharedGroupName:String in sharedGroups)
			{
				var rosterGroup:RosterGroup = SparkManager.roster.getGroup(sharedGroupName);
				if (rosterGroup)
					rosterGroup.shared = true;
			}
		}
	}
}
