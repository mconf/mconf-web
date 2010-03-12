package anzsoft.xmpp4gwt.client.xmpp.xeps.jabberSearch;

import anzsoft.xmpp4gwt.client.JID;

public class Item {

	private String email;

	private String first;

	private final JID jid;

	private String last;

	private String nick;

	public Item(JID jid) {
		this.jid = jid;
	}

	public String getEmail() {
		return email;
	}

	public String getFirst() {
		return first;
	}

	public JID getJid() {
		return jid;
	}

	public String getLast() {
		return last;
	}

	public String getNick() {
		return nick;
	}

	void setEmail(String email) {
		this.email = email;
	}

	void setFirst(String first) {
		this.first = first;
	}

	void setLast(String last) {
		this.last = last;
	}

	void setNick(String nick) {
		this.nick = nick;
	}
}
