package org.jivesoftware.xiff.data{
	/*
	 * Copyright (C) 2003-2007 
	 * Nick Velloff <nick.velloff@gmail.com>
	 * Derrick Grigg <dgrigg@rogers.com>
	 * Sean Voisen <sean@voisen.org>
	 * Sean Treadway <seant@oncotype.dk>
	 *
	 * This library is free software; you can redistribute it and/or
	 * modify it under the terms of the GNU Lesser General Public
	 * License as published by the Free Software Foundation; either
	 * version 2.1 of the License, or (at your option) any later version.
	 * 
	 * This library is distributed in the hope that it will be useful,
	 * but WITHOUT ANY WARRANTY; without even the implied warranty of
	 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	 * Lesser General Public License for more details.
	 * 
	 * You should have received a copy of the GNU Lesser General Public
	 * License along with this library; if not, write to the Free Software
	 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
	 *
	 */
	
	/**
	 * All XMPP stanzas that will interact with the library should implement this interface.
	 *
	 * @author Sean Voisen
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @toc-path Interfaces
	 * @toc-sort 1
	 */
	import flash.xml.XMLNode;

	public interface ISerializable
	{
		/**
		 * Called when the library need to retrieve the state of the instance.  If the instance manages its own state, then the state should be copied into the XMLNode passed.  If the instance also implements INodeProxy, then the parent should be verified against the parent XMLNode passed to determine if the serialization is in the same namespace.
		 *
		 * @param parentNode (XMLNode) The container of the XML.
		 * @returns On success, return true.
		 */
		function serialize( parentNode:XMLNode ):Boolean;
	
		/**
		 * Called when data is retrieved from the XMLSocket, use this method to extract any state into internal state.
		 * @param node (XMLNode) The node that should be used as the data container.
		 * @returns On success, return true.
		 */
		function deserialize( node:XMLNode ):Boolean;
		
	}
}