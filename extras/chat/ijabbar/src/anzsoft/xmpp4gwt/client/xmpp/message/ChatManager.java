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

import java.util.ArrayList;

import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.stanzas.Message;

public class ChatManager<T> {

	private ArrayList<ChatListener<T>> chatListeners = new ArrayList<ChatListener<T>>();

	private final ArrayList<Chat<T>> chats = new ArrayList<Chat<T>>();

	private final MessagePlugin messagePlugin;

	public ChatManager(MessagePlugin plugin) {
		this.messagePlugin = plugin;
	}

	public void addListener(ChatListener<T> listener) {
		this.chatListeners.add(listener);
	}

	private void fireChatCreated(Chat<T> chat) {
		for (ChatListener<T> l : this.chatListeners) {
			l.onStartNewChat(chat);
		}
	}

	private void fireReceivedMessage(Chat<T> chat, Message message,
			boolean firstMessage) {
		for (ChatListener<T> l : this.chatListeners) {
			l.onMessageReceived(chat, message, firstMessage);
		}
	}

	private void fireSyncSend(Chat<T> chat, Message message,
			boolean firstMessage) {
		for (ChatListener<T> l : this.chatListeners) {
			l.onSyncSend(chat, message, firstMessage);
		}
	}

	private void fireSyncRecv(Chat<T> chat, Message message,
			boolean firstMessage) {
		for (ChatListener<T> l : this.chatListeners) {
			l.onSyncRecv(chat, message, firstMessage);
		}
	}

	private void fireReceivedNotify(Notify notify) {
		for (ChatListener<T> l : this.chatListeners) {
			l.onNotifyReceive(notify);
		}
	}

	protected Chat<T> getChat(JID jid, String threadId) {
		Chat<T> chat = null;

		JID bareJID = jid.getBareJID();

		for (Chat<T> c : this.chats) {
			if (c.getJid().getBareJID().equals(bareJID)) {
				chat = c;
				break;
			}
			/*
			if (!c.getJid().getBareJID().equals(bareJID)) {
				continue;
			}
			if (threadId != null && c.getThreadId() != null && threadId.equals(c.getThreadId())) {
				chat = c;
				break;
			}
			if (jid.getResource() != null && c.getJid().getResource() != null && jid.getResource().equals(c.getJid().getResource())) {
				chat = c;
				break;
			}
			if (c.getJid().getResource() == null) {
				c.setJid(jid);
				chat = c;
				break;
			}
			 */

		}
		return chat;
	}

	void process(Message message) {
		if (message.getType().equals(Message.Type.notify)) {
			Notify notify = new Notify(message.getFirstChild("notify"));
			this.fireReceivedNotify(notify);
			return;
		}

		if (message.getType().equals(Message.Type.syncsend)) {
			final JID sendTo = message.getSyncWho();
			final String threadId = message.getThread();
			Chat<T> chat = getChat(sendTo, threadId);
			boolean firstMessage = false;
			if (chat == null) {
				chat = new Chat<T>(this, sendTo, threadId);
				this.chats.add(chat);
				fireChatCreated(chat);
				firstMessage = true;
			}
			fireSyncSend(chat, message, firstMessage);
			return;
		}

		if (message.getType().equals(Message.Type.syncrecv)) {
			final JID fromJid = message.getFrom();
			final String threadId = message.getThread();
			Chat<T> chat = getChat(fromJid, threadId);
			boolean firstMessage = false;
			if (chat == null) {
				chat = new Chat<T>(this, fromJid, threadId);
				this.chats.add(chat);
				fireChatCreated(chat);
				firstMessage = true;
			}
			fireSyncRecv(chat, message, firstMessage);
			return;
		}

		if (message.getType().equals(Message.Type.syncrecv)) {
			return;
		}

		if (!message.getType().equals(Message.Type.chat)
				&& !message.getType().equals(Message.Type.groupchat))
			return;
		final JID fromJid = message.getFrom();
		final String threadId = message.getThread();
		Chat<T> chat = getChat(fromJid, threadId);
		boolean firstMessage = false;
		if (chat == null) {
			chat = new Chat<T>(this, fromJid, threadId);
			this.chats.add(chat);
			fireChatCreated(chat);
			firstMessage = true;
		}
		fireReceivedMessage(chat, message, firstMessage);
	}

	void removeChat(Chat<T> chat) {
		this.chats.remove(chat);
	}

	public void removeListener(ChatListener<T> listener) {
		this.chatListeners.remove(listener);
	}

	void send(Chat<T> chat, String message, String userNickname) {
		this.messagePlugin.sendChatMessage(chat.getJid(), message, chat
				.getThreadId(), null, userNickname);
	}

	public Chat<T> startChat(JID jid) {
		return startChat(jid, null);
	}

	public Chat<T> startChat(JID jid, T userData) {
		final String threadId = Session.nextId();
		final Chat<T> chat = new Chat<T>(this, jid, threadId);
		chat.setUserData(userData);
		this.chats.add(chat);
		fireChatCreated(chat);
		return chat;
	}

}
