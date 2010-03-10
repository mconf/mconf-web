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
package anzsoft.xmpp4gwt.client.xmpp.xeps.privateStorage;

import java.util.List;

import anzsoft.xmpp4gwt.client.ResponseHandler;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.stanzas.IQ;

public abstract class PrivateStorageRequestCallback implements ResponseHandler {

	private PrivateStoragePlugin sender;

	public abstract void onReceiveData(Packet element);

	public final void onResult(IQ iq) {
		Packet query = iq.getFirstChild("query");

		List<? extends Packet> children = query.getChildren();

		Packet element = children != null && children.size() > 0 ? children
				.get(0) : null;

		if (sender != null)
			sender.update(element);
		onReceiveData(element);
	}

	void setSender(PrivateStoragePlugin sender) {
		this.sender = sender;
	}
}
