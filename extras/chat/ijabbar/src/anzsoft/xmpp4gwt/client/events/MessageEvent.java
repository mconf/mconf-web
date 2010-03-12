package anzsoft.xmpp4gwt.client.events;

import anzsoft.xmpp4gwt.client.stanzas.Message;

public class MessageEvent extends Event {
	protected final Message message;

	public MessageEvent(Message message) {
		this.message = message;
	}

	public Message getMessage() {
		return message;
	}
}
