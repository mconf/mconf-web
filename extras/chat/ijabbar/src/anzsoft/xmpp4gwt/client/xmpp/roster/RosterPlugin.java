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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import com.google.gwt.core.client.GWT;
import com.google.gwt.json.client.JSONArray;
import com.google.gwt.json.client.JSONObject;
import com.google.gwt.json.client.JSONParser;
import com.google.gwt.json.client.JSONString;

import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.Plugin;
import anzsoft.xmpp4gwt.client.PluginState;
import anzsoft.xmpp4gwt.client.ResponseHandler;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.Storage;
import anzsoft.xmpp4gwt.client.Session.ServerType;
import anzsoft.xmpp4gwt.client.citeria.Criteria;
import anzsoft.xmpp4gwt.client.citeria.ElementCriteria;
import anzsoft.xmpp4gwt.client.events.Events;
import anzsoft.xmpp4gwt.client.events.Signal;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.stanzas.IQ;
import anzsoft.xmpp4gwt.client.xmpp.ErrorCondition;
import anzsoft.xmpp4gwt.client.xmpp.roster.RosterItem.Subscription;

public class RosterPlugin implements Plugin {

	private Map<String, RosterItem> rosterItemsByBareJid = new HashMap<String, RosterItem>();

	private List<RosterListener> rosterListeners = new ArrayList<RosterListener>();

	private boolean rosterReceived;

	private Session session;

	private PluginState stage = PluginState.NONE;

	private static final String STORAGEKEY = "iJabRoster";

	private Packet rosterQuery = null;

	private static final String INIT_ID = "get_roster_0";

	public RosterPlugin(Session session) {
		this.session = session;
	}

	public void addItem(JID jid, String name, List<String> groupsNames,
			ResponseHandler handler) {
		if (!fireBeforeAddItemfinal(jid, name, groupsNames))
			return;
		IQ iq = new IQ(IQ.Type.set);
		String id = String.valueOf(Session.nextId());
		iq.setAttribute("id", id);

		Packet query = iq.addChild("query", "jabber:iq:roster");

		Packet item = query.addChild("item", null);
		item.setAttribute("jid", jid.toString());
		item.setAttribute("name", name);

		if (groupsNames != null) {
			for (int i = 0; i < groupsNames.size(); i++) {
				Packet group = item.addChild("group", null);
				group.setCData(groupsNames.get(i).toString());
			}
		}

		session.addResponseHandler(iq, handler);
	}

	public void addItem(JID jid, String text, String[] itemGroups,
			ResponseHandler itemEditorDialog) {
		List<String> groups = new ArrayList<String>();
		if (itemGroups != null) {
			for (int i = 0; i < itemGroups.length; i++) {
				groups.add(itemGroups[i]);
			}
		}
		addItem(jid, text, groups, itemEditorDialog);
	}

	public void addItem(RosterItem ri, ResponseHandler itemEditorDialog) {
		addItem(JID.fromString(ri.getJid()), ri.getName(), ri.getGroups(),
				itemEditorDialog);
	}

	public void addRosterListener(RosterListener listener) {
		this.rosterListeners.add(listener);
	}

	private void fireAddRosterItem(final RosterItem rosterItem) {
		for (int i = 0; i < rosterListeners.size(); i++) {
			rosterListeners.get(i).onAddItem(rosterItem);
		}
	}

	private boolean fireBeforeAddItemfinal(JID jid, final String name,
			final List<String> groupsNames) {
		try {
			for (RosterListener listener : this.rosterListeners) {
				listener.beforeAddItem(jid, name, groupsNames);
			}
			return true;
		} catch (Exception e) {
			return false;
		}
	}

	private void fireEndRosterUpdating() {
		for (int i = 0; i < rosterListeners.size(); i++) {
			rosterListeners.get(i).onEndRosterUpdating();
		}
	}

	private void fireRemoveRosterItem(final RosterItem rosterItem) {
		for (int i = 0; i < rosterListeners.size(); i++) {
			rosterListeners.get(i).onRemoveItem(rosterItem);
		}
	}

	private void fireStartRosterUpdating() {
		for (int i = 0; i < rosterListeners.size(); i++) {
			rosterListeners.get(i).onStartRosterUpdating();
		}
	}

	private void fireUpdateRosterItem(final RosterItem rosterItem) {
		for (int i = 0; i < rosterListeners.size(); i++) {
			rosterListeners.get(i).onUpdateItem(rosterItem);
		}
	}

	private void fireInitRoster() {
		for (RosterListener l : rosterListeners) {
			l.onInitRoster();
		}
	}

	public List<RosterItem> getAllRosteritems() {
		return new ArrayList<RosterItem>(this.rosterItemsByBareJid.values());
	}

	public int getAllRosterItemCount() {
		if (rosterQuery == null)
			return getAllRosteritems().size();
		else
			return rosterQuery.getChildren().size();
	}

	public Criteria getCriteria() {
		return ElementCriteria.name("iq").add(
				ElementCriteria.name("query", new String[] { "xmlns" },
						new String[] { "jabber:iq:roster" }));
	}

	public String[] getGroupsByJid(JID jid) {
		RosterItem rosterItem = this.rosterItemsByBareJid.get(jid
				.toStringBare());
		if (rosterItem != null) {
			return rosterItem.getGroups();
		}
		return null;
	}

	public List<String> getJidsByGroupName(String groupName) {
		ArrayList<String> result = new ArrayList<String>();
		Iterator<RosterItem> iterator = this.rosterItemsByBareJid.values()
				.iterator();
		while (iterator.hasNext()) {
			RosterItem ri = iterator.next();
			boolean ok = false;
			if (groupName == null
					&& (ri.getGroups() == null || ri.getGroups().length == 0)) {
				ok = true;
			} else if (groupName != null && ri.getGroups() != null) {
				for (int i = 0; i < ri.getGroups().length; i++) {
					ok = ok | groupName.equals(ri.getGroups()[i]);
				}
			}
			if (ok) {
				result.add(ri.getJid());
			}
		}
		return result;
	}

	public String getNameByJid(JID from) {
		RosterItem rosterItem = this.rosterItemsByBareJid.get(from
				.toStringBare());
		if (rosterItem != null) {
			return rosterItem.getName();
		}
		return null;
	}

	public void getRoster() {
		stage = PluginState.IN_PROGRESS;
		IQ iq = new IQ(IQ.Type.get);
		iq.setAttribute("id", INIT_ID);
		iq.addChild("query", "jabber:iq:roster");
		if (session.getServerType().equals(ServerType.EJabberd))
			session.send(iq);
		else {
			session.addResponseHandler(iq, new ResponseHandler() {
				public void onError(IQ iq, ErrorType errorType,
						ErrorCondition errorCondition, String text) {
					rosterReceived = true;
					stage = PluginState.ERROR;
				}

				public void onResult(IQ iq) {
					GWT.log("process roster at function getRoster call back!",
							null);
					stage = PluginState.SUCCESS;
					rosterReceived = true;
					processRoster(iq);
				}
			});
		}
	}

	public RosterItem getRosterItem(JID jid) {
		RosterItem rosterItem = this.rosterItemsByBareJid.get(jid
				.toStringBare());
		return rosterItem;
	}

	public List<RosterItem> getRosterItemsByGroupName(String groupName) {
		ArrayList<RosterItem> result = new ArrayList<RosterItem>();
		Iterator<RosterItem> iterator = this.rosterItemsByBareJid.values()
				.iterator();
		while (iterator.hasNext()) {
			RosterItem ri = iterator.next();
			boolean ok = false;
			if (groupName == null
					&& (ri.getGroups() == null || ri.getGroups().length == 0)) {
				ok = true;
			} else if (groupName != null && ri.getGroups() != null) {
				for (int i = 0; i < ri.getGroups().length; i++) {
					ok = ok | groupName.equals(ri.getGroups()[i]);
				}
			}
			if (ok) {
				result.add(ri);
			}
		}
		return result;
	}

	public PluginState getStatus() {
		return stage;
	}

	public boolean isContactExists(JID jid) {
		return this.rosterItemsByBareJid.containsKey(jid.toStringBare());
	}

	/**
	 * @return the rosterReceived
	 */
	public boolean isRosterReceived() {
		return rosterReceived;
	}

	private void processRoster(IQ iq) {
		rosterQuery = iq.getFirstChild("query");
		try {
			fireStartRosterUpdating();
			for (Packet item : rosterQuery.getChildren()) {
				processRosterItem(new IQ(iq), item);
			}
		} finally {
			fireEndRosterUpdating();
		}
	}

	private void processInitRoster(IQ iq) {
		GWT.log("process init roster!It's may be huage!", null);
		rosterQuery = iq.getFirstChild("query");
		fireInitRoster();
		fireEndRosterUpdating();
	}

	public boolean process(Packet iq) {
		if (!iq.getAtribute("type").equals("result")) {
			rosterReceived = true;
			stage = PluginState.ERROR;
		} else {
			stage = PluginState.SUCCESS;
			rosterReceived = true;
			if (iq.getAtribute("id").equalsIgnoreCase(INIT_ID))
				processInitRoster(new IQ(iq));
			else
				processRoster(new IQ(iq));
		}
		return true;
	}

	public void processRosterItem(final IQ iq, Packet item) {
		final String jid = item.getAtribute("jid");
		final String name = item.getAtribute("name");
		final String tmp = item.getAtribute("subscription");
		final String _ask = item.getAtribute("ask");
		String order = item.getAtribute("order");
		boolean ask = _ask != null && "subscribe".equals(_ask);

		if (order != null) {
			order = "000000" + order;
			order = order.substring(order.length() - 6);
		}

		List<? extends Packet> grl = item.getChildren();
		final String[] groups = new String[grl.size()];
		for (int i = 0; i < grl.size(); i++) {
			Packet gri = grl.get(i);
			if (gri != null) {
				groups[i] = gri.getCData();
			} else {
				groups[i] = "";
			}
		}

		RosterItem rosterItem = this.rosterItemsByBareJid.get(jid);
		List<Signal> signals = new ArrayList<Signal>();
		if (tmp.equals("remove")) {
			rosterItemsByBareJid.remove(jid);
			fireRemoveRosterItem(rosterItem);
			signals.add(new Signal(Events.rosterItemRemoved, new RosterEvent(
					iq, rosterItem)));
		} else if (rosterItem == null) {
			final Subscription subscription = tmp == null ? Subscription.none
					: Subscription.valueOf(tmp);
			rosterItem = new RosterItem(jid, name, subscription, ask, groups,
					order);
			rosterItemsByBareJid.put(jid, rosterItem);
			fireAddRosterItem(rosterItem);
			signals.add(new Signal(Events.rosterItemAdded, new RosterEvent(iq,
					rosterItem)));
		} else {
			final Subscription subscription = tmp == null ? Subscription.none
					: Subscription.valueOf(tmp);
			if (rosterItem.isAsk() == true
					&& ask == false
					&& (subscription == Subscription.from || subscription == Subscription.none)) {
				RosterEvent event = new RosterEvent(iq, rosterItem);
				signals.add(new Signal(Events.askCancelled, event));
			} else if (rosterItem.getSubscription() == Subscription.both
					&& subscription == Subscription.from
					|| rosterItem.getSubscription() == Subscription.to
					&& subscription == Subscription.none) {
				signals.add(new Signal(Events.unsubscribed, new RosterEvent(iq,
						rosterItem)));
			} else if (rosterItem.getSubscription() == Subscription.from
					&& subscription == Subscription.both
					|| rosterItem.getSubscription() == Subscription.none
					&& subscription == Subscription.to) {
				signals.add(new Signal(Events.subscribed, new RosterEvent(iq,
						rosterItem)));
			}

			rosterItem.setName(name);
			rosterItem.setSubscription(subscription);
			rosterItem.setGroups(groups);
			rosterItem.setAsk(ask);
			rosterItem.setOrder(order);

			fireUpdateRosterItem(rosterItem);
			signals.add(new Signal(Events.rosterItemUpdated, new RosterEvent(
					iq, rosterItem)));
		}
		session.getEventsManager().fireEvents(signals);
	}

	public void removeRosterItem(JID jidToRemove) {
		IQ iq = new IQ(IQ.Type.set);
		iq.setAttribute("id", String.valueOf(Session.nextId()));

		Packet query = iq.addChild("query", "jabber:iq:roster");

		Packet item = query.addChild("item", null);
		item.setAttribute("jid", jidToRemove.toString());
		item.setAttribute("subscription", "remove");

		session.addResponseHandler(iq, new ResponseHandler() {
			public void onError(IQ iq, ErrorType errorType,
					ErrorCondition errorCondition, String text) {
			}

			public void onResult(IQ iq) {
			}
		});
	}

	public void removeRosterListener(RosterListener listener) {
		this.rosterListeners.remove(listener);
	}

	public void reset() {
		final String prefix = Session.instance().getUser().getStorageID();
		Storage storage = Storage.createStorage(STORAGEKEY, prefix);
		storage.remove("index");
		this.rosterItemsByBareJid.clear();
		this.rosterReceived = false;
		this.stage = PluginState.NONE;
	}

	public void setInitializedDirty() {
		this.rosterReceived = true;
		this.stage = PluginState.SUCCESS;
	}

	public void saveStatus() {
		try {
			JSONArray jRoster = new JSONArray();
			Iterator<RosterItem> iterator = this.rosterItemsByBareJid.values()
					.iterator();
			int index = 0;
			final String prefix = Session.instance().getUser().getStorageID();
			Storage storage = Storage.createStorage(STORAGEKEY, prefix);
			while (iterator.hasNext()) {
				RosterItem ri = iterator.next();
				jRoster.set(index, new JSONString(ri.getJid()));
				storage.set(ri.getJid(), ri.toJsonObject().toString());
			}
			storage.set("index", jRoster.toString());
		} catch (Exception e) {
			System.out.println(e.toString());
		}
	}

	public void suspend() {
		saveStatus();
	}

	public boolean resume() {
		try {
			final String prefix = Session.instance().getUser().getStorageID();
			Storage storage = Storage.createStorage(STORAGEKEY, prefix);
			String indexString = storage.get("index");
			if (indexString == null)
				return false;
			JSONArray jRoster = JSONParser.parse(indexString).isArray();
			if (jRoster == null)
				return false;
			rosterItemsByBareJid.clear();
			for (int index = 0; index < jRoster.size(); index++) {
				String jid = jRoster.get(index).isString().stringValue();
				if (jid == null || jid.length() == 0)
					continue;
				String objectString = storage.get(jid);
				if (objectString == null || objectString.length() == 0)
					continue;
				JSONObject object = JSONParser.parse(objectString).isObject();
				if (object == null)
					continue;
				RosterItem ri = new RosterItem();
				ri.fromJsonObject(object);
				rosterItemsByBareJid.put(ri.getJid(), ri);
			}
			this.rosterReceived = true;
			Iterator<RosterItem> iterator = this.rosterItemsByBareJid.values()
					.iterator();
			while (iterator.hasNext()) {
				RosterItem ri = iterator.next();
				this.fireAddRosterItem(ri);
			}
		} catch (Exception e) {
			System.out.println(e.toString());
		}
		return true;
	}

	public Packet getRosterPacket() {
		return this.rosterQuery;
	}

}
