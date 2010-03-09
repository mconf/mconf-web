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
public interface Packet {

	Packet addChild(String nodeName, String xmlns);

	String getAsString();

	String getAtribute(final String attrName);

	String getCData();

	List<? extends Packet> getChildren();

	Packet getFirstChild(final String name);

	String getName();

	void removeChild(Packet packet);

	void setAttribute(final String attrName, final String value);

	void setCData(final String cdata);
}
