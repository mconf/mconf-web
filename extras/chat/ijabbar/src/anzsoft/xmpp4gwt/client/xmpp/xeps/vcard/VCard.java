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

public class VCard {

	private String country;

	private JID jid;

	private String locality;

	private String name;

	private String nameFamily;

	private String nameGiven;

	private String nameMiddle;

	private String nickname;

	private String photoFileName;

	private String title;

	public String getCountry() {
		return country;
	}

	public JID getJid() {
		return jid;
	}

	public String getLocality() {
		return locality;
	}

	public String getName() {
		return name;
	}

	public String getNameFamily() {
		return nameFamily;
	}

	public String getNameGiven() {
		return nameGiven;
	}

	public String getNameMiddle() {
		return nameMiddle;
	}

	public String getNickname() {
		return nickname;
	}

	/**
	 * Internal Tigase extension.
	 * 
	 * @return
	 */
	public String getPhotoFileName() {
		return photoFileName;
	}

	public String getTitle() {
		return title;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	public void setJid(JID jid) {
		this.jid = jid;
	}

	public void setLocality(String locality) {
		this.locality = locality;
	}

	public void setName(String name) {
		this.name = name;
	}

	public void setNameFamily(String nameFamily) {
		this.nameFamily = nameFamily;
	}

	public void setNameGiven(String nameGiven) {
		this.nameGiven = nameGiven;
	}

	public void setNameMiddle(String nameMiddle) {
		this.nameMiddle = nameMiddle;
	}

	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

	public void setPhotoFileName(String photoFileName) {
		this.photoFileName = photoFileName;
	}

	public void setTitle(String title) {
		this.title = title;
	}

}
