package org.jivesoftware.xiff.data.muc{
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
	
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.ISerializable;
	
	import org.jivesoftware.xiff.data.muc.MUCBaseExtension;
	import flash.xml.XMLNode;
	
	/**
	 * Implements the administration command data model in <a href="http://www.jabber.org/jeps/jep-0045.html">JEP-0045<a> for multi-user chat.
	 *
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @param parent (Optional) The containing XMLNode for this extension
	 * @availability Flash Player 7
	 * @toc-path Extensions/Conferencing
	 * @toc-sort 1/2
	 */
	public class MUCAdminExtension extends MUCBaseExtension implements IExtension
	{
		// Static class variables to be overridden in subclasses;
		public static var NS:String = "http://jabber.org/protocol/muc#admin";
		public static var ELEMENT:String = "query";
	
		private var myItems:Array;
	
		public function MUCAdminExtension( parent:XMLNode=null )
		{
			super(parent);
		}
	
		public function getNS():String
		{
			return MUCAdminExtension.NS;
		}
	
		public function getElementName():String
		{
			return MUCAdminExtension.ELEMENT;
		}
	}
}