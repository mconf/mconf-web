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
package anzsoft.xmpp4gwt.client.xmpp.roster;

import anzsoft.xmpp4gwt.client.events.IQEvent;
import anzsoft.xmpp4gwt.client.stanzas.IQ;

public class RosterEvent extends IQEvent {

	private final RosterItem rosterItem;

	protected RosterEvent(IQ iqElement, RosterItem rosterItem) {
		super(iqElement);
		this.rosterItem = rosterItem;
	}

	public RosterItem getRosterItem() {
		return rosterItem;
	}

	@Override
	public String toString() {
		return rosterItem.getName() + " <" + rosterItem.getJid() + "> ("
				+ rosterItem.getSubscription() + ")";
	}
}
