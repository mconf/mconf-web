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
package anzsoft.xmpp4gwt.client.xmpp.sasl;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import anzsoft.xmpp4gwt.client.Connector;
import anzsoft.xmpp4gwt.client.Plugin;
import anzsoft.xmpp4gwt.client.PluginState;
import anzsoft.xmpp4gwt.client.User;
import anzsoft.xmpp4gwt.client.citeria.Criteria;
import anzsoft.xmpp4gwt.client.citeria.ElementCriteria;
import anzsoft.xmpp4gwt.client.citeria.Or;
import anzsoft.xmpp4gwt.client.events.Events;
import anzsoft.xmpp4gwt.client.events.EventsManager;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.packet.PacketImp;

import com.google.gwt.core.client.GWT;

public class SaslAuthPlugin implements Plugin {

	private final Connector con;

	private final EventsManager eventsManager;

	private boolean featuresReceived = false;

	@SuppressWarnings("deprecation")
	private ArrayList<SaslAuthPluginListener> listeners = new ArrayList<SaslAuthPluginListener>();

	private SaslMechanism mechanism;

	private Set<String> serverMechanisms = new HashSet<String>();

	private PluginState stage = PluginState.NONE;

	public SaslAuthPlugin(final Connector con, final User user,
			final EventsManager eventsManager) {
		this(con, user, eventsManager, null);
	}

	public SaslAuthPlugin(final Connector con, final User user,
			final EventsManager eventsManager, final SaslMechanism saslMechanism) {
		this.con = con;
		this.eventsManager = eventsManager;
		this.mechanism = saslMechanism;
		if (this.mechanism == null) {
			this.mechanism = new PlainMechanism(user);
		}
		// this.mechanism = new AnonymousMechanism();
	}

	@SuppressWarnings("deprecation")
	public void addSaslAuthListener(SaslAuthPluginListener listener) {
		this.listeners.add(listener);
	}

	public void auth() {
		stage = PluginState.IN_PROGRESS;
		fireEventStartAuth();
		eventsManager.fireEvent(Events.saslStartAuth, new SaslEvent(mechanism,
				null));
		Packet auth = new PacketImp("auth");
		auth.setAttribute("xmlns", "urn:ietf:params:xml:ns:xmpp-sasl");
		auth.setAttribute("mechanism", mechanism.name());

		String req = mechanism.evaluateChallenge(null);
		GWT.log("SASL request: " + req, null);

		if (req != null) {
			auth.setCData(req);
		}

		con.send(auth);
	}

	@Deprecated
	private void fireEventFail(String message) {
		for (int i = 0; i < listeners.size(); i++) {
			(listeners.get(i)).onFail(message);
		}
	}

	@Deprecated
	private void fireEventStartAuth() {
		for (int i = 0; i < listeners.size(); i++) {
			(listeners.get(i)).onStartAuth();
		}
	}

	@Deprecated
	private void fireEventSuccess() {
		for (int i = 0; i < listeners.size(); i++) {
			(listeners.get(i)).onSuccess();
		}
	}

	public Criteria getCriteria() {
		return new Or(new Criteria[] {
				ElementCriteria.name("stream:features").add(
						ElementCriteria.name("mechanisms")),
				ElementCriteria.name("success"),
				ElementCriteria.name("failure") });
	}

	public SaslMechanism getMechanism() {
		return mechanism;
	}

	public PluginState getStatus() {
		return this.stage;
	}

	/**
	 * @return the featuresReceived
	 */
	public boolean isFeaturesReceived() {
		return featuresReceived;
	}

	public boolean process(Packet element) {
		if ("failure".equals(element.getName())) {
			stage = PluginState.ERROR;
			List<? extends Packet> children = element.getChildren();
			Packet x = children != null && children.size() > 0 ? children
					.get(0) : null;
			String msg = null;
			if (x != null)
				msg = x.getName();
			fireEventFail(msg);
			eventsManager.fireEvent(Events.saslFail, new SaslEvent(mechanism,
					msg));
		} else if ("success".equals(element.getName())) {
			stage = PluginState.SUCCESS;
			fireEventSuccess();
			eventsManager.fireEvent(Events.saslSuccess, new SaslEvent(
					mechanism, null));
		} else if ("stream:features".equals(element.getName())) {
			featuresReceived = true;
			GWT.log("auth stream:features received", null);

			Packet mechanisms = element.getFirstChild("mechanisms");

			for (Packet mechanism : mechanisms.getChildren()) {
				serverMechanisms.add(mechanism.getCData());
			}

		}
		return true;
	}

	@SuppressWarnings("deprecation")
	public void removeSaslAuthListener(SaslAuthPluginListener listener) {
		this.listeners.remove(listener);
	}

	public void reset() {
		this.featuresReceived = false;
		this.serverMechanisms.clear();
		this.stage = PluginState.NONE;
	}

	public void setMechanism(SaslMechanism mechanism) {
		this.mechanism = mechanism;
	}
}
