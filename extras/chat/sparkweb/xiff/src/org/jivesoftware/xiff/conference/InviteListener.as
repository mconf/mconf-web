/*
 * Copyright (C) 2003-20077
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
	 
package org.jivesoftware.xiff.conference
{	
	import flash.events.EventDispatcher;
	
	import org.jivesoftware.xiff.core.XMPPConnection;
	import org.jivesoftware.xiff.data.Message;
	import org.jivesoftware.xiff.data.muc.MUCUserExtension;
	import org.jivesoftware.xiff.events.InviteEvent;
	import org.jivesoftware.xiff.events.MessageEvent;
	
	/**
	 * Dispatched when an invitations has been received.
	 * 
	 * @eventType org.jivesoftware.xiff.InviteEvent.INVITED
	 * @see org.jivesoftware.xiff.conference.Room
	 * @see org.jivesoftware.xiff.conference.Room.#invite
	 */
	[Event( name="invited", type="org.jivesoftware.xiff.events.InviteEvent" )]
	
	/**
	 * Manages the dispatching of events during invitations.  Add event
	 * listeners to an instance of this class to monitor invite and decline
	 * events.
	 *
	 * <p>You only need a single instance of this class to listen for all invite
	 * or decline events.</p>
	 *
	 * @param connection An XMPPConnection instance that is providing the primary server 
	 * connection.
	 */
	public class InviteListener extends EventDispatcher
	{
		private var myConnection:XMPPConnection;
		
		public function InviteListener( aConnection:XMPPConnection=null )
		{
			if (aConnection != null)
				setConnection( aConnection );	
		}
		
		/**
		 * Sets a reference to the XMPPConnection being used for incoming/outgoing XMPP data.
		 *
		 * @param connection The XMPPConnection instance to use.
		 * @see org.jivesoftware.xiff.core.XMPPConnection
		 */
		public function setConnection( connection:XMPPConnection ):void
		{
			if (myConnection != null){
				myConnection.removeEventListener(MessageEvent.MESSAGE, handleEvent);
			}
			myConnection = connection;
			myConnection.addEventListener(MessageEvent.MESSAGE, handleEvent);
		}
	
		/**
		 * Gets a reference to the XMPPConnection being used for incoming/outgoing XMPP data.
		 *
		 * @returns The XMPPConnection used
		 * @see org.jivesoftware.xiff.core.XMPPConnection
		 */
		public function getConnection():XMPPConnection
		{
			return myConnection;
		}
		 
		private function handleEvent( eventObj:Object ):void
		{
			switch( eventObj.type )
			{
				case MessageEvent.MESSAGE:
				
					try
					{
						var msg:Message = eventObj.data as Message;
						var exts:Array = msg.getAllExtensionsByNS(MUCUserExtension.NS);
						if(!exts || exts.length < 0) {
							return;
						}
						var muc:MUCUserExtension =  exts[0];
	                    if (muc.type == MUCUserExtension.INVITE_TYPE) {
	                        var room:Room = new Room(myConnection);
	                        room.roomJID = msg.from.unescaped;
	                        room.password = muc.password;
							var e:InviteEvent = new InviteEvent();
							e.from = muc.from.unescaped;
							e.reason = muc.reason;
							e.room = room;
							e.data = msg;
							dispatchEvent(e);
	                    }
    				 }
    				 catch (e:Error)
    				 {
    				 	trace(e.getStackTrace());
    				 }
                    
					break;
			}
		}
	}
}