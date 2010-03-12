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

import anzsoft.xmpp4gwt.client.events.MessageEvent;
import anzsoft.xmpp4gwt.client.stanzas.Message;
import anzsoft.xmpp4gwt.client.stanzas.Presence;

public class GroupChatEvent extends MessageEvent {

	private final GroupChat groupChat;

	private boolean kicked;

	private final Presence presence;

	public GroupChatEvent(Message message, GroupChat gc) {
		super(message);
		this.groupChat = gc;
		this.presence = null;
	}

	public GroupChatEvent(Presence presence, GroupChat gc) {
		super(null);
		this.groupChat = gc;
		this.presence = presence;
	}

	public GroupChat getGroupChat() {
		return groupChat;
	}

	public Presence getPresence() {
		return presence;
	}

	public boolean isKicked() {
		return kicked;
	}

	public void setKicked(boolean value) {
		this.kicked = value;
	}

	@Override
	public String toString() {
		return "room="
				+ groupChat.getRoomJid()
				+ ":: "
				+ (presence != null ? presence.toString()
						: (message != null ? message.toString() : "???"));
	}

}
