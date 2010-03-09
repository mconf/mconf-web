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

import java.util.List;

import anzsoft.xmpp4gwt.client.Connector.BoshErrorCondition;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.xmpp.ErrorCondition;

import com.google.gwt.http.client.Response;

public interface ConnectorListener {

	void onBodyReceive(Response code, String body);

	void onBodySend(String body);

	void onBoshError(ErrorCondition xmppErrorCondition,
			BoshErrorCondition boshErrorCondition, String message);

	void onBoshTerminate(Connector con, BoshErrorCondition boshErrorCondition);

	void onConnect(Connector con);

	void onStanzaReceived(List<? extends Packet> nodes);

}
