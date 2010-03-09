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

import java.util.ArrayList;
import java.util.List;

import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.packet.PacketImp;
import anzsoft.xmpp4gwt.client.xmpp.privacy.PrivacyItem.Action;
import anzsoft.xmpp4gwt.client.xmpp.privacy.PrivacyItem.Kind;
import anzsoft.xmpp4gwt.client.xmpp.privacy.PrivacyItem.Type;

public class PrivacyList {

	private final List<PrivacyItem> items = new ArrayList<PrivacyItem>();

	private String name;

	private final PrivacyListsPlugin privacyListsPlugin;

	PrivacyList(Packet list, PrivacyListsPlugin privacyListsPlugin) {
		this.privacyListsPlugin = privacyListsPlugin;
		this.name = list.getAtribute("name");
		List<? extends Packet> children = list.getChildren();
		if (children != null) {
			for (Packet child : children) {
				if ("item".equals(child.getName())) {
					this.items.add(new PrivacyItem(child));
				}
			}
		}
	}

	PrivacyList(String name, PrivacyListsPlugin privacyListsPlugin) {
		this.name = name;
		this.privacyListsPlugin = privacyListsPlugin;
	}

	public void addItem(PrivacyItem item) {
		this.items.add(item);
	}

	public PrivacyItem addRuleBlockJid(JID jid) {
		PrivacyItem pi = new PrivacyItem(Action.deny, getUniqueOrder());
		pi.setType(Type.jid);
		pi.setValue(jid.toStringBare());
		addItem(pi);
		return pi;
	}

	void addToQuery(Packet query) {
		Packet list = query.addChild("list", null);
		fillListPacket(list);
	}

	public void commit() {
		this.privacyListsPlugin.sendPrivacyList(this);
	}

	private void fillListPacket(final Packet list) {
		list.setAttribute("name", name);

		for (PrivacyItem pi : this.items) {
			final Packet item = list.addChild("item", null);
			if (pi.getType() != null)
				item.setAttribute("type", pi.getType().name());
			if (pi.getValue() != null)
				item.setAttribute("value", pi.getValue());

			item.setAttribute("action", pi.getAction().name());
			item.setAttribute("order", String.valueOf(pi.getOrder()));

			for (Kind kind : pi.getStanzaKind()) {
				item.addChild(kind.name().replace('_', '-'), null);
			}

		}
	}

	public Packet getAsPacket() {
		Packet list = new PacketImp("list");
		fillListPacket(list);
		return list;
	}

	public List<PrivacyItem> getItems() {
		return items;
	}

	public String getName() {
		return name;
	}

	private int getUniqueOrder() {
		int x = this.items.size() + 1;
		while (orderExists(x)) {
			x++;
		}
		return x;
	}

	private boolean orderExists(int order) {
		for (PrivacyItem item : this.items) {
			if (item.getOrder() == order)
				return true;
		}
		return false;
	}

	public void removeRule(PrivacyItem privacyList) {
		this.items.remove(privacyList);
	}

}
