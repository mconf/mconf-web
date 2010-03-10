package anzsoft.xmpp4gwt.client.xmpp.xeps.jabberSearch;

import java.util.ArrayList;
import java.util.List;

import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.ResponseHandler;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.stanzas.IQ;
import anzsoft.xmpp4gwt.client.xmpp.ErrorCondition;

public abstract class JabberSearchResponseHandler implements ResponseHandler {

	private String getChildCData(Packet packet, String name) {
		Packet v = packet.getFirstChild(name);
		if (v != null) {
			return v.getCData();
		} else
			return null;
	}

	public void onError(IQ iq, ErrorType errorType,
			ErrorCondition errorCondition, String text) {
	}

	public final void onResult(final IQ iq) {
		List<Item> result = new ArrayList<Item>();
		Packet query = iq.getFirstChild("query");

		for (Packet item : query.getChildren()) {
			if ("item".equals(item.getName())) {
				JID jid = JID.fromString(item.getAtribute("jid"));
				Item res = new Item(jid);
				res.setFirst(getChildCData(item, "first"));
				res.setLast(getChildCData(item, "last"));
				res.setNick(getChildCData(item, "nick"));
				res.setEmail(getChildCData(item, "email"));
				result.add(res);
			}
		}
		onSuccess(iq, result);
	}

	public abstract void onSuccess(final IQ iq, final List<Item> items);

}
