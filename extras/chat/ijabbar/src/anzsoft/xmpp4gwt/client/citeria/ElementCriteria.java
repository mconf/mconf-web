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
package anzsoft.xmpp4gwt.client.citeria;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map.Entry;

import anzsoft.xmpp4gwt.client.packet.Packet;

public class ElementCriteria implements Criteria {

	public static final ElementCriteria empty() {
		return new ElementCriteria(null, null, null);
	}

	public static final ElementCriteria name(String name) {
		return new ElementCriteria(name, null, null);
	}

	public static final ElementCriteria name(String name, String xmlns) {
		return new ElementCriteria(name, new String[] { "xmlns" },
				new String[] { xmlns });
	}

	public static final ElementCriteria name(String name, String[] attNames,
			String[] attValues) {
		return new ElementCriteria(name, attNames, attValues);
	}

	public static final ElementCriteria xmlns(String xmlns) {
		return new ElementCriteria(null, new String[] { "xmlns" },
				new String[] { xmlns });
	}

	private HashMap<String, String> attrs = new HashMap<String, String>();

	private String name;

	private Criteria nextCriteria;

	public ElementCriteria(String name, String[] attname, String[] attValue) {
		this.name = name;
		if (attname != null && attValue != null) {
			for (int i = 0; i < attname.length; i++) {
				attrs.put(attname[i], attValue[i]);
			}
		}
	}

	public Criteria add(Criteria criteria) {
		if (this.nextCriteria == null) {
			this.nextCriteria = criteria;
		} else {
			Criteria c = this.nextCriteria;
			c.add(criteria);
		}
		return this;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see tigase.criteria.Criteria#match(tigase.xml.Element)
	 */
	public boolean match(Packet element) {
		if (name != null && !name.equals(element.getName())) {
			return false;
		}
		boolean result = true;
		Iterator<Entry<String, String>> attrIterator = this.attrs.entrySet()
				.iterator();
		while (attrIterator.hasNext()) {
			Entry<String, String> entry = attrIterator.next();

			String at = element.getAtribute(entry.getKey().toString());
			if (at != null) {
				if (at == null || !at.equals(entry.getValue())) {
					result = false;
					break;
				}
			}
		}

		if (this.nextCriteria != null) {
			final List<? extends Packet> children = element.getChildren();
			boolean subres = false;
			if (children != null) {
				for (Packet sub : children) {
					if (this.nextCriteria.match(sub)) {
						subres = true;
						break;
					}
				}
			}
			result &= subres;
		}

		return result;
	}
}
