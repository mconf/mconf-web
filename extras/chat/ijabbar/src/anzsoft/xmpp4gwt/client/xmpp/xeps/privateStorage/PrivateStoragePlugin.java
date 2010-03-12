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

import java.util.HashMap;
import java.util.Map;

import anzsoft.xmpp4gwt.client.Plugin;
import anzsoft.xmpp4gwt.client.PluginState;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.citeria.Criteria;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.packet.PacketImp;
import anzsoft.xmpp4gwt.client.stanzas.IQ;

public class PrivateStoragePlugin implements Plugin {

	static String makeKey(final String elementName, final String xmlns) {
		return ":" + elementName + ": :" + xmlns + ":";
	}

	private Map<String, Packet> privateData = new HashMap<String, Packet>();

	private Session session;

	public PrivateStoragePlugin(Session session) {
		this.session = session;
	}

	public Criteria getCriteria() {
		return null;
	}

	public Packet getPrivateData(final String elementName, final String xmlns) {
		final String key = makeKey(elementName, xmlns);
		return this.privateData.get(key);
	}

	public void getPrivateData(final String elementName, final String xmlns,
			final PrivateStorageRequestCallback callback) {
		IQ iq = new IQ(IQ.Type.get);
		iq.setAttribute("id", "" + Session.nextId());

		Packet query = iq.addChild("query", "jabber:iq:private");

		query.addChild(elementName, xmlns);

		callback.setSender(this);
		this.session.addResponseHandler(iq, callback);
	}

	public PluginState getStatus() {
		return null;
	}

	public boolean process(Packet element) {
		return false;
	}

	public void reset() {
		privateData.clear();
	}

	public void store(Packet q) {
		IQ iq = new IQ(IQ.Type.set);
		iq.setAttribute("id", "" + Session.nextId());

		Packet query = iq.addChild("query", "jabber:iq:private");

		((PacketImp) query).addChild(q);

		update(q);
		this.session.send(iq);
	}

	void update(final Packet element) {
		String xmlns = element.getAtribute("xmlns");
		String name = element.getName();
		final String key = makeKey(name, xmlns);
		this.privateData.put(key, element);
	}

}
