package anzsoft.xmpp4gwt.client.xmpp;

import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.events.IQEvent;
import anzsoft.xmpp4gwt.client.stanzas.IQ;

public class ResourceBindEvenet extends IQEvent {

	private final JID bindedJid;

	public ResourceBindEvenet(IQ iq, JID new_jid) {
		super(iq);
		this.bindedJid = new_jid;
	}

	public JID getBindedJid() {
		return bindedJid;
	}

}
