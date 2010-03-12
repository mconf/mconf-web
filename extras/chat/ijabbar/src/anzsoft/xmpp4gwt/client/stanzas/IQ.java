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

import anzsoft.xmpp4gwt.client.packet.Packet;

/**
 * @author bmalkow
 * 
 */
public class IQ extends AbstractStanza {

	public static enum Type {
		error, get, result, set
	}

	public IQ(final Packet packet) {
		super(packet);
	}

	public IQ(Type type) {
		super("iq");
		if (type != null) {
			setAttribute("type", type.name());
		}
	}

	public String getId() {
		return getAtribute("id");
	}

	public Type getType() {
		String tmp = getAtribute("type");
		if (tmp != null) {
			try {
				return Type.valueOf(tmp);
			} catch (Exception e) {
				return null;
			}
		} else {
			return null;
		}
	}

	public IQ makeResult() {
		IQ result = new IQ(Type.result);
		result.setAttribute("id", getId());
		result.setFrom(getTo());
		result.setTo(getFrom());
		return result;
	}

	public void setId(String id) {
		setAttribute("id", id);
	}

	public void setType(Type type) {
		setAttribute("type", type != null ? type.name() : null);
	}
}
