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

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.packet.PacketImp;
import anzsoft.xmpp4gwt.client.packet.PacketREXMLImpl;
import anzsoft.xmpp4gwt.client.packet.PacketRenderer;
import anzsoft.xmpp4gwt.client.packet.REXML;
import anzsoft.xmpp4gwt.client.stanzas.IQ;
import anzsoft.xmpp4gwt.client.xmpp.ErrorCondition;

import com.google.gwt.core.client.GWT;
import com.google.gwt.http.client.Request;
import com.google.gwt.http.client.RequestBuilder;
import com.google.gwt.http.client.RequestCallback;
import com.google.gwt.http.client.RequestTimeoutException;
import com.google.gwt.http.client.Response;
import com.google.gwt.user.client.Command;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.DeferredCommand;

public class Bosh2Connector implements Connector {

	enum State {
		connected, connecting, disconnected
	}

	protected static final int MAX_ERRORS = 3;

	public static ErrorCondition getCondition(String name, int httpResult) {
		ErrorCondition result = null;
		if (name != null) {
			try {
				result = ErrorCondition.valueOf(name.replaceAll("-", "_"));
			} catch (Exception e) {
				result = null;
			}
		}
		if (result == null && httpResult != 200) {
			switch (httpResult) {
			case 400:
				result = ErrorCondition.bad_request;
				break;
			case 403:
				result = ErrorCondition.forbidden;
				break;
			case 404:
				result = ErrorCondition.item_not_found;
				break;
			case 405:
				result = ErrorCondition.not_allowed;
				break;
			default:
				result = ErrorCondition.undefined_condition;
				break;
			}
		}
		return result == null ? ErrorCondition.undefined_condition : result;
	}

	private Map<Request, String> activeRequests = new HashMap<Request, String>();

	private RequestBuilder builder;

	//added by zhongfanglin@antapp.com to support javascript cross domain
	private ScriptSyntaxRequestBuilder scriptBuilder;
	private boolean crossDomain = false;
	private ScriptSyntaxRequestCallback scriptHandler;
	private Map<String, String> activeScriptRequests = new HashMap<String, String>();

	private int defaultTimeout = 30;

	private int errorCounter = 0;

	private String domain;
	private String host = null;
	int port = 5222;

	private List<ConnectorListener> listeners = new ArrayList<ConnectorListener>();

	private PacketRenderer renderer = new PacketRenderer() {
		public String render(Packet packet) {
			return packet.getAsString();
		}
	};

	private long rid;

	private String sid;

	private RequestCallback standardHandler;

	private State state = State.disconnected;

	private User user;

	public Bosh2Connector(final User user) {
		this.setUser(user);
		standardHandler = new RequestCallback() {

			public void onError(Request request, Throwable exception) {
				final String lastSendedBody = activeRequests.remove(request);
				if (exception instanceof RequestTimeoutException) {
					GWT.log("Request too old. Trying again.", null);
					DeferredCommand.addCommand(new Command() {
						public void execute() {
							if (lastSendedBody != null
									&& state == State.connected && sid != null
									&& sid.length() > 0)
								send(lastSendedBody, standardHandler);
							else
								continuousConnection(null);
						}
					});
				} else if (exception.getMessage().startsWith(
						"Unable to read XmlHttpRequest.status;")) {
					GWT.log("Lost request. Ignored. Resend.", null);
					if (lastSendedBody != null) {
						DeferredCommand.addCommand(new Command() {
							public void execute() {
								if (state == State.connected && sid != null
										&& sid.length() > 0) {
									send(lastSendedBody, standardHandler);
								}
							}
						});
					}
				} else {
					state = State.disconnected;
					GWT.log("Connection error", exception);
					exception.printStackTrace();
					fireEventError(BoshErrorCondition.remote_connection_failed,
							null, "Response error: " + exception.getMessage());
				}
			}

			public void onResponseReceived(Request request, Response response) {
				if (state == State.disconnected)
					return;

				final String httpResponse = response.getText();
				final int httpStatusCode = response.getStatusCode();
				final String lastSendedBody = activeRequests.remove(request);

				System.out.println(" IN (" + httpStatusCode + "): "
						+ httpResponse);
				fireOnBodyReceive(response, httpResponse);

				final Packet body = parse2(response.getText().replaceAll(
						"&semi;", ";"));

				final String type = body == null ? null : body
						.getAtribute("type");
				final String receivedSid = body == null ? null : body
						.getAtribute("sid");
				String $tmp = body == null ? null : body.getAtribute("rid");
				//final Long rid = $tmp == null ? null : Long.valueOf($tmp);
				final String ack = body == null ? null : body
						.getAtribute("ack");
				$tmp = body == null ? null : body.getAtribute("condition");
				if ($tmp != null)
					$tmp = $tmp.replace("-", "_");
				final BoshErrorCondition boshCondition = $tmp == null ? null
						: BoshErrorCondition.valueOf($tmp);

				final String wait = body == null ? null : body
						.getAtribute("wait");
				final String inactivity = body == null ? null : body
						.getAtribute("inactivity");
				if (wait != null && inactivity != null) {
					try {
						int w = Integer.parseInt(wait);
						int i = Integer.parseInt(inactivity);
						int t = (w + i / 2) * 1000;
						builder.setTimeoutMillis(t);
						GWT.log("New timeout: " + t + "ms", null);
					} catch (Exception e) {
						GWT.log("Error in wait and inactivity attributes", e);
					}
				}

				if (httpStatusCode != 200 || body == null || type != null
						&& ("terminate".equals(type) || "error".equals(type))) {
					GWT.log("ERROR (" + httpStatusCode + "): " + httpResponse,
							null);
					ErrorCondition condition = body == null ? ErrorCondition.bad_request
							: ErrorCondition.undefined_condition;
					String msg = null;
					Packet error = body == null ? null : body
							.getFirstChild("error");
					if (error != null) {
						for (Packet c : error.getChildren()) {
							String xmlns = c.getAtribute("xmlns");
							if ("text".equals(c.getName())) {
								msg = c.getCData();
								break;
							} else if (xmlns != null
									&& "urn:ietf:params:xml:ns:xmpp-stanzas"
											.equals(xmlns)) {
								condition = getCondition(c.getName(),
										httpStatusCode);
							}
						}
					}

					if (condition == ErrorCondition.item_not_found) {
						state = State.disconnected;
						fireEventError(boshCondition, condition, msg);
					} else if (errorCounter < MAX_ERRORS) {
						errorCounter++;
						send(lastSendedBody, standardHandler);
					} else if (type != null && "terminate".equals(type)) {
						GWT.log("Disconnected by server", null);
						state = State.disconnected;
						fireDisconnectByServer(boshCondition, condition, msg);
					} else {
						state = State.disconnected;
						if (msg == null) {
							msg = "[" + httpStatusCode + "] "
									+ condition.name().replace('_', '-');
						}
						fireEventError(boshCondition, condition, msg);
					}
				} else {
					errorCounter = 0;
					if (receivedSid != null && sid != null
							&& !receivedSid.equals(sid)) {
						state = State.disconnected;
						fireEventError(BoshErrorCondition.policy_violation,
								ErrorCondition.unexpected_request,
								"Unexpected session initialisation.");
					} else if (receivedSid != null && sid == null) {
						sid = receivedSid;
						Cookies.setCookie(user.getResource() + "sid", sid,
								null, null, "/", false);
						state = State.connected;
					}

					final List<? extends Packet> children = body.getChildren();
					if (children.size() > 0) {
						fireEventReceiveStanzas(children);
					}
					continuousConnection(ack);
				}
				System.out.println("............sid value is:" + sid);
			}
		};

		//added by zhongfanglin@antapp.com
		scriptHandler = new ScriptSyntaxRequestCallback() {
			public void onError(String callbackID) {
				state = State.disconnected;
				GWT.log("Connection error", null);
				fireEventError(BoshErrorCondition.remote_connection_failed,
						null, "Response error: request timeout or 404!");
			}

			public void onResponseReceived(String callbackID,
					String responseText) {

				if (state == State.disconnected)
					return;

				final String httpResponse = responseText;
				final String lastSendedBody = activeScriptRequests
						.remove(callbackID);

				System.out.println(" IN:" + httpResponse);
				fireOnBodyReceive(null, httpResponse);

				final Packet body = parse2(responseText.replaceAll("&semi;",
						";"));

				final String type = body == null ? null : body
						.getAtribute("type");
				final String receivedSid = body == null ? null : body
						.getAtribute("sid");
				String $tmp = body == null ? null : body.getAtribute("rid");
				//final Long rid = $tmp == null ? null : Long.valueOf($tmp);
				final String ack = body == null ? null : body
						.getAtribute("ack");
				$tmp = body == null ? null : body.getAtribute("condition");
				if ($tmp != null)
					$tmp = $tmp.replace("-", "_");
				final BoshErrorCondition boshCondition = $tmp == null ? null
						: BoshErrorCondition.valueOf($tmp);

				final String wait = body == null ? null : body
						.getAtribute("wait");
				final String inactivity = body == null ? null : body
						.getAtribute("inactivity");
				if (wait != null && inactivity != null) {
					try {
						int w = Integer.parseInt(wait);
						int i = Integer.parseInt(inactivity);
						int t = (w + i / 2) * 1000;
						scriptBuilder.setTimeoutMillis(t);
						GWT.log("New timeout: " + t + "ms", null);
					} catch (Exception e) {
						GWT.log("Error in wait and inactivity attributes", e);
					}
				}

				if (body == null || type != null
						&& ("terminate".equals(type) || "error".equals(type))) {
					GWT.log("ERROR : " + httpResponse, null);
					ErrorCondition condition = body == null ? ErrorCondition.bad_request
							: ErrorCondition.undefined_condition;
					String msg = null;
					Packet error = body == null ? null : body
							.getFirstChild("error");
					if (error != null) {
						for (Packet c : error.getChildren()) {
							String xmlns = c.getAtribute("xmlns");
							if ("text".equals(c.getName())) {
								msg = c.getCData();
								break;
							} else if (xmlns != null
									&& "urn:ietf:params:xml:ns:xmpp-stanzas"
											.equals(xmlns)) {
								condition = getCondition(c.getName(), -1);
							}
						}
					}

					if (condition == ErrorCondition.item_not_found) {
						state = State.disconnected;
						fireEventError(boshCondition, condition, msg);
					} else if (errorCounter < MAX_ERRORS) {
						errorCounter++;
						send(lastSendedBody, scriptHandler);
					} else if (type != null && "terminate".equals(type)) {
						GWT.log("Disconnected by server", null);
						state = State.disconnected;
						fireDisconnectByServer(boshCondition, condition, msg);
					} else {
						state = State.disconnected;
						if (msg == null) {
							msg = condition.name().replace('_', '-');
						}
						fireEventError(boshCondition, condition, msg);
					}
				} else {
					errorCounter = 0;
					if (receivedSid != null && sid != null
							&& !receivedSid.equals(sid)) {
						state = State.disconnected;
						fireEventError(BoshErrorCondition.policy_violation,
								ErrorCondition.unexpected_request,
								"Unexpected session initialisation.");
					} else if (receivedSid != null && sid == null) {
						sid = receivedSid;
						Cookies.setCookie(user.getResource() + "sid", sid,
								null, null, "/", false);
						state = State.connected;
					}

					List<? extends Packet> children = body.getChildren();
					if (children.size() > 0) {
						fireEventReceiveStanzas(children);
					}
					continuousConnection(ack);
				}
			}

		};
		//end added 
	}

	public void addListener(ConnectorListener listener) {
		this.listeners.add(listener);
	}

	public void connect() {
		makeNewRequestBuilder(defaultTimeout + 7);
		this.rid = (long) (Math.random() * 10000000);

		Packet e = new PacketImp("body");
		e.setAttribute("content", "text/xml; charset=utf-8");
		e.setAttribute("hold", "1");
		e.setAttribute("requests", "2");
		e.setAttribute("rid", getNextRid());
		e.setAttribute("to", domain);
		e.setAttribute("ver", "1.6");
		e.setAttribute("cache", "on");
		e.setAttribute("wait", String.valueOf(defaultTimeout));
		e.setAttribute("xmlns", "http://jabber.org/protocol/httpbind");
		e.setAttribute("xmlns:xmpp", "urn:xmpp:xbosh");
		e.setAttribute("secure", "false");
		e.setAttribute("xmpp:version", "1.0");
		if (host != null && !(host.length() == 0)) {
			final String value = "xmpp:" + host + ":" + String.valueOf(port);
			e.setAttribute("route", value);
		}

		state = State.connecting;
		if (crossDomain)
			send(renderer.render(e), scriptHandler);
		else
			send(renderer.render(e), standardHandler);

	}

	private int getActivesRequestCount() {
		if (crossDomain)
			return this.activeScriptRequests.size();
		else
			return this.activeRequests.size();
	}

	public void continuousConnection(String ack) {
		if (state != State.connected || getActivesRequestCount() > 0)
			return;
		Packet e = new PacketImp("body");
		e.setAttribute("xmlns", "http://jabber.org/protocol/httpbind");
		e.setAttribute("rid", getNextRid());
		if (sid != null)
			e.setAttribute("sid", sid);

		if (ack != null) {
			e.setAttribute("ack", ack);
		}

		if (crossDomain)
			send(renderer.render(e), scriptHandler);
		else
			send(renderer.render(e), standardHandler);
	}

	public void disconnect(Packet packetToSend) {
		PacketImp e = new PacketImp("body");
		e.setAttribute("rid", getNextRid());
		if (sid != null)
			e.setAttribute("sid", sid);
		e.setAttribute("to", domain);
		e.setAttribute("type", "terminate");
		e.setAttribute("xmlns", "http://jabber.org/protocol/httpbind");
		e.setAttribute("xmlns:xmpp", "urn:xmpp:xbosh");
		e.setAttribute("secure", "false");
		e.setAttribute("xmpp:version", "1.0");
		if (host != null && !(host.length() == 0)) {
			final String value = "xmpp:" + host + ":" + String.valueOf(port);
			e.setAttribute("route", value);
		}
		if (packetToSend != null) {
			e.addChild(packetToSend);
		}
		if (state == State.connected) {
			if (crossDomain)
				send(renderer.render(e), scriptHandler);
			else
				send(renderer.render(e), standardHandler);
		}
		state = State.disconnected;
		reset();
	}

	private void fireDisconnectByServer(BoshErrorCondition boshCondition,
			ErrorCondition xmppCondition, String msg) {
		for (int i = 0; i < this.listeners.size(); i++) {
			ConnectorListener l = this.listeners.get(i);
			l.onBoshTerminate(this, boshCondition);
		}
	}

	private void fireEventError(BoshErrorCondition boshErrorCondition,
			ErrorCondition xmppErrorCondition, String message) {
		for (int i = 0; i < this.listeners.size(); i++) {
			ConnectorListener l = this.listeners.get(i);
			l.onBoshError(xmppErrorCondition, boshErrorCondition, message);
		}
	}

	private void fireEventReceiveStanzas(List<? extends Packet> nodes) {
		for (int i = 0; i < this.listeners.size(); i++) {
			ConnectorListener l = this.listeners.get(i);
			l.onStanzaReceived(nodes);
		}
	}

	private void fireOnBodyReceive(Response response, String body) {
		for (int i = 0; i < this.listeners.size(); i++) {
			ConnectorListener l = this.listeners.get(i);
			l.onBodyReceive(response, body);
		}
	}

	private void fireOnBodySend(String body) {
		for (int i = 0; i < this.listeners.size(); i++) {
			ConnectorListener l = this.listeners.get(i);
			l.onBodySend(body);
		}
	}

	private String getNextRid() {
		this.rid++;
		String tmp = String.valueOf(this.rid);
		final Date expire = new Date(39 * 1000 + (new Date()).getTime());
		Cookies.setCookie(user.getResource() + "rid", tmp, expire, null, "/",
				false);
		return tmp;
	}

	public boolean isCacheAvailable() {
		return Cookies.getCookie(user.getResource() + "sid") != null
				&& Cookies.getCookie(user.getResource() + "rid") != null;
	}

	public boolean isConnected() {
		return state == State.connected;
	}

	public boolean isDisconnected() {
		return state == State.disconnected;
	}

	private void makeNewRequestBuilder(int timeOut) {
		if (crossDomain)
			scriptBuilder.setTimeoutMillis(timeOut * 2000);
		else
			builder.setTimeoutMillis(timeOut * 2000);
		GWT.log("timeout==" + (timeOut * 2000), null);
	}

	private Packet parse2(final String s) {
		if (s == null || s.length() == 0) {
			return null;
		} else {
			try {
				REXML xml = new REXML(s);
				return new PacketREXMLImpl(xml.getJSO());
			} catch (Exception e) {
				GWT.log("Parsing error (\"" + s + "\")", e);
				return null;
			}
		}
	}

	/*
	private Packet parse(String s) 
	{
		if (s == null || s.length() == 0) 
		{
			return null;
		}
		else
		{
			try 
			{
				Element element = XMLParser.parse(s).getDocumentElement();
				return new PacketGwtImpl(element);
			} catch (Exception e) 
			{
				GWT.log("Parsing error (\"" + s + "\")", e);
				return null;
			}
		}
	}
	 */

	public void removeListener(ConnectorListener listener) {
		this.listeners.remove(listener);
	}

	public void reset() {
		state = State.disconnected;
		Cookies.removeCookie(user.getResource() + "sid");
		Cookies.removeCookie(user.getResource() + "rid");
		this.errorCounter = 0;
		this.activeRequests.clear();
		this.activeScriptRequests.clear();
		this.sid = null;
		this.rid = (long) (Math.random() * 10000000);
	}

	public void restartStream(IQ iq) {
		PacketImp e = new PacketImp("body");
		if (sid != null)
			e.setAttribute("sid", sid);
		e.setAttribute("rid", getNextRid());
		e.setAttribute("to", domain);
		e.setAttribute("xmpp:restart", "true");
		e.setAttribute("xmlns", "http://jabber.org/protocol/httpbind");
		e.setAttribute("xmlns:xmpp", "urn:xmpp:xbosh");
		if (iq != null)
			e.addChild(iq);
		if (crossDomain)
			send(renderer.render(e), scriptHandler);
		else
			send(renderer.render(e), standardHandler);
	}

	public void send(Packet stanza) {
		PacketImp e = new PacketImp("body");
		e.setAttribute("xmlns", "http://jabber.org/protocol/httpbind");
		e.setAttribute("rid", getNextRid());
		if (sid != null)
			e.setAttribute("sid", sid);

		e.addChild(stanza);

		if (crossDomain)
			send(renderer.render(e), scriptHandler);
		else
			send(renderer.render(e), standardHandler);
	}

	//adde by zhongfanglin@antapp.com
	private void send(String body, ScriptSyntaxRequestCallback callback) {
		System.out.println("OUT (" + this.sid + "): " + body);
		try {
			// ++activeConnections;
			String id = scriptBuilder.sendRequest(body, callback);
			this.activeScriptRequests.put(id, body);
			fireOnBodySend(body);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	//end added

	private void send(String body, RequestCallback callback) {
		// System.out.println("OUT (" + this.sid + ", " + connected + ", " +
		// activeConnections + "): " + body);
		System.out.println("OUT (" + this.sid + "): " + body);
		try {
			// ++activeConnections;
			Request request = builder.sendRequest(body, callback);
			this.activeRequests.put(request, body);
			fireOnBodySend(body);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void sendStanza(String stanza) {
		String r = "<body xmlns='http://jabber.org/protocol/httpbind' rid='"
				+ getNextRid() + "'";
		if (sid != null)
			r += " sid='" + sid + "'";
		r += ">";
		r += stanza;
		r += "</body>";
		if (crossDomain)
			send(r, scriptHandler);
		else
			send(r, standardHandler);
	}

	public void setDomain(String domainname) {
		this.domain = domainname;
	}

	public void setHttpBase(final String boshUrl) {
		if (boshUrl.startsWith("http://") || boshUrl.startsWith("https://")) {
			setCrossDomainHttpBase(boshUrl);
			return;
		}
		builder = new RequestBuilder(RequestBuilder.POST, boshUrl);
		builder.setHeader("Connection", "close");
	}

	public void setCrossDomainHttpBase(final String boshUrl) {
		crossDomain = true;
		scriptBuilder = new ScriptSyntaxRequestBuilder(boshUrl);
	}

	public void setHost(String host) {
		this.host = host;
	}

	public void setPort(int port) {
		this.port = port;
	}

	public void setUser(User user) {
		this.user = user;
	}

	public User getUser() {
		return user;
	}

	public boolean resume() {
		makeNewRequestBuilder(defaultTimeout + 7);
		this.sid = Cookies.getCookie(user.getResource() + "sid");
		try {
			this.rid = Long.parseLong(Cookies.getCookie(user.getResource()
					+ "rid"));
		} catch (Exception e) {
			this.rid = 0;
		}

		if (this.sid == null || this.rid == 0)
			return false;

		this.state = State.connected;

		Packet e0 = new PacketImp("body");
		e0.setAttribute("xmlns", "http://jabber.org/protocol/httpbind");
		e0.setAttribute("sid", sid);
		//e0.setAttribute("rid", ""+this.rid);
		e0.setAttribute("rid", this.getNextRid());

		/*
		Packet e = new PacketImp("body");
		e.setAttribute("xmlns", "http://jabber.org/protocol/httpbind");
		e.setAttribute("rid", getNextRid());
		e.setAttribute("sid", sid);

		e.setAttribute("cache", "get_all");
		 */

		if (crossDomain) {
			send(renderer.render(e0), scriptHandler);
			//send(renderer.render(e),scriptHandler);
		} else {
			send(renderer.render(e0), standardHandler);
			//send(renderer.render(e), standardHandler);
		}

		return true;
	}

	public boolean suspend() {
		Packet e0 = new PacketImp("body");
		e0.setAttribute("pause", "120");
		e0.setAttribute("xmlns", "http://jabber.org/protocol/httpbind");
		e0.setAttribute("sid", sid);
		e0.setAttribute("rid", this.getNextRid());

		if (crossDomain) {
			send(renderer.render(e0), scriptHandler);
			//send(renderer.render(e),scriptHandler);
		} else {
			send(renderer.render(e0), standardHandler);
			//send(renderer.render(e), standardHandler);
		}

		return true;
	}

	public ScriptSyntaxRequestBuilder getScriptSyntaxRquestBuilder() {
		return this.scriptBuilder;
	}

	public boolean isCrossDomain() {
		return this.crossDomain;
	}

}
