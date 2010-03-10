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
package anzsoft.xmpp4gwt.client.citeria;

import anzsoft.xmpp4gwt.client.packet.Packet;

public class Or implements Criteria {

	private Criteria[] crits;

	public Or(Criteria criteria) {
		this.crits = new Criteria[] { criteria };
	}

	public Or(Criteria criteria1, Criteria criteria2) {
		this.crits = new Criteria[] { criteria1, criteria2 };
	}

	public Or(Criteria[] criteria) {
		this.crits = criteria;
	}

	public Criteria add(Criteria criteria) {
		throw new RuntimeException("Or.add() is not implemented!");
	}

	public boolean match(Packet element) {
		for (int i = 0; i < crits.length; i++) {
			Criteria c = this.crits[i];
			if (c.match(element)) {
				return true;
			}
		}
		return false;
	}

}
