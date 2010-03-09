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

import com.google.gwt.json.client.JSONObject;
import com.google.gwt.json.client.JSONParser;
import com.google.gwt.json.client.JSONString;
import com.google.gwt.user.client.Cookies;

public class User {

	private final static String STORAGE_DOMAIN = "0";
	private final static String STORAGE_PRIORITY = "1";
	private final static String STORAGE_RESOURCE = "2";
	private final static String STORAGE_USERNAME = "3";

	private String domainname;;

	private String password;

	private int priority;

	private String resource;

	private String username;

	private static final String COOKIENAME = "ijabuser";

	public User() {
	}

	/**
	 * @param username
	 * @param domainname
	 * @param password
	 * @param resource
	 * @param priority
	 */
	public User(String username, String domainname, String password,
			String resource, int priority) {
		super();
		this.username = username;
		this.domainname = domainname;
		this.password = password;
		this.resource = resource;
		this.priority = priority;
	}

	/**
	 * @return the domainname
	 */
	public String getDomainname() {
		return domainname;
	}

	/**
	 * @return the password
	 */
	public String getPassword() {
		return password;
	}

	/**
	 * @return the priority
	 */
	public int getPriority() {
		return priority;
	}

	/**
	 * @return the resource
	 */
	public String getResource() {
		return resource;
	}

	/**
	 * @return the username
	 */
	public String getUsername() {
		return username;
	}

	public void reset() {
		Cookies.removeCookie(COOKIENAME);
		password = "";
		priority = 0;
		domainname = "";
		username = "";
		resource = "";
	}

	/**
	 * @param domainname
	 *            the domainname to set
	 */
	public void setDomainname(String domainname) {
		this.domainname = domainname;
	}

	/**
	 * @param password
	 *            the password to set
	 */
	public void setPassword(String password) {
		this.password = password;
	}

	/**
	 * @param priority
	 *            the priority to set
	 */
	public void setPriority(int priority) {
		this.priority = priority;
	}

	/**
	 * @param resource
	 *            the resource to set
	 */
	public void setResource(String resource) {
		this.resource = resource;
	}

	/**
	 * @param username
	 *            the username to set
	 */
	public void setUsername(String username) {
		this.username = username;
	}

	public boolean suspend() {
		JSONObject jUser = new JSONObject();
		if (domainname == null || username == null)
			return false;

		jUser.put(STORAGE_DOMAIN, new JSONString(domainname));
		//jUser.put("password", new JSONString(password)); //It's uneeded, and not safe
		String strPriority = String.valueOf(priority);
		if (strPriority != null)
			jUser.put(STORAGE_PRIORITY,
					new JSONString(String.valueOf(priority)));
		jUser.put(STORAGE_RESOURCE, new JSONString(resource));
		jUser.put(STORAGE_USERNAME, new JSONString(username));

		Cookies.setCookie(COOKIENAME, jUser.toString(), null, null, "/", false);
		return true;
	}

	public boolean resume() {
		String cookie = Cookies.getCookie(COOKIENAME);
		if (cookie == null || cookie.length() == 0)
			return false;
		JSONObject jUser = JSONParser.parse(cookie).isObject();
		if (jUser == null)
			return false;

		this.username = jUser.get(STORAGE_USERNAME).isString().stringValue();
		this.domainname = jUser.get(STORAGE_DOMAIN).isString().stringValue();
		//this.password = jUser.get("password").isString().stringValue();  
		//jUser.put("priority", new JSONString(String.valueOf(priority)));
		this.resource = jUser.get(STORAGE_RESOURCE).isString().stringValue();
		this.priority = Integer.parseInt(jUser.get(STORAGE_PRIORITY).isString()
				.stringValue());
		Cookies.removeCookie(COOKIENAME);
		if (username.length() == 0 || domainname.length() == 0)
			return false;
		return true;
	}

	public String getStorageID() {
		return (username + "at" + domainname).replace(".", "dot");
	}

}
