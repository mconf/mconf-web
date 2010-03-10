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
package anzsoft.xmpp4gwt.client.xmpp.xeps.vcard;

import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.ResponseHandler;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.stanzas.IQ;

public abstract class VCardResponseHandler implements ResponseHandler {

	public final void onResult(IQ iq) {

		JID jid = JID.fromString(iq.getAtribute("from"));

		Packet vcard = iq.getFirstChild("vCard");
		if (vcard == null)
			return;

		VCard result = new VCard();
		result.setJid(jid);
		Packet fn = vcard.getFirstChild("FN");
		Packet n = vcard.getFirstChild("N");
		Packet nickname = vcard.getFirstChild("NICKNAME");
		Packet adr = vcard.getFirstChild("ADR");
		Packet title = vcard.getFirstChild("TITLE");

		Packet photo = vcard.getFirstChild("PHOTO");

		result.setName(fn == null ? null : fn.getCData());
		result.setNickname(nickname == null ? null : nickname.getCData());
		result.setTitle(title == null ? null : title.getCData());

		if (adr != null) {
			Packet ctry = adr.getFirstChild("CTRY");
			Packet locality = adr.getFirstChild("LOCALITY");
			result.setCountry(ctry == null ? null : ctry.getCData());
			result.setLocality(locality == null ? null : locality.getCData());
		}
		if (n != null) {
			Packet family = n.getFirstChild("FAMILY");
			Packet given = n.getFirstChild("GIVEN");
			Packet middle = n.getFirstChild("MIDDLE");

			result.setNameFamily(family == null ? null : family.getCData());
			result.setNameGiven(given == null ? null : given.getCData());
			result.setNameMiddle(middle == null ? null : middle.getCData());
		}

		if (photo != null) {
			Packet filename = photo.getFirstChild("FILENAME");
			result.setPhotoFileName(filename == null ? null : filename
					.getCData());
		}

		onSuccess(result);
	}

	public abstract void onSuccess(final VCard vcard);

}
