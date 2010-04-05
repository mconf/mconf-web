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
	 
package org.jivesoftware.xiff.data
{
	
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.XMLStanza;
	import flash.xml.XMLNode;
	
	/**
	 * This is a base class for all data extensions.
	 * @param parent The parent node that this extension should be appended to
	 */
	public class Extension extends XMLStanza
	{
		public function Extension(parent:XMLNode=null)
		{
			super();
	
			getNode().nodeName = IExtension(this).getElementName();
			getNode().attributes.xmlns = IExtension(this).getNS();
	
			if (exists(parent)) {
				parent.appendChild(getNode());
			}
		}
	
		/**
		 * Removes the extension from its parent.
		 *
		 * @availability Flash Player 7
		 */
		public function remove():void
		{
			getNode().removeNode();
		}
		
		/**
		 * Converts the extension stanza XML to a string.
		 *
		 * @availability Flash Player 7
		 * @return The extension XML in string form
		 */
		public function toString():String
		{
			return getNode().toString();
		}
	}
}