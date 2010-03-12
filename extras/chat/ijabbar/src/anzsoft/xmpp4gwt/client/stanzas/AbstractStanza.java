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
import anzsoft.xmpp4gwt.client.packet.DelegatePacket;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.packet.PacketImp;

/**
 * @author bmalkow
 * 
 */
public abstract class AbstractStanza extends DelegatePacket implements Stanza {

	public AbstractStanza(Packet packet) {
		super(packet);
	}

	public AbstractStanza(String name) {
		super(new PacketImp(name));
	}

	protected Packet getChildByXMLNS(String xmlns) {
		for (Packet child : getChildren()) {
			String x = child.getAtribute("xmlns");
			if (x != null && xmlns.equals(x)) {
				return child;
			}
		}
		return null;
	}

	public JID getFrom() {
		String x = getAtribute("from");
		return x != null ? JID.fromString(x) : null;
	}

	public JID getTo() {
		String x = getAtribute("to");
		return x != null ? JID.fromString(x) : null;
	}

	protected void setChildrenValue(String childName, String value) {
		Packet child = getFirstChild(childName);
		if (child == null && value != null) {
			child = addChild(childName, null);
		} else if (child != null && value == null) {
			removeChild(child);
		}
		if (child != null && value != null) {
			child.setCData(value);
		}
	}

	public void setFrom(JID jid) {
		setAttribute("from", jid == null ? null : jid.toString());
	}

	public void setTo(JID jid) {
		setAttribute("to", jid == null ? null : jid.toString());
	}

}
