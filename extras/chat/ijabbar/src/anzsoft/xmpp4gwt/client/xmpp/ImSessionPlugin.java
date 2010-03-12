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
package anzsoft.xmpp4gwt.client.xmpp;

import java.util.ArrayList;

import anzsoft.xmpp4gwt.client.Plugin;
import anzsoft.xmpp4gwt.client.PluginState;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.citeria.Criteria;
import anzsoft.xmpp4gwt.client.citeria.ElementCriteria;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.stanzas.IQ;

@Deprecated
public class ImSessionPlugin implements Plugin {

	private Session con;

	private boolean imSessionEstablished = false;

	private final ArrayList<ImSessionListener> listener = new ArrayList<ImSessionListener>();

	private PluginState stage = PluginState.NONE;

	public ImSessionPlugin(Session con) {
		this.con = con;
	}

	public void addListener(ImSessionListener listener) {
		this.listener.add(listener);
	}

	/*
	private void fireSessionEstablished() 
	{
		for (ImSessionListener listener : this.listener) 
		{
			listener.onSessionEstablished();
		}
	}

	private void fireSessionEstablishing() 
	{
		for (ImSessionListener listener : this.listener) 
		{
			listener.onStartSessionEstablishing();
		}
	}

	private void fireSessionEstablishingError() 
	{
		for (ImSessionListener listener : this.listener) 
		{
			listener.onSessionEstablishingError();
		}
	}
	 */

	public Criteria getCriteria() {
		return ElementCriteria
				.name("iq")
				.add(
						ElementCriteria
								.name(
										"session",
										new String[] { "xmlns" },
										new String[] { "urn:ietf:params:xml:ns:xmpp-session" }));
	}

	public PluginState getStatus() {
		return stage;
	}

	/**
	 * @return the imSessionEstablished
	 */
	public boolean isImSessionEstablished() {
		return imSessionEstablished;
	}

	public boolean process(Packet iq) {
		if ("result".equals(iq.getAtribute("type"))) {
			stage = PluginState.SUCCESS;
		} else {
			stage = PluginState.ERROR;
		}
		return true;
	}

	public void removeListener(ImSessionListener listener) {
		this.listener.remove(listener);
	}

	public void requestImSession() {
		stage = PluginState.IN_PROGRESS;
		IQ iq = new IQ(IQ.Type.set);
		iq.setAttribute("id", "" + Session.nextId());
		iq.setAttribute("xmlns", "jabber:client");

		iq.addChild("session", "urn:ietf:params:xml:ns:xmpp-session");
		con.send(iq);
		/*
		fireSessionEstablishing();
		stage = PluginState.IN_PROGRESS;
		IQ iq = new IQ(IQ.Type.set);
		iq.setId(Session.nextId());
		iq.setAttribute("xmlns", "jabber:client");

		Packet session = iq.addChild("session", null);
		session.setAttribute("xmlns", "urn:ietf:params:xml:ns:xmpp-session");

		con.addResponseHandler(iq, new ResponseHandler() 
		{

			public void onError(IQ iq, ErrorType errorType, ErrorCondition errorCondition, String text) 
			{
				stage = PluginState.SUCCESS;
				imSessionEstablished = false;
				fireSessionEstablishingError();
			}

			public void onResult(IQ iq) 
			{
				stage = PluginState.SUCCESS;
				imSessionEstablished = true;
				fireSessionEstablished();
			}
		});
		 */

	}

	public void reset() {
		this.imSessionEstablished = false;
		this.stage = PluginState.NONE;
	}

	public void setInitializedDirty() {
		this.imSessionEstablished = true;
		this.stage = PluginState.SUCCESS;
	}
}
