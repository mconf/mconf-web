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
package anzsoft.xmpp4gwt.client.xmpp;

import java.util.ArrayList;

import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.Plugin;
import anzsoft.xmpp4gwt.client.PluginState;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.User;
import anzsoft.xmpp4gwt.client.citeria.Criteria;
import anzsoft.xmpp4gwt.client.citeria.ElementCriteria;
import anzsoft.xmpp4gwt.client.citeria.Or;
import anzsoft.xmpp4gwt.client.events.Events;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.stanzas.IQ;

public class ResourceBindPlugin implements Plugin {

	private JID bindedJid;

	private final Session con;

	@SuppressWarnings("deprecation")
	private ArrayList<ResourceBindListener> listeners = new ArrayList<ResourceBindListener>();

	private boolean ready = false;

	private PluginState stage = PluginState.NONE;

	private final User user;

	public ResourceBindPlugin(Session con, User user) {
		this.user = user;
		this.con = con;
	}

	@SuppressWarnings("deprecation")
	public void addResourceBindListener(ResourceBindListener listener) {
		this.listeners.add(listener);
	}

	public IQ bindInRestarStream() {
		stage = PluginState.IN_PROGRESS;
		IQ iq = new IQ(IQ.Type.set);
		iq.setAttribute("id", "" + Session.nextId());
		iq.setAttribute("xmlns", "jabber:client");

		Packet bind = iq.addChild("bind", "urn:ietf:params:xml:ns:xmpp-bind");

		Packet resource = bind.addChild("resource", null);
		resource.setCData(user.getResource());
		return iq;
	}

	public void bind() {
		stage = PluginState.IN_PROGRESS;
		IQ iq = new IQ(IQ.Type.set);
		iq.setAttribute("id", "" + Session.nextId());
		iq.setAttribute("xmlns", "jabber:client");

		Packet bind = iq.addChild("bind", "urn:ietf:params:xml:ns:xmpp-bind");

		Packet resource = bind.addChild("resource", null);
		resource.setCData(user.getResource());

		con.send(iq);

	}

	@Deprecated
	private void fireOnBindResource(final JID jid) {
		for (int i = 0; i < this.listeners.size(); i++) {
			ResourceBindListener l = this.listeners.get(i);
			l.onBindResource(jid);
		}
	}

	/**
	 * @return the bindedJid
	 */
	public JID getBindedJid() {
		return bindedJid;
	}

	public Criteria getCriteria() {
		return new Or(new Criteria[] {
				ElementCriteria.name("stream:features").add(
						ElementCriteria.name("bind")),
				ElementCriteria.name("iq").add(
						ElementCriteria.name("bind",
								"urn:ietf:params:xml:ns:xmpp-bind")) });
	}

	public PluginState getStatus() {
		return stage;
	}

	public boolean isReady() {
		return ready;
	}

	public boolean process(Packet iq) {
		if ("stream:features".equals(iq.getName())) {
			this.ready = true;
		} else {
			if ("result".equals(iq.getAtribute("type"))) {
				stage = PluginState.SUCCESS;

				Packet bind = iq.getFirstChild("bind");
				Packet jid = bind.getFirstChild("jid");

				ResourceBindPlugin.this.bindedJid = JID.fromString(jid
						.getCData());
				JID new_jid = JID.fromString(jid.getCData());
				user.setUsername(new_jid.getNode());
				fireOnBindResource(new_jid);
				con.getEventsManager().fireEvent(Events.resourceBinded,
						new ResourceBindEvenet(new IQ(iq), new_jid));
			} else {
				stage = PluginState.ERROR;
				con.getEventsManager().fireEvent(Events.resourceBindingError,
						new ResourceBindEvenet(new IQ(iq), null));
			}
		}
		return true;
	}

	@SuppressWarnings("deprecation")
	public void removeResourceBindListener(ResourceBindListener listener) {
		this.listeners.remove(listener);
	}

	public void reset() {
		this.bindedJid = null;
		this.stage = PluginState.NONE;
		this.ready = false;
	}

	public void setInitializedDirty() {
		stage = PluginState.SUCCESS;
		ready = true;
	}

}
