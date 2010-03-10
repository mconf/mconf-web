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

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.stanzas.AbstractStanza;

public class MucXPacket extends AbstractStanza {

	public MucXPacket(Packet packet) {
		super(packet);
	}

	public Affiliation getAffiliation() {
		Packet item = getFirstChild("item");
		if (item != null) {
			String tmp = item.getAtribute("affiliation");
			return tmp == null ? null : Affiliation.valueOf(tmp);
		} else
			return null;
	}

	public JID getJid() {
		Packet item = getFirstChild("item");
		if (item != null) {
			String tmp = item.getAtribute("jid");
			return tmp == null ? null : JID.fromString(tmp);
		} else
			return null;
	}

	public String getNickname() {
		Packet item = getFirstChild("item");
		if (item != null) {
			String tmp = item.getAtribute("nick");
			return tmp;
		} else
			return null;
	}

	public Role getRole() {
		Packet item = getFirstChild("item");
		if (item != null) {
			String tmp = item.getAtribute("role");
			return tmp == null ? null : Role.valueOf(tmp);
		} else
			return null;
	}

	public Set<String> getStatusCodes() {
		List<? extends Packet> kids = getChildren();
		Set<String> result = new HashSet<String>();
		for (Packet k : kids) {
			if (k.getName().equals("status")) {
				result.add(k.getAtribute("code"));
			}
		}
		return result;
	}

}
