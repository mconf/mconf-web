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

import anzsoft.xmpp4gwt.client.packet.Packet;

public class PrivacyItem {

	public static enum Action {
		allow, deny
	}

	public static enum Kind {
		iq, message, presence_in, presence_out
	}

	public static enum Type {
		group, jid, subscription
	}

	private Action action = Action.deny;

	private int order;

	private final Set<Kind> stanzaKind = new HashSet<Kind>();

	private Type type;

	private String value;

	public PrivacyItem(Action action, int order) {
		this.action = action;
		this.order = order;
	}

	PrivacyItem(Packet item) {
		String sOrder = item.getAtribute("order");
		String sAction = item.getAtribute("action");
		String sType = item.getAtribute("type");
		value = item.getAtribute("value");

		if (sOrder != null)
			this.order = Integer.valueOf(sOrder);
		if (sAction != null)
			this.action = Action.valueOf(sAction);
		if (sType != null)
			this.type = Type.valueOf(sType);

		List<? extends Packet> children = item.getChildren();
		if (children != null)
			for (Packet c : children) {
				this.stanzaKind
						.add(Kind.valueOf(c.getName().replace('-', '_')));
			}
	}

	public void addKinds(Kind... kinds) {
		if (kinds != null)
			for (Kind kind : kinds) {
				this.stanzaKind.add(kind);
			}
	}

	public Action getAction() {
		return action;
	}

	public int getOrder() {
		return order;
	}

	public Set<Kind> getStanzaKind() {
		return stanzaKind;
	}

	public Type getType() {
		return type;
	}

	public String getValue() {
		return value;
	}

	public boolean isIq() {
		return stanzaKind.size() == 0 || stanzaKind.contains(Kind.iq);
	}

	public boolean isMessage() {
		return stanzaKind.size() == 0 || stanzaKind.contains(Kind.message);
	}

	public boolean isPresenceIn() {
		return stanzaKind.size() == 0 || stanzaKind.contains(Kind.presence_in);
	}

	public boolean isPresenceOut() {
		return stanzaKind.size() == 0 || stanzaKind.contains(Kind.presence_out);
	}

	public void removeKinds(Kind... kinds) {
		if (kinds != null)
			for (Kind kind : kinds) {
				this.stanzaKind.remove(kind);
			}
	}

	public void setAction(Action action) {
		this.action = action;
	}

	public void setAllKinds() {
		addKinds(Kind.values());
	}

	public void setKinds(Kind... kinds) {
		this.stanzaKind.clear();
		addKinds(kinds);
	}

	public void setOrder(int order) {
		this.order = order;
	}

	public void setType(Type type) {
		this.type = type;
	}

	public void setValue(String value) {
		this.value = value;
	}
}
