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
package anzsoft.xmpp4gwt.client.xmpp.privacy;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import anzsoft.xmpp4gwt.client.Plugin;
import anzsoft.xmpp4gwt.client.PluginState;
import anzsoft.xmpp4gwt.client.ResponseHandler;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.citeria.Criteria;
import anzsoft.xmpp4gwt.client.citeria.ElementCriteria;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.stanzas.IQ;
import anzsoft.xmpp4gwt.client.xmpp.ErrorCondition;

public class PrivacyListsPlugin implements Plugin {

	public static interface RetrieveListHandler {
		void onRtrieveList(String listName, PrivacyList list);
	}

	public static interface RetrieveListsNamesHandler {
		void onRetrieve(String activeListName, String defaultListName,
				Set<String> listNames);
	}

	private final static Criteria CRIT = ElementCriteria.name("iq",
			new String[] { "type" }, new String[] { "set" }).add(
			ElementCriteria.name("query", new String[] { "xmlns" },
					new String[] { "jabber:iq:privacy" }));

	private String activeList;

	private String defaultList;

	private boolean listRetrieved = false;

	private final Set<String> listsNames = new HashSet<String>();

	private final Session session;

	public PrivacyListsPlugin(Session session) {
		this.session = session;
	};

	public PrivacyList createList(String name) {
		return new PrivacyList(name, this);
	}

	public Criteria getCriteria() {
		return CRIT;
	}

	public PluginState getStatus() {
		return null;
	}

	public boolean isListExists(String name) {
		if (listRetrieved) {
			return this.listsNames.contains(name);
		} else
			throw new RuntimeException("List not retrieved yet");
	}

	public boolean isListNamesRetrieved() {
		return this.listRetrieved;
	}

	public boolean process(Packet stanza) {
		IQ iq = new IQ(stanza);
		this.session.send(iq.makeResult());
		return true;
	}

	public void reset() {
		this.listsNames.clear();
		this.activeList = null;
		this.defaultList = null;
		this.listRetrieved = false;

	}

	public void retrieveList(final String name,
			final RetrieveListHandler handler) {
		IQ iq = new IQ(IQ.Type.get);
		iq.setId(Session.nextId());
		Packet query = iq.addChild("query", "jabber:iq:privacy");
		Packet list = query.addChild("list", null);
		list.setAttribute("name", name);

		this.session.addResponseHandler(iq, new ResponseHandler() {

			public void onError(IQ iq, ErrorType errorType,
					ErrorCondition errorCondition, String text) {
				if (handler != null)
					handler.onRtrieveList(name, null);
			}

			public void onResult(IQ iq) {
				Packet query = iq.getFirstChild("query");
				Packet list = query.getFirstChild("list");
				PrivacyList pl = new PrivacyList(list, PrivacyListsPlugin.this);
				if (handler != null)
					handler.onRtrieveList(name, pl);
			}
		});
	}

	public void retrieveListsNames(final RetrieveListsNamesHandler handler) {
		IQ iq = new IQ(IQ.Type.get);
		iq.setId(Session.nextId());
		iq.addChild("query", "jabber:iq:privacy");

		this.session.addResponseHandler(iq, new ResponseHandler() {

			public void onError(IQ iq, ErrorType errorType,
					ErrorCondition errorCondition, String text) {
			}

			public void onResult(IQ iq) {
				listsNames.clear();
				listRetrieved = true;
				Packet query = iq.getFirstChild("query");
				List<? extends Packet> children = query.getChildren();
				if (children != null) {
					for (Packet kid : children) {
						if ("active".equals(kid.getName())) {
							activeList = kid.getAtribute("name");
						} else if ("default".equals(kid.getName())) {
							defaultList = kid.getAtribute("name");
						} else if ("list".equals(kid.getName())) {
							listsNames.add(kid.getAtribute("name"));
						}
					}
				}
				if (handler != null) {
					handler.onRetrieve(activeList, defaultList, listsNames);
				}
			}
		});

	}

	public void sendPrivacyList(final PrivacyList privacyList) {
		IQ iq = new IQ(IQ.Type.set);
		iq.setId(Session.nextId());
		Packet query = iq.addChild("query", "jabber:iq:privacy");
		privacyList.addToQuery(query);
		this.session.addResponseHandler(iq, new ResponseHandler() {

			public void onError(IQ iq, ErrorType errorType,
					ErrorCondition errorCondition, String text) {
			}

			public void onResult(IQ iq) {
				PrivacyListsPlugin.this.listsNames.add(privacyList.getName());
			}
		});
	}

	public void setActive(final String name) {
		IQ iq = new IQ(IQ.Type.set);
		iq.setId(Session.nextId());
		Packet query = iq.addChild("query", "jabber:iq:privacy");
		Packet act = query.addChild("active", null);
		act.setAttribute("name", name);
		this.session.addResponseHandler(iq, new ResponseHandler() {

			public void onError(IQ iq, ErrorType errorType,
					ErrorCondition errorCondition, String text) {
			}

			public void onResult(IQ iq) {
				PrivacyListsPlugin.this.activeList = name;
			}
		});
	}

	public void setDefault(final String name) {
		IQ iq = new IQ(IQ.Type.set);
		iq.setId(Session.nextId());
		Packet query = iq.addChild("query", "jabber:iq:privacy");
		Packet def = query.addChild("default", null);
		def.setAttribute("name", name);
		this.session.addResponseHandler(iq, new ResponseHandler() {

			public void onError(IQ iq, ErrorType errorType,
					ErrorCondition errorCondition, String text) {
			}

			public void onResult(IQ iq) {
				PrivacyListsPlugin.this.defaultList = name;
			}
		});
	}

}
