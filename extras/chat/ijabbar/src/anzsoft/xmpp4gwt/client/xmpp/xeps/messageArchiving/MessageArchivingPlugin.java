package anzsoft.xmpp4gwt.client.xmpp.xeps.messageArchiving;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.Plugin;
import anzsoft.xmpp4gwt.client.PluginState;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.citeria.Criteria;
import anzsoft.xmpp4gwt.client.citeria.ElementCriteria;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.stanzas.IQ;
import anzsoft.xmpp4gwt.client.xmpp.xeps.messageArchiving.Item.Type;

import com.google.gwt.i18n.client.DateTimeFormat;

public class MessageArchivingPlugin implements Plugin {

	private static DateTimeFormat df1 = DateTimeFormat
			.getFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
	private static DateTimeFormat df2 = DateTimeFormat
			.getFormat("yyyy-MM-dd'T'HH:mm:ssZ");

	private static Date parseDate(final String t) {
		try {
			return df1.parse(t);
		} catch (Exception e) {
			try {
				return df2.parse(t);
			} catch (Exception e1) {
				return null;
			}
		}
	}

	private List<MessageArchivingListener> listeners = new ArrayList<MessageArchivingListener>();

	private final Session session;

	public MessageArchivingPlugin(Session session) {
		this.session = session;
	}

	public void addMessageArchivingListener(MessageArchivingListener listener) {
		this.listeners.add(listener);
	}

	private String getChildCData(Packet packet, String name) {
		Packet v = packet.getFirstChild(name);
		if (v != null) {
			return v.getCData();
		} else
			return null;
	}

	public Criteria getCriteria() {
		return ElementCriteria.name("iq").add(
				ElementCriteria.name("chat", "urn:xmpp:tmp:archive"));
	}

	public PluginState getStatus() {
		return null;
	}

	ResultSet makeResultSet(final Packet iq) {
		ResultSet rs = new ResultSet();

		Packet chat = iq.getFirstChild("chat");
		rs.setWithJid(JID.fromString(chat.getAtribute("with")));
		rs.setStart(parseDate(chat.getAtribute("start")));
		rs.setSubject(chat.getAtribute("subject"));

		List<Item> resultItems = new ArrayList<Item>();
		rs.setItems(resultItems);

		Date cd = rs.getStart();

		for (Packet item : chat.getChildren()) {
			String body = getChildCData(item, "body");
			String secsTmp = item.getAtribute("secs");
			String utcTmp = item.getAtribute("utc");

			if (secsTmp != null) {
				int msecs = Integer.parseInt(secsTmp) * 1000;
				cd = new Date(cd.getTime() + msecs);
			} else if (utcTmp != null) {
				try {
					cd = parseDate(utcTmp);
				} catch (Exception e) {
				}
			}

			if ("from".equals(item.getName())) {
				Item it = new Item(Type.FROM, cd, body);
				resultItems.add(it);
			} else if ("to".equals(item.getName())) {
				Item it = new Item(Type.TO, cd, body);
				resultItems.add(it);
			}
		}

		return rs;
	}

	public boolean process(final Packet element) {
		System.out.println("Archive pushed :: " + element);
		final ResultSet rs = makeResultSet(element);
		final String id = element.getAtribute("id");
		try {
			for (MessageArchivingListener listener : this.listeners) {
				listener.onReceiveSetChat(element, rs);
			}
			IQ iq = new IQ(IQ.Type.result);
			iq.setAttribute("id", id);
			this.session.send(iq);
		} catch (Exception e) {
			IQ iq = new IQ(IQ.Type.error);
			iq.setAttribute("id", id);
			this.session.send(iq);
		}
		return true;
	}

	public void removeMessageArchivingListener(MessageArchivingListener listener) {
		this.listeners.remove(listener);
	}

	public void reset() {
	}

	public void retriveCollection(final JID withJid, final Date startTime,
			final MessageArchiveRequestHandler requestHandler) {
		IQ iq = new IQ(IQ.Type.get);
		iq.setAttribute("id", Session.nextId());

		Packet retrieve = iq.addChild("retrieve", "urn:xmpp:tmp:archive");
		retrieve.setAttribute("with", withJid.toString());
		retrieve.setAttribute("start", df1.format(startTime));

		Packet set = retrieve.addChild("set", "http://jabber.org/protocol/rsm");

		Packet max = set.addChild("max", null);
		max.setCData("100");

		this.session.addResponseHandler(iq, requestHandler);
	}

}
