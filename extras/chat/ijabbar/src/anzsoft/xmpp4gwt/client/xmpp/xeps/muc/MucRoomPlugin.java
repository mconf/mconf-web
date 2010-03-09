package anzsoft.xmpp4gwt.client.xmpp.xeps.muc;

import java.util.ArrayList;
import java.util.List;

import anzsoft.xmpp4gwt.client.Plugin;
import anzsoft.xmpp4gwt.client.PluginState;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.citeria.Criteria;
import anzsoft.xmpp4gwt.client.citeria.ElementCriteria;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.stanzas.IQ;

public class MucRoomPlugin implements Plugin {
	private final Session session;

	private List<MucRoomListener> listeners = new ArrayList<MucRoomListener>();

	public MucRoomPlugin(Session session) {
		this.session = session;
	}

	public Criteria getCriteria() {
		return ElementCriteria
				.name("iq")
				.add(
						ElementCriteria
								.name(
										"query",
										new String[] { "xmlns" },
										new String[] { "http://jabber.org/protocol/disco#items" }));
	}

	public PluginState getStatus() {
		return null;
	}

	public boolean process(Packet iq) {
		List<MucRoomItem> rooms = new ArrayList<MucRoomItem>();
		if (iq.getAtribute("type").equals("result")) {
			Packet query = iq.getFirstChild("query");
			for (Packet item : query.getChildren()) {
				MucRoomItem room = new MucRoomItem(item.getAtribute("jid"),
						item.getAtribute("name"));
				rooms.add(room);
			}
		}
		fireOnRoomListUpdate(rooms);
		return true;
	}

	public void reset() {

	}

	public void getMucRoomList(final String mucServerNode) {
		IQ iq = new IQ(IQ.Type.get);
		iq.setAttribute("id", "" + Session.nextId());
		iq.setAttribute("to", mucServerNode);
		iq.addChild("query", "http://jabber.org/protocol/disco#items");
		session.send(iq);
	}

	public void addListener(MucRoomListener listener) {
		listeners.add(listener);
	}

	public void removeListener(MucRoomListener listener) {
		listeners.remove(listener);
	}

	private void fireOnRoomListUpdate(List<MucRoomItem> rooms) {
		for (MucRoomListener l : listeners) {
			l.onRoomListUpdate(rooms);
		}
	}
}
