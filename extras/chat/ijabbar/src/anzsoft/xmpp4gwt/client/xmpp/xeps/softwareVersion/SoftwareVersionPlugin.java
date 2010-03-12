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
package anzsoft.xmpp4gwt.client.xmpp.xeps.softwareVersion;

import anzsoft.xmpp4gwt.client.Plugin;
import anzsoft.xmpp4gwt.client.PluginState;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.citeria.Criteria;
import anzsoft.xmpp4gwt.client.citeria.ElementCriteria;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.stanzas.IQ;

public class SoftwareVersionPlugin implements Plugin {

	private String name = "ijab";

	private String os = null;

	private Session session;

	private String version = "0.2.0";

	public SoftwareVersionPlugin(Session session) {
		this.session = session;
	}

	public Criteria getCriteria() {
		return ElementCriteria.name("iq", new String[] { "type" },
				new String[] { "get" }).add(
				ElementCriteria.name("query", "jabber:iq:version"));
	}

	public String getName() {
		return name;
	}

	public String getOs() {
		return os;
	}

	public PluginState getStatus() {
		return null;
	}

	public String getVersion() {
		return version;
	}

	public boolean process(Packet element) {
		final IQ iq = new IQ(element);
		final IQ result = iq.makeResult();

		Packet query = result.addChild("query", "jabber:iq:version");
		Packet name = query.addChild("name", null);
		name.setCData(this.name);
		Packet version = query.addChild("version", null);
		version.setCData(this.version);

		if (os != null) {
			Packet os = query.addChild("os", null);
			os.setCData(this.os);
		}

		session.send(result);
		return true;
	}

	public void reset() {
	}

	public void setName(String name) {
		this.name = name;
	}

	public void setOs(String os) {
		this.os = os;
	}

	public void setVersion(String version) {
		this.version = version;
	}

}
