package anzsoft.xmpp4gwt.client.xmpp.xeps.jabberSearch;

import anzsoft.xmpp4gwt.client.Plugin;
import anzsoft.xmpp4gwt.client.PluginState;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.citeria.Criteria;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.stanzas.IQ;

public class JabberSearchPlugin implements Plugin {

	private final Session session;

	public JabberSearchPlugin(Session session) {
		this.session = session;
	}

	public Criteria getCriteria() {
		return null;
	}

	public PluginState getStatus() {
		return null;
	}

	public boolean process(Packet element) {
		return false;
	}

	public void reset() {
	}

	public void search(final String first, final String last,
			final String nick, final String email,
			final JabberSearchResponseHandler handler) {
		final IQ iq = new IQ(IQ.Type.set);
		iq.setAttribute("id", Session.nextId());

		Packet query = iq.addChild("query", "jabber:iq:search");

		if (first != null) {
			query.addChild("first", null).setCData(first);
		}
		if (last != null) {
			query.addChild("last", null).setCData(last);
		}
		if (nick != null) {
			query.addChild("nick", null).setCData(nick);
		}
		if (email != null) {
			query.addChild("email", null).setCData(email);
		}

		this.session.addResponseHandler(iq, handler);
	}

}
