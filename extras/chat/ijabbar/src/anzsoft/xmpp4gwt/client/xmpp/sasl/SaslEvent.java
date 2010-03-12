package anzsoft.xmpp4gwt.client.xmpp.sasl;

import anzsoft.xmpp4gwt.client.events.Event;

public class SaslEvent extends Event {

	private final String cause;

	private final SaslMechanism mechanism;

	public SaslEvent(SaslMechanism mechanism, String cause) {
		this.mechanism = mechanism;
		this.cause = cause;
	}

	public String getCause() {
		return cause;
	}

	public SaslMechanism getMechanism() {
		return mechanism;
	}
}
