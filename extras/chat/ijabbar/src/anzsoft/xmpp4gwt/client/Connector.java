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

import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.stanzas.IQ;

public interface Connector {

	public static enum BoshErrorCondition {
		/**
		 * The format of an HTTP header or binding element received from the
		 * client is unacceptable (e.g., syntax error), or Script Syntax is not
		 * supported.
		 */
		bad_request, /**
						 * The target domain specified in the 'to' attribute or the
						 * target host or port specified in the 'route' attribute is no longer
						 * serviced by the connection manager.
						 */
		host_gone, /**
					 * The target domain specified in the 'to' attribute or the
					 * target host or port specified in the 'route' attribute is unknown to
					 * the connection manager.
					 */
		host_unknown, /**
						 * The initialization element lacks a 'to' or 'route'
						 * attribute (or the attribute has no value) but the connection manager
						 * requires one.
						 */
		improper_addressing, /**
								 * The connection manager has experienced an
								 * internal error that prevents it from servicing the request.
								 */
		internal_server_error, /**
								 * (1) 'sid' is not valid, (2) 'stream' is not
								 * valid, (3) 'rid' is larger than the upper limit of the expected
								 * window, (4) connection manager is unable to resend response, (5)
								 * 'key' sequence is invalid
								 */
		item_not_found, /**
						 * Another request being processed at the same time as
						 * this request caused the session to terminate.
						 */
		other_request, /**
						 * The client has broken the session rules (polling too
						 * frequently, requesting too frequently, too many simultaneous
						 * requests).
						 */
		policy_violation, /**
							 * The connection manager was unable to connect to, or
							 * unable to connect securely to, or has lost its connection to, the
							 * server.
							 */
		remote_connection_failed, /**
									 * Encapsulates an error in the protocol being
									 * transported.
									 */
		remote_stream_error, /**
								 * The connection manager does not operate at this
								 * URI (e.g., the connection manager accepts only SSL or TLS connections
								 * at some https: URI rather than the http: URI requested by the
								 * client). The client may try POSTing to the URI in the content of the
								 * <uri/> child element.
								 */
		see_other_uri, /**
						 * The connection manager is being shut down. All active
						 * HTTP sessions are being terminated. No new sessions can be created.
						 */
		system_shutdown, /**
							 * The error is not one of those defined herein; the
							 * connection manager SHOULD include application-specific information in
							 * the content of the <body/> wrapper.
							 */
		undefined_condition
	}

	void addListener(ConnectorListener listener);

	public boolean suspend();

	public boolean resume();

	void connect();

	void disconnect(Packet packetToSend);

	public boolean isCacheAvailable();

	boolean isConnected();

	public boolean isDisconnected();

	void removeListener(ConnectorListener listener);

	void reset();

	void restartStream(IQ iq);

	void send(Packet stanza);

	void setDomain(String domainname);

	void setHost(String host);

	void setPort(int port);

	void setHttpBase(String url);

	void setCrossDomainHttpBase(String url);

}
