/*
 * tigase-xmpp4gwt
 * Copyright (C) 2007-2008 "Bartosz Małkowski" <bmalkow@tigase.org>
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
package anzsoft.xmpp4gwt.client.stanzas;

import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.packet.Packet;

/**
 * @author bmalkow
 * 
 */
public class Presence extends AbstractStanza {

	public static enum Show {
		away, chat, dnd, notSpecified, unknown, xa
	}

	public enum Type {
		available, error, probe, subscribe, subscribed, unavailable, unsubscribe, unsubscribed
	}

	public Presence(Packet packet) {
		super(packet);
	}

	/**
	 * @param unavailable
	 */
	public Presence(Type unavailable) {
		this(unavailable, null, null);
	}

	public Presence(Type type, JID from, JID to) {
		super("presence");
		setType(type);
		setFrom(from);
		setTo(to);
	}

	public Presence(Type type, JID from, JID to, Show show, String status,
			Integer priority) {
		super("presence");
		setType(type);
		setFrom(from);
		setTo(to);
		setShow(show);
		setStatus(status);
		setPriority(priority);
	}

	public String getExtNick() {
		Packet nick = getFirstChild("nick");
		if (nick != null) {
			return nick.getCData();
		}
		return null;
	}

	public int getPriority() {
		Packet child = getFirstChild("priority");
		final String priority = child == null ? null : child.getCData();
		if (priority != null) {
			try {
				return Integer.parseInt(priority);
			} catch (final NumberFormatException e) {
				return 0;
			}
		}
		return 0;
	}

	public Show getShow() {
		Packet child = getFirstChild("show");
		final String value = child != null ? child.getCData() : null;
		try {
			return value != null ? Show.valueOf(value) : Show.notSpecified;
		} catch (final IllegalArgumentException e) {
			return Show.unknown;
		}
	}

	public String getStatus() {
		Packet status = getFirstChild("status");
		return status == null ? null : status.getCData();
	}

	public Type getType() {
		final String type = getAtribute("type");
		try {
			return type != null ? Type.valueOf(type) : Type.available;
		} catch (final IllegalArgumentException e) {
			return Type.error;
		}
	}

	/**
	 * @param extNick
	 */
	public void setExtNick(String extNick) {
		Packet nick = getFirstChild("nick");
		if (nick == null) {
			nick = addChild("nick", "http://jabber.org/protocol/nick");
		} else if (extNick == null && nick != null) {
			removeChild(nick);
		}
		if (nick != null && extNick != null) {
			nick.setCData(extNick);
		}
	}

	public void setPriority(final Integer value) {
		String v = value == null ? null : Integer.toString(value >= 0 ? value
				: 0);
		setChildrenValue("priority", v);
	}

	public void setShow(Show value) {
		String v = (value != null && (value != Show.notSpecified && value != Show.unknown)) ? value
				.toString()
				: null;
		setChildrenValue("show", v);
	}

	public void setStatus(final String value) {
		setChildrenValue("status", value);
	}

	public void setType(Type type) {
		setAttribute("type", type == null ? null : type.name());
	}
}
