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
package anzsoft.xmpp4gwt.client.xmpp.sasl;

import anzsoft.xmpp4gwt.client.Base64;
import anzsoft.xmpp4gwt.client.User;

import com.google.gwt.core.client.GWT;

public class PlainMechanism implements SaslMechanism {

	private static final String NULL = String.valueOf((char) 0);

	private User user;

	public PlainMechanism(User user) {
		this.user = user;
	}

	public String evaluateChallenge(String input) {
		if (input == null) {
			String lreq = NULL + user.getUsername() + NULL + user.getPassword();
			GWT.log("Login data: " + user.getUsername() + ":"
					+ user.getPassword(), null);
			//String lreq = user.getUsername()+"@"+user.getDomainname()+NULL+user.getUsername()+NULL+user.getPassword();

			String base64 = Base64.encode(lreq);
			return base64;
		}
		return null;
	}

	public Status getStatus() {
		return null;
	}

	public String getStatusMessage() {
		return null;
	}

	public boolean isComplete() {
		return false;
	}

	public String name() {
		return "PLAIN";
	}

}
