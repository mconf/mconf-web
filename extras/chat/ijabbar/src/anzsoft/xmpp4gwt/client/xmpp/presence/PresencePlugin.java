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
package anzsoft.xmpp4gwt.client.xmpp.presence;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.gwt.core.client.GWT;
import com.google.gwt.json.client.JSONArray;
import com.google.gwt.json.client.JSONParser;
import com.google.gwt.json.client.JSONString;
import com.google.gwt.xml.client.Element;
import com.google.gwt.xml.client.XMLParser;

import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.Plugin;
import anzsoft.xmpp4gwt.client.PluginState;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.SessionListener;
import anzsoft.xmpp4gwt.client.Storage;
import anzsoft.xmpp4gwt.client.Connector.BoshErrorCondition;
import anzsoft.xmpp4gwt.client.citeria.Criteria;
import anzsoft.xmpp4gwt.client.citeria.ElementCriteria;
import anzsoft.xmpp4gwt.client.events.Events;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.packet.PacketGwtImpl;
import anzsoft.xmpp4gwt.client.stanzas.Presence;
import anzsoft.xmpp4gwt.client.stanzas.Presence.Show;
import anzsoft.xmpp4gwt.client.stanzas.Presence.Type;
import anzsoft.xmpp4gwt.client.xmpp.roster.RosterItem;
import anzsoft.xmpp4gwt.client.xmpp.roster.RosterListener;

public class PresencePlugin implements Plugin, SessionListener {

	private final static String STORAGE_CURRENTSHOW = "0";
	private final static String STORAGE_PRIORITY = "1";
	private final static String STORAGE_INIT_PRESENCE = "2";

	private static final String STORAGEKEY = "iJabPresence";

	private Show currentShow;

	private boolean initialPresenceSended;

	/**
	 * String, PresenceItem
	 */
	private Map<String, Presence> presenceByJid = new HashMap<String, Presence>();

	private List<PresenceListener> presenceListeners = new ArrayList<PresenceListener>();

	/**
	 * (String, Map(String, PresenceItem))
	 */
	private Map<String, Map<String, Presence>> presencesMapByBareJid = new HashMap<String, Map<String, Presence>>();

	private int priority = 5;

	private Session session;

	private RosterListener rosterListener = null;

	public PresencePlugin(Session session) {
		this.session = session;
		session.addListener(this);
	}

	public void addPresenceListener(PresenceListener listener) {
		this.presenceListeners.add(listener);
	}

	public List<Presence> getActiveResources(String jid) {
		Map<String, Presence> resourcesPresence = this.presencesMapByBareJid
				.get(jid);
		if (resourcesPresence == null)
			return null;
		List<Presence> result = new ArrayList<Presence>();
		Iterator<Presence> it = resourcesPresence.values().iterator();
		while (it.hasNext()) {
			Presence pi = it.next();
			if (pi.getType() != Presence.Type.unavailable) {
				result.add(pi);
			}
		}
		return result.size() == 0 ? null : result;
	}

	public List<Presence> getAllPresenceItems() {
		return new ArrayList<Presence>(this.presenceByJid.values());
	}

	public int getOnlineCount() {
		int ret = 0;
		Set<String> bareJids = this.presencesMapByBareJid.keySet();
		String selfJid = session.getUser().getUsername() + "@"
				+ session.getUser().getDomainname();
		for (String jid : bareJids) {
			if (isAvailableByBareJid(jid) && !(jid.equalsIgnoreCase(selfJid)))
				ret++;
		}
		return ret;
	}

	public Criteria getCriteria() {
		return ElementCriteria.name("presence");
	}

	public Show getCurrentShow() {
		return currentShow;
	}

	public Presence getPresenceitemByBareJid(String jid) {
		Map<String, Presence> resourcesPresence = this.presencesMapByBareJid
				.get(jid);
		Presence result = null;
		if (resourcesPresence != null) {
			Iterator<Presence> it = resourcesPresence.values().iterator();
			while (it.hasNext()) {
				Presence x = it.next();
				if (x.getType() == Presence.Type.error
						|| x.getType() == Presence.Type.unavailable)
					continue;
				if (result == null
						|| (result.getPriority() < x.getPriority() && x
								.getFrom().getResource() != null)
						|| (x.getFrom().getResource() != null && result
								.getFrom().getResource() == null))
					result = x;
			}
		}
		return result;
	}

	public PluginState getStatus() {
		return null;
	}

	public boolean isAvailableByBareJid(String jid) {
		Map<String, Presence> resourcesPresence = this.presencesMapByBareJid
				.get(jid);
		boolean result = false;
		if (resourcesPresence != null) {
			Iterator<Presence> it = resourcesPresence.values().iterator();
			while (it.hasNext()) {
				Presence x = it.next();
				result = result | x.getType() == Type.available;
			}
		}
		return result;

	}

	/**
	 * @return the initialPresenceSended
	 */
	public boolean isInitialPresenceSended() {
		return initialPresenceSended;
	}

	public Presence offlinePresence() {
		Presence presence = new Presence(Presence.Type.unavailable);
		return presence;
	}

	public boolean process(Packet element) {
		try {
			Presence presence = new Presence(element);
			JID from = presence.getFrom();
			Presence.Type type = presence.getType();
			if (from != null) {
				boolean availableOld = isAvailableByBareJid(from.toStringBare());

				this.presenceByJid.put(from.toString(), presence);
				String resource = from.getResource() == null ? "" : from
						.getResource();
				Map<String, Presence> resourcesPresence = this.presencesMapByBareJid
						.get(from.toStringBare());
				if (resourcesPresence == null) {
					resourcesPresence = new HashMap<String, Presence>();
					this.presencesMapByBareJid.put(from.toStringBare(),
							resourcesPresence);
				}
				resourcesPresence.put(resource, presence);

				boolean availableNow = isAvailableByBareJid(from.toStringBare());

				if (type == Type.subscribe) {
					session.getEventsManager().fireEvent(Events.subscribe,
							new PresenceEvent(presence));
				} else if (!availableOld && availableNow) {
					session.getEventsManager().fireEvent(
							Events.contactAvailable,
							new PresenceEvent(presence));
					for (int i = 0; i < this.presenceListeners.size(); i++) {
						(this.presenceListeners.get(i))
								.onContactAvailable(presence);
					}
				} else if (availableOld && !availableNow) {
					session.getEventsManager().fireEvent(
							Events.contactUnavailable,
							new PresenceEvent(presence));
					for (int i = 0; i < this.presenceListeners.size(); i++) {
						(this.presenceListeners.get(i))
								.onContactUnavailable(presence);
					}
				}

				session.getEventsManager().fireEvent(Events.presenceChange,
						new PresenceEvent(presence));
				for (int i = 0; i < this.presenceListeners.size(); i++) {
					(this.presenceListeners.get(i)).onPresenceChange(presence);
				}

			} else {

				for (int i = 0; i < this.presenceListeners.size(); i++) {
					(this.presenceListeners.get(i)).onPresenceChange(presence);
				}
			}
		} catch (Exception e) {
			System.out.println("Exception happen in PresencePlugin:process:"
					+ e.toString());
		}
		return true;
	}

	public void removePresenceListener(PresenceListener listener) {
		this.presenceListeners.remove(listener);
	}

	public void reset() {
		initialPresenceSended = false;
		presenceByJid.clear();
		presencesMapByBareJid.clear();
	}

	public void sendDirectPresence(JID jid, Show show, String extNick) {
		sendPresence(jid, show, null, null, extNick);
	}

	public void sendInitialPresence() {
		Presence presence = new Presence((Presence.Type) null);
		presence.setPriority(priority);
		for (PresenceListener listener : this.presenceListeners) {
			listener.beforeSendInitialPresence(presence);
		}
		session.getEventsManager().fireEvent(Events.beforeSendInitialPresence,
				new PresenceEvent(presence));
		session.send(presence);
		this.initialPresenceSended = true;
	}

	public void sendInitialPresence(final int priority) {
		Presence presence = new Presence((Presence.Type) null);
		presence.setPriority(priority);

		for (PresenceListener listener : this.presenceListeners) {
			listener.beforeSendInitialPresence(presence);
		}
		session.getEventsManager().fireEvent(Events.beforeSendInitialPresence,
				new PresenceEvent(presence));
		session.send(presence);
		this.initialPresenceSended = true;
	}

	public void sendPresence(final JID to, final Show show,
			final Presence.Type type, final Integer priority, String extNick) {
		Presence presence = new Presence(type);
		if (to != null) {
			presence.setAttribute("to", to.toString());
		}

		presence.setShow(show);
		presence.setPriority(priority);

		presence.setExtNick(extNick);

		session.send(presence);
	}

	public void sendStatus(final Show show) {
		sendPresence(null, show, null, null, null);
	}

	public void sendStatusText(final String text) {
		Presence presence = new Presence(Type.available);

		presence.setShow(currentShow);
		presence.setPriority(priority);
		presence.setStatus(text);
		session.send(presence);
	}

	public void subscribe(JID jid) {
		Presence presence = new Presence(Presence.Type.subscribe, null, jid);

		session.send(presence);
	}

	public void subscribed(JID jid) {
		Presence presence = new Presence(Presence.Type.subscribed, null, jid);

		session.send(presence);
	}

	public void unsubscribed(JID jid) {
		Presence presence = new Presence(Presence.Type.unsubscribed, null, jid);

		presence.setAttribute("to", jid.toString());
		presence.setAttribute("type", "unsubscribed");

		session.send(presence);
	}

	public void bigPresenceUpdated() {
		for (PresenceListener l : presenceListeners) {
			l.onBigPresenceChanged();
		}
	}

	public void saveStatus() {
		List<Presence> presences = this.getAllPresenceItems();
		final String prefix = Session.instance().getUser().getStorageID();
		Storage storage = Storage.createStorage(STORAGEKEY, prefix);
		JSONArray jPresences = new JSONArray();
		for (int index = 0; index < presences.size(); index++) {
			jPresences.set(index, new JSONString(presences.get(index)
					.toString()));
		}
		storage.set("data", jPresences.toString());

		//save current self presence status
		storage.set(STORAGE_CURRENTSHOW, currentShow != null ? currentShow
				.toString() : "");
		storage.set(STORAGE_PRIORITY, String.valueOf(priority));
		storage.set(STORAGE_INIT_PRESENCE, String
				.valueOf(initialPresenceSended));
	}

	public void suspend() {
		saveStatus();
	}

	public void doResume() {
		try {
			final String prefix = Session.instance().getUser().getStorageID();
			Storage storage = Storage.createStorage(STORAGEKEY, prefix);
			if (storage == null)
				return;
			//get self presence
			String showStr = storage.get(STORAGE_CURRENTSHOW);
			if (showStr != null && !(showStr.length() == 0))
				currentShow = Show.valueOf(showStr);
			String priorityStr = storage.get(STORAGE_PRIORITY);
			if (priorityStr != null && !(priorityStr.length() == 0))
				priority = Integer.valueOf(priorityStr);
			String initStr = storage.get(STORAGE_INIT_PRESENCE);
			if (initStr != null)
				initialPresenceSended = initStr.equals("true");
			//get presence data
			String data = storage.get("data");
			if (data == null)
				return;
			JSONArray jPresences = JSONParser.parse(data).isArray();
			if (jPresences == null)
				return;
			for (int index = 0; index < jPresences.size(); index++) {
				String packetStr = jPresences.get(index).isString()
						.stringValue();
				if (packetStr == null || packetStr.length() == 0)
					continue;
				final Packet pPacket = parse(packetStr);
				process(pPacket);
			}
		} catch (Exception e) {
			System.out.println(e.toString());
		}
	}

	public boolean resume() {
		try {
			final String prefix = Session.instance().getUser().getStorageID();
			Storage storage = Storage.createStorage(STORAGEKEY, prefix);
			if (storage == null)
				return false;
		} catch (Exception e) {
			return false;
		}
		if (Session.instance().getRosterPlugin().getStatus() == PluginState.SUCCESS) {
			doResume();
		} else {
			rosterListener = new RosterListener() {
				public void beforeAddItem(JID jid, String name,
						List<String> groupsNames) {
				}

				public void onAddItem(RosterItem item) {
				}

				public void onEndRosterUpdating() {
					doResume();
					Session.instance().getRosterPlugin().removeRosterListener(
							rosterListener);
					rosterListener = null;
				}

				public void onInitRoster() {
				}

				public void onRemoveItem(RosterItem item) {
				}

				public void onStartRosterUpdating() {
				}

				public void onUpdateItem(RosterItem item) {
				}
			};
			Session.instance().getRosterPlugin().addRosterListener(
					rosterListener);
		}
		return true;
	}

	private Packet parse(String s) {
		if (s == null || s.length() == 0) {
			return null;
		} else {
			try {
				Element element = XMLParser.parse(s).getDocumentElement();
				return new PacketGwtImpl(element);
			} catch (Exception e) {
				GWT.log("Parsing error (\"" + s + "\")", e);
				return null;
			}
		}
	}

	private void doClear() {
		final String prefix = Session.instance().getUser().getStorageID();
		Storage storage = Storage.createStorage(STORAGEKEY, prefix);
		storage.remove(STORAGEKEY);
		if (rosterListener != null) {
			Session.instance().getRosterPlugin().removeRosterListener(
					rosterListener);
			rosterListener = null;
		}
	}

	public void onBeforeLogin() {

	}

	public void onEndLogin() {
	}

	public void onError(BoshErrorCondition boshErrorCondition, String message) {
		doClear();
	}

	public void onLoginOut() {
		doClear();
	}

}
