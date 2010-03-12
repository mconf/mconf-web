/*
 * tigase-xmpp4gwt
 * Copyright (C) 2007 "Bartosz Małkowski" <bmalkow@tigase.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. Look for COPYING file in the top folder.
 * If not, see http://www.gnu.org/licenses/.
 *
 * $Rev$
 * Last modified by $Author$
 * $Date$
 */
package anzsoft.xmpp4gwt.client.xmpp.xeps.muc;

import java.util.HashMap;
import java.util.Map;

import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.events.Events;
import anzsoft.xmpp4gwt.client.events.EventsManager;
import anzsoft.xmpp4gwt.client.stanzas.Message;
import anzsoft.xmpp4gwt.client.stanzas.Presence;
import anzsoft.xmpp4gwt.client.stanzas.Message.Type;

public class GroupChatManager {

	private final EventsManager eventsManager;

	private final Map<JID, GroupChat> groupChats = new HashMap<JID, GroupChat>();

	public GroupChatManager(EventsManager eventsManager) {
		this.eventsManager = eventsManager;
	}

	public void add(GroupChat gc) {
		this.groupChats.put(gc.getRoomJid().getBareJID(), gc);
	}

	boolean process(Message message) {
		if (message.getType() == Type.groupchat && message.getFrom() != null) {
			final JID roomJid = message.getFrom().getBareJID();
			GroupChat gc = groupChats.get(roomJid);
			if (gc != null) {
				eventsManager.fireEvent(Events.groupChatMessageReceived,
						new GroupChatEvent(message, gc));
				return true;
			}
		}
		return false;
	}

	public boolean process(Presence presence) {
		if (presence.getFrom() != null) {
			final JID roomJid = presence.getFrom().getBareJID();
			GroupChat gc = groupChats.get(roomJid);
			if (gc != null) {
				gc.process(presence);
				eventsManager.fireEvent(Events.groupChatPresenceChange,
						new GroupChatEvent(presence, gc));
				return true;
			}
		}
		return false;
	}

	public void remove(GroupChat groupChat) {
		this.groupChats.remove(groupChat.getRoomJid().getBareJID());
	}

}
