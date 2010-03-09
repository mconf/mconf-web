package anzsoft.xmpp4gwt.client.xmpp;

import anzsoft.xmpp4gwt.client.Plugin;
import anzsoft.xmpp4gwt.client.PluginState;
import anzsoft.xmpp4gwt.client.citeria.Criteria;
import anzsoft.xmpp4gwt.client.citeria.ElementCriteria;
import anzsoft.xmpp4gwt.client.packet.Packet;

public class StreamFeaturesPlugin implements Plugin {

	private final Criteria CRIT = ElementCriteria.name("stream:features");

	private PluginState state = PluginState.NONE;

	public Criteria getCriteria() {
		return CRIT;
	}

	public PluginState getStatus() {
		return null;
	}

	public boolean process(Packet stanza) {
		setState(PluginState.SUCCESS);
		return false;
	}

	public void reset() {
		setState(PluginState.NONE);
	}

	public void setState(PluginState state) {
		this.state = state;
	}

	public PluginState getState() {
		return state;
	}

}
