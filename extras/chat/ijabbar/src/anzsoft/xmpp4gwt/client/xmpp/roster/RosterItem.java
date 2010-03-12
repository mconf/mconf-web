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

import com.google.gwt.json.client.JSONArray;
import com.google.gwt.json.client.JSONObject;
import com.google.gwt.json.client.JSONString;

public class RosterItem {

	public static enum Subscription {
		both(true, true), from(true, false), none(false, false), to(false, true);

		private final boolean sFrom;

		private final boolean sTo;

		private Subscription(boolean statusFrom, boolean statusTo) {
			this.sFrom = statusFrom;
			this.sTo = statusTo;
		}

		public boolean isFrom() {
			return this.sFrom;
		}

		public boolean isTo() {
			return this.sTo;
		}
	}

	private boolean ask;

	private String[] groups = {};

	private String jid;

	private String name;

	private String order;

	private Subscription subscription;

	public RosterItem(String jid, String name, Subscription subscription,
			boolean ask, String[] groups) {
		super();
		this.jid = jid;
		this.name = name;
		this.subscription = subscription;
		this.ask = ask;
		this.groups = groups;
		this.order = null;
	}

	public RosterItem(String jid, String name, Subscription subscription,
			boolean ask, String[] groups, String order) {
		super();
		this.jid = jid;
		this.name = name;
		this.subscription = subscription;
		this.ask = ask;
		this.groups = groups;
		this.order = order;
	}

	public RosterItem() {

	}

	/**
	 * @return the groups
	 */
	public String[] getGroups() {
		return groups;
	}

	/**
	 * @return the jid
	 */
	public String getJid() {
		return jid;
	}

	/**
	 * @return the name
	 */
	public String getName() {
		return name;
	}

	public String getOrder() {
		return order;
	}

	/**
	 * @return the subscription
	 */
	public Subscription getSubscription() {
		return subscription;
	}

	/**
	 * @return the ask
	 */
	public boolean isAsk() {
		return ask;
	}

	/**
	 * @param ask
	 *            the ask to set
	 */
	public void setAsk(boolean ask) {
		this.ask = ask;
	}

	/**
	 * @param groups
	 *            the groups to set
	 */
	public void setGroups(String[] groups) {
		this.groups = groups;
	}

	/**
	 * @param jid
	 *            the jid to set
	 */
	public void setJid(String jid) {
		this.jid = jid;
	}

	/**
	 * @param name
	 *            the name to set
	 */
	public void setName(String name) {
		this.name = name;
	}

	public void setOrder(String order) {
		this.order = order;
	}

	/**
	 * @param subscription
	 *            the subscription to set
	 */
	public void setSubscription(Subscription subscription) {
		this.subscription = subscription;
	}

	public void fromJsonObject(JSONObject object) {
		try {
			this.jid = object.get("jid").isString().stringValue();
			if (object.get("name") != null)
				this.name = object.get("name").isString().stringValue();
			this.subscription = Subscription.valueOf(object.get("subscription")
					.isString().stringValue());
			this.ask = object.get("ask").isString().stringValue()
					.equals("true") ? true : false;
			JSONArray jGroup = object.get("groups").isArray();
			if (jGroup != null) {
				this.groups = new String[jGroup.size()];
				for (int index = 0; index < jGroup.size(); index++) {
					this.groups[index] = jGroup.get(index).isString()
							.stringValue();
				}
			}
			if (object.get("order") != null)
				this.order = object.get("order").isString().stringValue();
		} catch (Exception e) {
			System.out.println(e.toString());
		}
	}

	public JSONObject toJsonObject() {
		JSONObject object = new JSONObject();
		try {
			object.put("jid", new JSONString(this.jid));
			if (this.name != null)
				object.put("name", new JSONString(this.name));
			else
				object.put("name", new JSONString(""));
			if (this.subscription.toString() != null)
				object.put("subscription", new JSONString(this.subscription
						.toString()));
			else
				object.put("subscription", new JSONString(""));
			if (ask)
				object.put("ask", new JSONString("true"));
			else
				object.put("ask", new JSONString("false"));
			JSONArray jGroup = new JSONArray();
			if (this.groups.length > 0) {
				for (int index = 0; index < this.groups.length; index++) {
					jGroup.set(index, new JSONString(this.groups[index]));
				}
			}
			object.put("groups", jGroup);
			if (this.order != null)
				object.put("order", new JSONString(this.order));
			else
				object.put("order", new JSONString(""));
		} catch (Exception e) {
			System.out.println(e.toString());
			return null;
		}
		return object;
	}
}
