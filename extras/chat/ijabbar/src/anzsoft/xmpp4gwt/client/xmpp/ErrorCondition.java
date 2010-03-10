/*
 * tigase-xmpp4gwt
 * Copyright (C) 2007-2008 "Bartosz Małkowski" <bmalkow@tigase.org>
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

public enum ErrorCondition {
	/**
	 * the sender has sent XML that is malformed or that cannot be processed
	 * (e.g., an IQ stanza that includes an unrecognized value of the 'type'
	 * attribute); the associated error type SHOULD be "modify".
	 */
	bad_request, /**
					 * access cannot be granted because an existing resource or
					 * session exists with the same name or address; the associated error type
					 * SHOULD be "cancel".
					 */
	conflict, /**
				 * the feature requested is not implemented by the recipient or
				 * server and therefore cannot be processed; the associated error type
				 * SHOULD be "cancel".
				 */
	feature_not_implemented, /**
								 * the requesting entity does not possess the
								 * required permissions to perform the action; the associated error type
								 * SHOULD be "auth".
								 */
	forbidden, /**
				 * the recipient or server can no longer be contacted at this
				 * address (the error stanza MAY contain a new address in the XML character
				 * data of the <gone/> element); the associated error type SHOULD be
				 * "modify".
				 */
	gone, /**
			 * the server could not process the stanza because of a
			 * misconfiguration or an otherwise-undefined internal server error; the
			 * associated error type SHOULD be "wait".
			 */
	internal_server_error, /**
							 * the addressed JID or item requested cannot be
							 * found; the associated error type SHOULD be "cancel".
							 */
	item_not_found, /**
					 * the sending entity has provided or communicated an XMPP
					 * address (e.g., a value of the 'to' attribute) or aspect thereof (e.g., a
					 * resource identifier) that does not adhere to the syntax defined in
					 * Addressing Scheme (Addressing Scheme); the associated error type SHOULD
					 * be "modify".
					 */
	jid_malformed, /**
					 * the recipient or server understands the request but is
					 * refusing to process it because it does not meet criteria defined by the
					 * recipient or server (e.g., a local policy regarding acceptable words in
					 * messages); the associated error type SHOULD be "modify".
					 */
	not_acceptable, /**
					 * the recipient or server does not allow any entity to
					 * perform the action; the associated error type SHOULD be "cancel".
					 */
	not_allowed, /**
					 * the sender must provide proper credentials before being
					 * allowed to perform the action, or has provided improper credentials; the
					 * associated error type SHOULD be "auth".
					 */
	not_authorized, /**
					 * the requesting entity is not authorized to access the
					 * requested service because payment is required; the associated error type
					 * SHOULD be "auth".
					 */
	payment_required, /**
						 * the intended recipient is temporarily unavailable; the
						 * associated error type SHOULD be "wait" (note: an application MUST NOT
						 * return this error if doing so would provide information about the
						 * intended recipient's network availability to an entity that is not
						 * authorized to know such information).
						 */
	recipient_unavailable, /**
							 * the recipient or server is redirecting requests
							 * for this information to another entity, usually temporarily (the error
							 * stanza SHOULD contain the alternate address, which MUST be a valid JID,
							 * in the XML character data of the <redirect/> element); the associated
							 * error type SHOULD be "modify".
							 */
	redirect, /**
				 * the requesting entity is not authorized to access the requested
				 * service because registration is required; the associated error type
				 * SHOULD be "auth".
				 */
	registration_required, /**
							 * a remote server or service specified as part or
							 * all of the JID of the intended recipient does not exist; the associated
							 * error type SHOULD be "cancel".
							 */
	remote_server_not_found, /**
								 * a remote server or service specified as part or
								 * all of the JID of the intended recipient (or required to fulfill a
								 * request) could not be contacted within a reasonable amount of time; the
								 * associated error type SHOULD be "wait".
								 */
	remote_server_timeout, /**
							 * the server or recipient lacks the system resources
							 * necessary to service the request; the associated error type SHOULD be
							 * "wait".
							 */
	resource_constraint, /**
							 * the server or recipient does not currently provide
							 * the requested service; the associated error type SHOULD be "cancel".
							 */
	service_unavailable, /**
							 * the requesting entity is not authorized to access
							 * the requested service because a subscription is required; the associated
							 * error type SHOULD be "auth".
							 */
	subscription_required, /**
							 * the error condition is not one of those defined by
							 * the other conditions in this list; any error type may be associated with
							 * this condition, and it SHOULD be used only in conjunction with an
							 * application-specific condition.
							 */
	undefined_condition, /**
							 * the recipient or server understood the request but
							 * was not expecting it at this time (e.g., the request was out of order);
							 * the associated error type SHOULD be "wait".
							 */
	unexpected_request,
	/** For internal use only! */
}