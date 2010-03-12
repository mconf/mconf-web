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

import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.Plugin;
import anzsoft.xmpp4gwt.client.PluginState;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.citeria.Criteria;
import anzsoft.xmpp4gwt.client.citeria.ElementCriteria;
import anzsoft.xmpp4gwt.client.citeria.Or;
import anzsoft.xmpp4gwt.client.events.Event;
import anzsoft.xmpp4gwt.client.events.Events;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.stanzas.Message;
import anzsoft.xmpp4gwt.client.stanzas.Presence;

public class MultiUserChatPlugin implements Plugin {

	public final Criteria CRIT = new Or(ElementCriteria.name("presence"),
			ElementCriteria.name("message", new String[] { "type" },
					new String[] { "groupchat" }));

	private final GroupChatManager groupChatManager;

	private final Session session;

	public MultiUserChatPlugin(Session session) {
		groupChatManager = new GroupChatManager(session.getEventsManager());
		this.session = session;
	}

	public GroupChat createGroupChat(final JID roomJid, final String nickname,
			String password) {
		GroupChat gc = new GroupChat(roomJid.getBareJID(), groupChatManager,
				this);
		gc.setNickname(nickname);
		gc.setPassword(password);
		groupChatManager.add(gc);
		session.getEventsManager().fireEvent(Events.groupChatCreated,
				new GroupChatEvent((Presence) null, gc));
		return gc;
	}

	void fireEvent(Enum<?> eventType, Event event) {
		session.getEventsManager().fireEvent(eventType, event);
	}

	public Criteria getCriteria() {
		return CRIT;
	}

	public PluginState getStatus() {
		return null;
	}

	public boolean process(Packet stanza) {
		if ("message".equals(stanza.getName())) {
			Message message = new Message(stanza);
			boolean processed = groupChatManager.process(message);
			return processed;
		} else if ("presence".equals(stanza.getName())) {
			Presence presence = new Presence(stanza);
			boolean processed = groupChatManager.process(presence);
			return processed;
		}
		return false;
	}

	public void reset() {
	}

	void send(Message message) {
		session.send(message);
	}

	void send(Presence presence) {
		session.send(presence);
	}

}
