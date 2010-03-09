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
package anzsoft.xmpp4gwt.client.xmpp.message;

import anzsoft.xmpp4gwt.client.JID;

public class Chat<T> {

	private JID jid;

	private final ChatManager<T> manager;

	private final String threadId;

	private T userData;

	private String userNickname = null;

	Chat(ChatManager<T> manager, JID jid, String threadId) {
		this.manager = manager;
		this.threadId = threadId;
		this.jid = jid;
	}

	public JID getJid() {
		return jid;
	}

	public String getThreadId() {
		return threadId;
	}

	public T getUserData() {
		return userData;
	}

	public String getUserNickname() {
		return userNickname;
	}

	public void remove() {
		this.manager.removeChat(this);
	}

	public void send(String message) {
		this.manager.send(this, message, userNickname);
	}

	void setJid(JID jid) {
		this.jid = jid;
	}

	public void setUserData(T userData) {
		this.userData = userData;
	}

	public void setUserNickname(String userNickname) {
		this.userNickname = userNickname;
	}

}
