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
package anzsoft.xmpp4gwt.client.packet;

import java.util.List;

/**
 * @author bmalkow
 * 
 */
public class DelegatePacket implements Packet {

	private final Packet packet;

	public DelegatePacket(Packet packet) {
		this.packet = packet;
	}

	public Packet addChild(String nodeName, String xmlns) {
		return packet.addChild(nodeName, xmlns);
	}

	public String getAsString() {
		return packet.getAsString();
	}

	public String getAtribute(String attrName) {
		return packet.getAtribute(attrName);
	}

	public String getCData() {
		return packet.getCData();
	}

	public Packet getChild(String name, String xmlns) {
		for (Packet p : getChildren()) {
			if (p.getName().equals(name)) {
				String x = p.getAtribute("xmlns");
				if (x != null && x.equals(xmlns))
					return p;
			}
		}
		return null;
	}

	public List<? extends Packet> getChildren() {
		return packet.getChildren();
	}

	public Packet getFirstChild(String name) {
		return packet.getFirstChild(name);
	}

	public String getName() {
		return packet.getName();
	}

	public void removeChild(Packet packet) {
		this.packet.removeChild(packet);
	}

	public void setAttribute(String attrName, String value) {
		packet.setAttribute(attrName, value);
	}

	public void setCData(String cdata) {
		packet.setCData(cdata);
	}

	@Override
	public String toString() {
		return getAsString();
	}

}
