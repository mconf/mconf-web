package anzsoft.xmpp4gwt.client.xmpp.xeps.messageArchiving;

import anzsoft.xmpp4gwt.client.packet.Packet;

public interface MessageArchivingListener {

	void onReceiveSetChat(final Packet iq, ResultSet rs);
}
