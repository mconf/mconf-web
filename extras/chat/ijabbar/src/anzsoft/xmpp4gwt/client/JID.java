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
package anzsoft.xmpp4gwt.client;

public class JID {

	private static final String REGEXP_DOMAIN = "^((([a-zA-Z0-9\\-])+(\\.)?))+$";

	private static final String REGEXP_NODE = "^([a-zA-Z0-9_\\.\\-]*)$";

	private static final String REGEXP_RESOURCE = "^([a-zA-Z0-9_\\.\\-]*)$";

	public static JID fromString(String jid) {
		String node = null;
		String domain;
		String resource = null;

		if (jid == null) {
			return null;
		}

		int indexOfAt = jid.indexOf('@');
		if (indexOfAt > 0) {
			node = jid.substring(0, indexOfAt);
			jid = jid.substring(indexOfAt + 1);
		}
		int indexOfSlash = jid.indexOf('/');
		if (indexOfSlash > 0) {
			resource = jid.substring(indexOfSlash + 1);
			jid = jid.substring(0, indexOfSlash);
		}
		domain = jid;
		return new JID(node, domain, resource);

	}

	private String asString;

	private String domain;

	private String node;

	private String resource;

	public JID(String node, String domain, String resource) {
		this.node = node;
		this.domain = domain;
		this.resource = resource;
		this.asString = intToString();
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		final JID other = (JID) obj;

		return toString().equals(other.toString());
	}

	public JID getBareJID() {
		return new JID(node, domain, null);
	}

	/**
	 * @return the domain
	 */
	public String getDomain() {
		return domain;
	}

	/**
	 * @return the node
	 */
	public String getNode() {
		return node;
	}

	/**
	 * @return the resource
	 */
	public String getResource() {
		return resource;
	}

	@Override
	public int hashCode() {
		return toString().hashCode();
	}

	private String intToString() {
		String a = node != null ? node + "@" : "";
		String c = resource != null ? "/" + resource : "";
		return a + domain + c;
	}

	public boolean isValid() {
		boolean result = true;
		result = result && domain.matches(REGEXP_DOMAIN);
		result = result && (node == null || node.matches(REGEXP_NODE));
		result = result
				&& (resource == null || resource.matches(REGEXP_RESOURCE));
		return result;
	}

	/**
	 * @param domain
	 *            the domain to set
	 */
	public void setDomain(String domain) {
		this.domain = domain;
		this.asString = intToString();
	}

	/**
	 * @param node
	 *            the node to set
	 */
	public void setNode(String node) {
		this.node = node;
		this.asString = intToString();
	}

	/**
	 * @param resource
	 *            the resource to set
	 */
	public void setResource(String resource) {
		this.resource = resource;
		this.asString = intToString();
	}

	@Override
	public String toString() {
		return this.asString;
	}

	public String toStringBare() {
		String a = node != null ? node + "@" : "";
		return a + domain;
	}

}
